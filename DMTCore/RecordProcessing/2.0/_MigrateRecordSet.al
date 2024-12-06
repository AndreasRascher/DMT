codeunit 91014 DMTMigrateRecordSet
{
    procedure Start(processingPlan: Record DMTProcessingPlan)
    var
        importSettings: Codeunit DMTImportSettings;
        migrationType: Enum DMTMigrationType;
    begin
        importSettings.init(processingPlan);
        case processingPlan.Type of
            // do nothing
            processingPlan.Type::" ", processingPlan.Type::"Group", processingPlan.Type::"Import To Buffer":
                ;
            processingPlan.Type::"Buffer + Target", processingPlan.Type::"Import To Target":
                migrationType := migrationType::MigrateRecords;
            processingPlan.Type::"Update Field":
                migrationType := migrationType::MigrateSelectsFields;
            processingPlan.Type::"Enter default values in target table":
                migrationType := migrationType::ApplyFixValuesToTarget;
            else
                Error('ProcessingPlan Type %1 not supported', processingPlan.Type);
        end;
        Start(importSettings.ImportConfigHeader(), importSettings, migrationType);
    end;

    procedure RetryErrors(processingPlan: Record DMTProcessingPlan)
    var
        importSettings: Codeunit DMTImportSettings;
        migrationType: Enum DMTMigrationType;
    begin
        importSettings.init(processingPlan);
        Start(importSettings.ImportConfigHeader(), importSettings, migrationType::RetryErrors);
    end;

    procedure Start(importConfigHeader: Record DMTImportConfigHeader; migrationType: Enum DMTMigrationType)
    var
        importSettings: Codeunit DMTImportSettings;
    begin
        // Set Processing Parameters
        importSettings.init(importConfigHeader, migrationType);
        Start(importConfigHeader, importSettings, migrationType);
    end;

    local procedure Start(importConfigHeader: Record DMTImportConfigHeader; importSettings: Codeunit DMTImportSettings; migrationType: Enum DMTMigrationType)
    var
        log: Codeunit "DMTLog";
        migrationLib: Codeunit DMTMigrationLib;
        bufferRef: recordRef;
        RecIdList: List of [RecordId];
        iReplacementHandler: Interface IReplacementHandler;
        iTriggerLog: Interface ITriggerLog;
        noOfRecordsProcessed: Integer;
    begin
        importSettings.UseTriggerLog(importConfigHeader."Log Trigger Changes");
        importSettings.EvaluateOptionValueAsNumber(importConfigHeader."Ev. Nos. for Option fields as" = importConfigHeader."Ev. Nos. for Option fields as"::Position);
        DMTSetup.GetRecordOnce();
        // Checks
        CheckIfAllKeyFieldsAreAssigned(importConfigHeader);
        // Nummernserien:
        // - Laden der nächsten Nummern vor der Verarbeitung
        // - Nur wenn der Prozess erfolgreich war, dann die Nummern speichern
        CheckNoSeriesFieldSetup(importConfigHeader);
        // Prepare Buffer
        DefineSourceRecords(bufferRef, RecIdList, importSettings, migrationType);
        // Prepare FieldMapping
        LoadImportConfigLine(importSettings);
        // Prepare NoSeries
        LoadNoSeriesConfig(importSettings);
        // Prepare Log
        case migrationType of
            migrationType::MigrateRecords:
                log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", importConfigHeader);
            migrationType::MigrateSelectsFields:
                log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Field Update", importConfigHeader);
            migrationType::RetryErrors:
                log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", importConfigHeader);
            migrationType::ApplyFixValuesToTarget:
                log.InitNewProcess(Enum::DMTLogUsage::"Apply Fixed Values", importConfigHeader);
        end;
        if importSettings.UseTriggerLog() then
            DMTSetup.getDefaultTriggerLogImplementation(iTriggerLog);
        // Prepare Replacements
        DMTSetup.getDefaultReplacementImplementation(iReplacementHandler);
        iReplacementHandler.InitBatchProcess(importConfigHeader);
        // Show Filter Dialog
        if migrationType <> migrationType::RetryErrors then begin
            importConfigHeader.BufferTableMgt().InitBufferRef(bufferRef, true);
            Commit(); // Runmodal Dialog in Edit View
            if not EditView(bufferRef, importSettings) then
                exit;
        end;
        // Progress
        Progress_StartTime := CurrentDateTime; // needed for duration calculation in log entry
        if migrationType = migrationType::RetryErrors then
            PrepareProgressBar(importConfigHeader, RecIdList.Count, importSettings, false)
        else
            PrepareProgressBar(importConfigHeader, bufferRef.Count, importSettings, true);

        noOfRecordsProcessed := processRecords(importSettings, migrationType, log, bufferRef, RecIdList, iReplacementHandler, iTriggerLog);

        // Close Progress
        if Progress_IsOpen then
            Progress.Close();
        // Post Processing
        migrationLib.RunPostProcessingFor(importConfigHeader);
        importConfigHeader.BufferTableMgt().updateImportToTargetPercentage();
        // Finish Log
        log.CreateSummary(noOfRecordsProcessed, noOfRecordsProcessed - Progress_NoOfErrors - Progress_NoOfRecordsIgnored, Progress_NoOfErrors, CurrentDateTime - Progress_StartTime);
        if not ImportSettings.NoUserInteraction() then begin
            log.ShowLogForCurrentProcess();
            ShowResultDialog();
        end;

    end;

    local procedure DefineSourceRecords(var bufferRef: RecordRef; var RecIdList: List of [RecordId]; importSettings: Codeunit DMTImportSettings; migrationType: Enum DMTMigrationType)
    var
        LogQry: Query DMTLogQry;

        noBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filter: "%1"',
                                    Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Filter: "%1"';
        NoErrorFoundLbl: Label 'No errors were found for retry', Comment = 'de-DE=Es wurden keine Fehler zur erneuten Verbeitung gefunden';

    begin
        case migrationType of
            DMTMigrationType::MigrateRecords,
            DMTMigrationType::MigrateSelectsFields:
                begin
                    Clear(bufferRef);
                    importSettings.ImportConfigHeader().BufferTableMgt().InitBufferRef(bufferRef, true);
                    if bufferRef.IsEmpty then
                        Error(noBufferTableRecorsInFilterErr, bufferRef.GetFilters);
                end;
            DMTMigrationType::ApplyFixValuesToTarget:
                begin
                    Clear(bufferRef);
                    bufferRef.Open(importSettings.ImportConfigHeader()."Target Table ID");
                end;
            DMTMigrationType::RetryErrors:
                begin
                    LogQry.SetRange(LogQry.SourceFileName, importSettings.ImportConfigHeader().GetSourceFileName());
                    LogQry.Open();
                    while LogQry.Read() do begin
                        if Format(LogQry.SourceID) <> '' then
                            RecIdList.Add(LogQry.SourceID);
                    end;
                    // show message
                    if not importSettings.NoUserInteraction() then
                        if RecIdList.Count = 0 then
                            Message(NoErrorFoundLbl);
                end;
            else
                Error('DefineSourceRecords: Unhandled migration type %1', migrationType);
        end;
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
                    if not tempImportConfigLine.Get(tempImportConfigLine_ProcessingPlanSettings.RecordId) then begin
                        // if fixed value is set for a unmapped field, create a new line
                        importConfigLine.Get(tempImportConfigLine_ProcessingPlanSettings.RecordId);
                        tempImportConfigLine := importConfigLine;
                        tempImportConfigLine."Processing Action" := tempImportConfigLine_ProcessingPlanSettings."Processing Action";
                        tempImportConfigLine."Custom Value" := tempImportConfigLine_ProcessingPlanSettings."Custom Value";
                        tempImportConfigLine.Insert(false);
                    end else begin
                        tempImportConfigLine := tempImportConfigLine_ProcessingPlanSettings;
                        tempImportConfigLine.Modify();
                    end;
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

    local procedure EditView(var BufferRef: RecordRef; var importSettings: Codeunit DMTImportSettings) Continue: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        fieldSelection: Page DMTFieldSelection;
    begin
        Continue := true; // Canceling the dialog should stop the process

        if importSettings.SourceTableView() <> '' then begin
            BufferRef.SetView(importSettings.SourceTableView());
        end;

        if importSettings.NoUserInteraction() then begin
            exit(Continue);
        end;

        ImportConfigHeader.Get(importSettings.ImportConfigHeader().RecordId);
        // if not FPBuilder.RunModal(BufferRef, ImportConfigHeader) then
        // exit(false);
        if not fieldSelection.EditSourceTableFilters(BufferRef, ImportConfigHeader) then
            exit(false);
        if BufferRef.HasFilter then begin
            ImportConfigHeader.WriteSourceTableView(BufferRef.GetView(false));
            Commit();
            importSettings.SourceTableView(BufferRef.GetView(false));
        end else begin
            ImportConfigHeader.WriteSourceTableView('');
            Commit();
            importSettings.SourceTableView('');
        end;
    end;


    local procedure MoveNext(var bufferRef: RecordRef; loopCount: Integer; var RecIdList: List of [RecordId]; noOfRecordsProcessed: Integer; migrationType: Enum DMTMigrationType) OK: Boolean
    begin
        case migrationType of
            // Retry Errors - Step through RecID List
            migrationType::RetryErrors:
                begin
                    if true in [RecIdList.Count = 0, noOfRecordsProcessed = RecIdList.Count] then
                        OK := false
                    else
                        OK := bufferRef.Get(RecIdList.Get(noOfRecordsProcessed + 1));
                end;
            // First Record from buffer table
            migrationType::MigrateRecords, migrationType::MigrateSelectsFields, migrationType::ApplyFixValuesToTarget:
                begin
                    if loopCount = 0 then
                        OK := bufferRef.FindSet()
                    else
                        OK := (bufferRef.Next() <> 0);
                end;

            else
                Error('unhandled migration type %1', migrationType);
        end;
    end;

    local procedure ProcessSingleRecord(bufferRef: RecordRef; importSettings: Codeunit DMTImportSettings; log: Codeunit DMTLog; var triggerLog: Interface ITriggerLog; iReplacementHandler: Interface IReplacementHandler; var Result: Enum DMTProcessingResultType)
    var
        migrateRecord: Codeunit DMTMigrateRecord;
        targetRecordExists: Boolean;
        skipRecord: Boolean;
    begin
        Log.DeleteExistingLogFor(bufferRef);
        if importSettings.UseTriggerLog() then
            triggerLog.DeleteExistingLogFor(bufferRef);

        skipRecord := false;
        CustomValueSettingsGlobal.prepareNoSeriesNextNo(importSettings);
        migrateRecord.Init(bufferRef, importSettings, iReplacementHandler);
        Result := Result::ChangesApplied; // default
        Commit();
        // 1. Read Key Fields
        if not ProcessKeyFields(migrateRecord) then begin
            migrateRecord.CollectLastError();
            Result := Enum::DMTProcessingResultType::Error;
        end;

        // 2. Skip if no target record found for update
        targetRecordExists := migrateRecord.TargetRecordExists();
        if importSettings.UpdateExistingRecordsOnly() and not targetRecordExists then begin
            Result := Enum::DMTProcessingResultType::Ignored;
            skipRecord := true;
        end;

        // 2.1. Set Existing Record as source for update
        if targetRecordExists and importSettings.UpdateExistingRecordsOnly() then
            migrateRecord.SetExistingRecordAsSource();

        // 3. Read Non-Key Fields
        if not skipRecord then
            ProcessNonKeyFields(migrateRecord);

        // 4. Insert or Update Record if no unignorable errors occured   
        if not skipRecord and not migrateRecord.HasErrorsThatShouldNotBeIngored() then
            if not targetRecordExists then begin
                // 4.a Insert Record
                if not InsertRecord(migrateRecord) then begin
                    migrateRecord.CollectLastError();
                    Result := Enum::DMTProcessingResultType::Error;
                end else begin
                    migrateRecord.UpdateDMTImportFields(); // write reference to target record after import
                end;
            end else begin
                // 4.b Update Record
                if not UpdateRecord(migrateRecord) then begin
                    migrateRecord.CollectLastError();
                    Result := Enum::DMTProcessingResultType::Error;
                end;
            end;
        // 5. Store Log
        if not skipRecord then begin
            migrateRecord.SaveErrorLog(Log);
            if importSettings.UseTriggerLog() then
                migrateRecord.SaveTriggerLog(Log);
        end;
        // 6. Set Result
        if migrateRecord.HasErrorsThatShouldNotBeIngored() then
            Result := Enum::DMTProcessingResultType::Error;
        // 7. Update last used no. series no. in import config line if Success
        if Result <> Enum::DMTProcessingResultType::Error then
            CustomValueSettingsGlobal.finalizeNoSeries(migrateRecord.GetNoSeriesStartingNos());
    end;

    procedure ProcessKeyFields(var migrateRecord: Codeunit DMTMigrateRecord) Success: Boolean
    begin
        migrateRecord.SetRunMode_ProcessKeyFields();
        while not migrateRecord.Run() do begin
            migrateRecord.CollectLastError();
        end;
        Success := not migrateRecord.HasErrorsThatShouldNotBeIngored();
    end;

    local procedure ProcessNonKeyFields(var migrateRecord: Codeunit DMTMigrateRecord) Success: Boolean
    begin
        migrateRecord.SetRunMode_ProcessNonKeyFields();
        while not migrateRecord.Run() do begin
            migrateRecord.CollectLastError();
        end;
        Success := not migrateRecord.HasErrorsThatShouldNotBeIngored();
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

    procedure CheckIfAllKeyFieldsAreAssigned(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        ImportConfigLine: Record DMTImportConfigLine;
        noValidMappingFoundForKeyFieldErr: Label 'No valid mapping found for key field "%1"',
                        Comment = 'de-DE=Keine gültige Zuordnung für Schlüsselfeld "%1" gefunden';
    begin
        // Key Fields Mapping Exists
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        ImportConfigLine.SetRange("Is Key Field(Target)", true);
        if ImportConfigLine.FindSet(false) then
            repeat
                case true of
                    // source field mapping
                    (ImportConfigLine."Source Field No." <> 0):
                        ;
                    // no series as source
                    (ImportConfigLine."Custom Value Type" = ImportConfigLine."Custom Value Type"::"No.Series"):
                        ;
                    // fixed value as source
                    (ImportConfigLine."Custom Value Type" = ImportConfigLine."Custom Value Type"::"Fixed Value"):
                        ;
                    else begin
                        ImportConfigLine.CalcFields("Target Field Caption");
                        Error(noValidMappingFoundForKeyFieldErr, ImportConfigLine."Target Field Caption");
                    end;
                end;
            until ImportConfigLine.Next() = 0;

        if ImportConfigLine.IsEmpty then
            Error(noValidMappingFoundForKeyFieldErr, ImportConfigHeader.ID);
    end;

    local procedure CheckNoSeriesFieldSetup(importConfigHeader: Record DMTImportConfigHeader)
    var
        importConfigLine: Record DMTImportConfigLine;
        NoSeries: Record "No. Series";
        StartingNo, LastUsedNo : Text;
        BCNoSeriesCode: Text;
        noStartingNoDefinedErr: Label 'No Starting No. defined for field %1', Comment = 'de-DE=Keine Startnummer definiert für Feld %1';
        bcNoSeriesNotFoundErr: Label 'No. Series Code %1 not found for field %2', Comment = 'de-DE=Nummernserie %1 nicht gefunden für Feld %2';
    begin
        // Check if Starting Nos is valid and exists
        ImportConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.SetFilter("Processing Action", '<>%1', importConfigLine."Processing Action"::Ignore);
        importConfigLine.SetRange("Custom Value Type", importConfigLine."Custom Value Type"::"No.Series");
        if importConfigLine.FindSet() then
            repeat
                importConfigLine.TestField("Source Field No.", 0);
                // Type Starting No
                if CustomValueSettingsGlobal.IsNoSeriesTypeStartingNo(importConfigLine) then begin
                    StartingNo := CustomValueSettingsGlobal.GetSetting_StartingNo(importConfigLine);
                    if StartingNo = '' then begin
                        importConfigLine.CalcFields("Target Field Caption");
                        Error(noStartingNoDefinedErr, importConfigLine."Target Field Caption");
                    end else
                        CustomValueSettingsGlobal.CheckIfNoCanBeIncreased(StartingNo, '');
                    LastUsedNo := CustomValueSettingsGlobal.GetSetting_LastUsedNo(importConfigLine);
                    if LastUsedNo <> '' then
                        CustomValueSettingsGlobal.CheckIfNoCanBeIncreased('', LastUsedNo);
                end;
                // Type BC No Series
                if CustomValueSettingsGlobal.IsNoSeriesTypeBCNoSeries(importConfigLine) then begin
                    BCNoSeriesCode := CustomValueSettingsGlobal.GetSetting_BcNoSeriesCode(importConfigLine);
                    if true in [BCNoSeriesCode = '', not NoSeries.Get(BCNoSeriesCode)] then begin
                        importConfigLine.CalcFields("Target Field Caption");
                        Error(BCNoSeriesNotFoundErr, BCNoSeriesCode, importConfigLine."Target Field Caption");
                    end;
                end;
            until importConfigLine.Next() = 0;
    end;

    procedure PrepareProgressBar(var ImportConfigHeader: Record DMTImportConfigHeader; noOfRecordsToProcess: Integer; var importSettings: Codeunit DMTImportSettings; applyLimits: Boolean)
    var
        MaxWith: Integer;
        DurationLbl: Label 'Duration', Comment = 'de-DE=Dauer';
        TimeRemainingLbl: Label 'Time Remaining', Comment = 'de-DE=Verbleibende Zeit';
        ProgressBarTitle: Text;
        ProgressBarText: TextBuilder;
        RecordsToProcessLimit, RecordsToProcessStartPos : Integer;
        debug: Text;
    begin
        // Use Limit or all records for progress
        if applyLimits then begin
            RecordsToProcessLimit := importSettings.RecordsToProcessLimit();
            RecordsToProcessStartPos := importSettings.RecordsToProcessStartPos();
            if RecordsToProcessStartPos > 0 then
                noOfRecordsToProcess := noOfRecordsToProcess - (RecordsToProcessStartPos - 1);
            if RecordsToProcessLimit <> 0 then
                if RecordsToProcessLimit < noOfRecordsToProcess then
                    noOfRecordsToProcess := RecordsToProcessLimit;
        end;

        Progress_UpdateThresholdInMS := 1000; // 1 Seconds
        ProgressBarTitle := ImportConfigHeader."Target Table Caption";
        MaxWith := 100 - 40;
        if StrLen(ProgressBarTitle) < MaxWith then begin
            ProgressBarTitle := PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_') +
                                ProgressBarTitle +
                                PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_');
        end;
        Progress_NoOfSteps := noOfRecordsToProcess;
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
        Progress_NoOfRecordsProcessed += 1;
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
            Progress.Update(2, StrSubstNo('%1 / %2', format(Progress_NoOfRecordsProcessed, 0, '<Integer Thousand>'), format(Progress_NoOfSteps, 0, '<Integer Thousand>')));
            // ProgressDialog.UpdateControlWithCustomDuration('Duration', 'Progress');
            Progress.Update(3, Format(CurrentDateTime - Progress_StartTime));
            // ProgressDialog.UpdateProgressBar('Progress', 'Process');
            Progress.Update(4, (10000 * (Progress_NoOfRecordsProcessed / Progress_NoOfSteps)) div 1);
            // ProgressDialog.UpdateFieldControl('TimeRemaining', ProgressDialog.GetRemainingTime('Progress', 'Process'));
            Progress.Update(5, GetRemainingTime(Progress_StartTime, Progress_NoOfRecordsProcessed, Progress_NoOfSteps));
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

    local procedure ShowResultDialog()
    var
        ResultMsg: Label 'No. of Records..\processed: %1\imported: %2\With Error: %3\Processing Time:%4',
         Comment = 'de-DE=Anzahl Datensätze..\verarbeitet: %1\eingelesen : %2\mit Fehlern: %3\Verarbeitungsdauer: %4';
    begin
        Message(ResultMsg,
                Progress_NoOfRecordsProcessed,
                Progress_ResultOK,
                Progress_NoOfErrors,
                CurrentDateTime - Progress_StartTime);
    end;

    local procedure LoadNoSeriesConfig(var importSettings: Codeunit DMTImportSettings)
    var
        tempImportConfigLine: Record DMTImportConfigLine temporary;
        noSeriesSettings: Dictionary of [RecordId, Dictionary of [Text, Text]];
    begin
        importSettings.GetImportConfigLine(tempImportConfigLine);
        tempImportConfigLine.Reset();
        tempImportConfigLine.SetRange("Custom Value Type", tempImportConfigLine."Custom Value Type"::"No.Series");
        if not tempImportConfigLine.FindSet() then
            exit;
        repeat
            CustomValueSettingsGlobal.AddToNoSeriesSetting(noSeriesSettings, tempImportConfigLine);
        until tempImportConfigLine.Next() = 0;
        importSettings.NoSeriesSettings(noSeriesSettings);
    end;

    local procedure processRecords(var importSettings: Codeunit DMTImportSettings; var migrationType: Enum DMTMigrationType; var log: Codeunit "DMTLog"; var bufferRef: recordRef; var RecIdList: List of [RecordId]; var iReplacementHandler: Interface IReplacementHandler; var iTriggerLog: Interface ITriggerLog) noOfRecordsProcessed: Integer
    var
        Result: Enum DMTProcessingResultType;
        loopCount, noMaxNoOfRecords, startPos : Integer;
    begin
        loopCount := 0;
        noOfRecordsProcessed := 0;
        noMaxNoOfRecords := importSettings.RecordsToProcessLimit();
        startPos := importSettings.RecordsToProcessStartPos();

        while MoveNext(bufferRef, loopCount, RecIdList, noOfRecordsProcessed, migrationType) do begin
            loopCount += 1;
            // Limit is defined and reached
            if (noMaxNoOfRecords <> 0) and (noOfRecordsProcessed = noMaxNoOfRecords) then
                break;
            // Start Processing after Start Position
            if (loopCount >= startPos) then begin
                noOfRecordsProcessed += 1;
                ProcessSingleRecord(bufferRef, importSettings, log, iTriggerLog, iReplacementHandler, Result);
                UpdateProgress(Result);
            end;
        end;
    end;

    procedure FindCollationProblems(RecordMapping: Dictionary of [RecordId, RecordId]) CollationProblems: Dictionary of [RecordId, RecordId]
    var
        TargetRecID: RecordId;
        LastIndex, ListIndex : Integer;
    begin
        for ListIndex := 1 to RecordMapping.Values.Count do begin
            TargetRecID := RecordMapping.Values.Get(ListIndex);
            LastIndex := RecordMapping.Values.LastIndexOf(TargetRecID);
            if LastIndex <> ListIndex then begin
                CollationProblems.Add(RecordMapping.Keys.Get(ListIndex), RecordMapping.Values.Get(ListIndex));
                CollationProblems.Add(RecordMapping.Keys.Get(LastIndex), RecordMapping.Values.Get(LastIndex));
            end;
        end;
    end;

    var
        DMTSetup: Record "DMTSetup";
        CustomValueSettingsGlobal: Page DMTCustomValueSettings;
        Progress: Dialog;
        Progress_StartTime, Progess_LastUpdate : DateTime;
        Progress_NoOfSteps: Integer;
        Progress_IsOpen: Boolean;
        Progress_NoOfRecordsProcessed, Progress_NoOfErrors, Progress_ResultOK, Progress_NoOfRecordsIgnored, Progress_UpdateThresholdInMS : Integer;
}