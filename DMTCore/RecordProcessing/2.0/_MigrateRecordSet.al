codeunit 90001 DMTMigrateRecordSet
{
    // procedure RetryFailedRecords()
    // var
    //     log: Codeunit "DMTLog";
    // begin
    //     DefineSourceRecords();
    //     PrepareLog(log);
    //     PrepareReplacements();
    //     PrepareProgressBar();
    //     ProcessRecords(log);
    //     CloseProgressBar();
    //     FinishLog(log);
    // end;

    procedure Start(importConfigHeader: Record DMTImportConfigHeader; migrationType: Enum DMTMigrationType; recordsToProcessLimit: Integer)
    var
        log: Codeunit "DMTLog";
        importSettings: Codeunit DMTImportSettings;
        bufferRef: recordRef;
        Result: Enum DMTProcessingResultType;
        iReplacementHandler: Interface IReplacementHandler;
    begin
        //TODO: Enable/Disable TriggerLog from Setup
        importSettings.UseTriggerLog(true);
        // Checks
        CheckMappedFieldsExist(importConfigHeader);
        // Set Processing Parameters
        importSettings.init(importConfigHeader, migrationType);
        // Prepare Buffer
        DefineSourceRecords(bufferRef, importSettings, migrationType);
        // Prepare FieldMapping
        LoadImportConfigLine(importSettings);
        // Prepare Log
        log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", importConfigHeader);
        // Prepare Replacements
        DMTSetup.getDefaultReplacementImplementation(iReplacementHandler);
        iReplacementHandler.InitBatchProcess(importConfigHeader);
        // Progress
        if not importSettings.NoUserInteraction() then
            PrepareProgressBar(importConfigHeader, bufferRef);
        // Process Records
        Clear(NoOfRecordsProcessedGlobal);
        while MoveNext(bufferRef, recordsToProcessLimit, NoOfRecordsProcessedGlobal) do begin
            NoOfRecordsProcessedGlobal += 1;
            ProcessSingleRecord(bufferRef, importSettings, log, iReplacementHandler, false, Result);
            UpdateProgress(Result);
        end;
        // Close Progress
        if Progress_IsOpen then
            Progress.Close();
    end;

    local procedure DefineSourceRecords(var bufferRef: RecordRef; var importSettings: Codeunit DMTImportSettings; migrationType: Enum DMTMigrationType)
    var
        noBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filter: "%1"',
                                    Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Filter: "%1"';
    begin
        case migrationType of
            DMTMigrationType::MigrateRecords,
            DMTMigrationType::MigrateSelectsFields:
                begin
                    Clear(bufferRef);
                    importSettings.ImportConfigHeader().BufferTableMgt().InitBufferRef(bufferRef, true);
                end;
            DMTMigrationType::ApplyFixValuesToTarget:
                begin
                    Clear(bufferRef);
                    bufferRef.Open(importSettings.ImportConfigHeader()."Target Table ID");
                end;
            else
                Error('DefineSourceRecords: Unhandled migration type %1', migrationType);
        end;
        if bufferRef.IsEmpty then
            Error(noBufferTableRecorsInFilterErr, bufferRef.GetFilters);
    end;

    local procedure LoadImportConfigLine(var importSettings: Codeunit DMTImportSettings) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
        tempImportConfigLine, tempImportConfigLine_ProcessingPlanSettings : Record DMTImportConfigLine temporary;
        importConfigHeader: Record DMTImportConfigHeader;
    begin
        importConfigHeader := importSettings.ImportConfigHeader();
        importConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.SetFilter("Processing Action", '<>%1', importConfigLine."Processing Action"::Ignore);
        if not importConfigHeader.UseGenericBufferTable() then
            importConfigLine.SetFilter("Source Field No.", '<>0');

        if importSettings.UpdateFieldsFilter() <> '' then begin

            // Mark Key Fields
            importConfigLine.SetRange("Is Key Field(Target)", true);
            importConfigLine.FindSet();
            repeat
                importConfigLine.Mark(true);
            until importConfigLine.Next() = 0;

            // Mark Selected Fields
            importConfigLine.SetRange("Is Key Field(Target)");
            importConfigLine.SetFilter("Target Field No.", importSettings.UpdateFieldsFilter());
            importConfigLine.FindSet();
            repeat
                importConfigLine.Mark(true);
            until importConfigLine.Next() = 0;

            importConfigLine.SetRange("Target Field No.");
            importConfigLine.MarkedOnly(true);
        end;
        importConfigLine.CopyToTemp(tempImportConfigLine);

        // Processing Plan - update field mapping with processing plan settings (fixed values) 
        if importSettings.ProcessingPlan()."Line No." <> 0 then begin
            importSettings.ProcessingPlan().ConvertDefaultValuesViewToFieldLines(tempImportConfigLine_ProcessingPlanSettings);
            if tempImportConfigLine_ProcessingPlanSettings.FindSet() then
                repeat
                    tempImportConfigLine.Get(tempImportConfigLine_ProcessingPlanSettings.RecordId);
                    tempImportConfigLine := tempImportConfigLine_ProcessingPlanSettings;
                    tempImportConfigLine.Modify();
                until tempImportConfigLine_ProcessingPlanSettings.Next() = 0;
        end;

        // Update From Field No From Index To Gen.Buff Field No
        if importConfigHeader.UseGenericBufferTable() then begin
            tempImportConfigLine.Reset();
            if tempImportConfigLine.FindSet() then
                repeat
                    if tempImportConfigLine."Source Field No." < 1000 then begin
                        tempImportConfigLine."Source Field No." += 1000;
                        tempImportConfigLine.Modify();
                    end;
                until tempImportConfigLine.Next() = 0;
        end;

        OK := tempImportConfigLine.FindFirst();
        importSettings.SetImportConfigLine(tempImportConfigLine);
    end;


    local procedure MoveNext(var bufferRef: RecordRef; noRecordsToProcessLimit: Integer; noOfRecordsProcessed: Integer) OK: Boolean
    begin
        case true of
            // First Record
            (noOfRecordsProcessed = 0):
                OK := bufferRef.FindSet();
            // Limit is defined and reached
            (noRecordsToProcessLimit <> 0) and (noOfRecordsProcessed > noRecordsToProcessLimit):
                OK := false;
            // Next Record
            else
                OK := (bufferRef.Next() <> 0);
        end;
    end;

    local procedure ProcessSingleRecord(bufferRef: RecordRef; importSettings: Codeunit DMTImportSettings; log: Codeunit DMTLog; iReplacementHandler: Interface IReplacementHandler; UpdateExistingRecordsOnly: Boolean; var Result: Enum DMTProcessingResultType)
    var
        migrateRecord: Codeunit DMTMigrateRecord;
        targetRecordExists: Boolean;
    begin
        migrateRecord.Init(bufferRef, importSettings, iReplacementHandler);
        Result := Result::ChangesApplied; // default

        // 1. Read Key Fields
        if not ProcessKeyFields(migrateRecord) then begin
            migrateRecord.SaveErrors(log);
            Result := Enum::DMTProcessingResultType::Error;
            exit;
        end;

        // 2. Skip if no target record found for update
        targetRecordExists := migrateRecord.TargetRecordExists();
        if UpdateExistingRecordsOnly and not targetRecordExists then begin
            Result := Enum::DMTProcessingResultType::Ignored;
            exit;
        end;

        // 3. Read Non-Key Fields
        if not ProcessNonKeyFields(migrateRecord) then begin
            migrateRecord.SaveErrors(log);
            Result := Enum::DMTProcessingResultType::Error;
            exit;
        end;

        if not targetRecordExists then begin
            // 4.a Insert Record
            if not InsertRecord(migrateRecord) then begin
                migrateRecord.SaveErrors(log);
                Result := Enum::DMTProcessingResultType::Error;
                exit;
            end;
        end else
            // 4.b Update Record
            if not UpdateRecord(migrateRecord) then begin
                migrateRecord.SaveErrors(log);
                Result := Enum::DMTProcessingResultType::Error;
                exit;
            end;
    end;

    local procedure ProcessKeyFields(var migrateRecord: Codeunit DMTMigrateRecord) Success: Boolean
    begin
        Success := true;
        migrateRecord.SetRunMode_ProcessKeyFields();
        while not migrateRecord.Run() do begin
            migrateRecord.CollectLastError();
        end;
        // Success is only false if there are errors that should not be ignored
        if migrateRecord.HasErrorsThatShouldNotBeIngored() then
            Success := false;
    end;

    local procedure ProcessNonKeyFields(migrateRecord: Codeunit DMTMigrateRecord) Success: Boolean
    begin
        Success := true;
        migrateRecord.SetRunMode_ProcessNonKeyFields();
        while not migrateRecord.Run() do begin
            migrateRecord.CollectLastError();
        end;
        // Success is only false if there are errors that should not be ignored
        if migrateRecord.HasErrorsThatShouldNotBeIngored() then
            Success := false;
    end;

    local procedure InsertRecord(migrateRecord: Codeunit DMTMigrateRecord) Success: Boolean
    begin
        Success := true;
        migrateRecord.SetRunMode_InsertRecord();
        if not migrateRecord.Run() then begin
            migrateRecord.CollectLastError();
            exit(false);
        end;
    end;

    local procedure UpdateRecord(migrateRecord: Codeunit DMTMigrateRecord) Success: Boolean
    begin
        Success := true;
        migrateRecord.SetRunMode_ModifyRecord();
        if not migrateRecord.Run() then begin
            migrateRecord.CollectLastError();
            exit(false);
        end;
    end;

    procedure CheckMappedFieldsExist(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        ImportConfigLine: Record DMTImportConfigLine;
        ImportConfigLineEmptyErr: Label 'No field mapping found for import configuration "%1"',
                        Comment = 'de-DE=Importkonfiguration "%1" enthält keine Feldzuordnung.';
    begin
        // Key Fields Mapping Exists
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        ImportConfigLine.SetRange("Is Key Field(Target)", true);
        ImportConfigLine.SetFilter("Source Field No.", '<>0');

        if ImportConfigLine.IsEmpty then
            Error(ImportConfigLineEmptyErr, ImportConfigHeader.ID);
    end;

    procedure PrepareProgressBar(var ImportConfigHeader: Record DMTImportConfigHeader; var bufferRef: RecordRef)
    var
        MaxWith: Integer;
        DurationLbl: Label 'Duration', Comment = 'de-DE=Dauer';
        TimeRemainingLbl: Label 'Time Remaining', Comment = 'de-DE=Verbleibende Zeit';
        ProgressBarTitle: Text;
        ProgressBarText: TextBuilder;
    begin
        Progress_UpdateThresholdInMS := 1000; // 1 Seconds
        ProgressBarTitle := ImportConfigHeader."Target Table Caption";
        MaxWith := 100 - 40;
        if StrLen(ProgressBarTitle) < MaxWith then begin
            ProgressBarTitle := PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_') +
                                ProgressBarTitle +
                                PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_');
        end;

        Progress_StartTime := CurrentDateTime;
        Progress_NoOfSteps := bufferRef.Count;
        ProgressBarText.AppendLine(ProgressBarTitle);
        ProgressBarText.AppendLine('\Filter:' + PadStr('', 42, '#') + '1#');
        ProgressBarText.AppendLine('\Record:' + PadStr('', 42, '#') + '2#');
        ProgressBarText.AppendLine('\' + DurationLbl + ':' + PadStr('', 42, '#') + '3#');
        ProgressBarText.AppendLine('\Progress:' + PadStr('', 42, '@') + '4@');
        ProgressBarText.AppendLine('\' + TimeRemainingLbl + ':' + PadStr('', 42, '#') + '5#');

        Clear(Progress);
        Progress.Open(ProgressBarText.ToText());
        Progress_IsOpen := true;
    end;

    procedure UpdateProgress(ResultType: Enum DMTProcessingResultType)
    begin
        // ProgressDialog.NextStep('Process');
        Progress_NoOfStepsProcessed += 1;
        case ResultType of
            ResultType::Error:
                Progress_NoOfErrors += 1;
            ResultType::Ignored:
                Progress_NoOfRecordsIgnored += 1;
            ResultType::ChangesApplied:
                Progress_ResultOK += 1;
            else begin
                Error('Unhandled Case %1', ResultType::" ");
            end;
        end;
        if Progress_DoUpdate() then begin
            // ProgressDialog.UpdateFieldControl('NoofRecord', StrSubstNo('%1 / %2', ProgressDialog.GetStep('Process'), ProgressDialog.GetTotalStep('Process')));
            Progress.Update(2, StrSubstNo('%1 / %2', Progress_NoOfStepsProcessed, Progress_NoOfSteps));
            // ProgressDialog.UpdateControlWithCustomDuration('Duration', 'Progress');
            Progress.Update(3, Format(CurrentDateTime - Progress_StartTime));
            // ProgressDialog.UpdateProgressBar('Progress', 'Process');
            Progress.Update(4, (10000 * Progress_NoOfStepsProcessed / Progress_NoOfSteps) div 1);
            // ProgressDialog.UpdateFieldControl('TimeRemaining', ProgressDialog.GetRemainingTime('Progress', 'Process'));
            Progress.Update(5, GetRemainingTime(Progress_StartTime, Progress_NoOfStepsProcessed, Progress_NoOfSteps));
        end;
    end;

    procedure GetRemainingTime(StartTime: DateTime; Step: Integer; TotalNoOfSteps: Integer) TimeLeft: Text
    var
        RemainingMins: Decimal;
        RemainingSeconds: Decimal;
        ElapsedTime: Duration;
        RoundedRemainingMins: Integer;
    begin
        ElapsedTime := Round(((CurrentDateTime - StartTime) / 1000), 1);
        RemainingMins := Round((((ElapsedTime / ((Step / TotalNoOfSteps) * 100) * 100) - ElapsedTime) / 60), 0.1);
        RoundedRemainingMins := Round(RemainingMins, 1, '<');
        RemainingSeconds := Round(((RemainingMins - RoundedRemainingMins) * 0.6) * 100, 1);
        TimeLeft := StrSubstNo('%1:', RoundedRemainingMins);
        if StrLen(Format(RemainingSeconds)) = 1 then
            TimeLeft += StrSubstNo('0%1', RemainingSeconds)
        else
            TimeLeft += StrSubstNo('%1', RemainingSeconds);
    end;

    local procedure Progress_DoUpdate(): Boolean
    begin
        if not Progress_IsOpen then
            exit(false);
        if Progess_LastUpdate = 0DT then
            Progess_LastUpdate := CurrentDateTime - Progress_UpdateThresholdInMS;
        if (CurrentDateTime - Progess_LastUpdate) <= Progress_UpdateThresholdInMS then
            exit(false);
        Progess_LastUpdate := CurrentDateTime;
        exit(true);
    end;

    var
        DMTSetup: Record "DMTSetup";
        NoOfRecordsProcessedGlobal: Integer;
        Progress: Dialog;
        Progress_StartTime, Progess_LastUpdate : DateTime;
        Progress_NoOfSteps: Integer;
        Progress_IsOpen: Boolean;
        Progress_NoOfStepsProcessed, Progress_NoOfErrors, Progress_ResultOK, Progress_NoOfRecordsIgnored, Progress_UpdateThresholdInMS : Integer;
}