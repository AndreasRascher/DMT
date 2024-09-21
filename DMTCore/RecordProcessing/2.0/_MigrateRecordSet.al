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

    procedure MigrateRecordsFromSourceToTarget(importConfigHeader: Record DMTImportConfigHeader; recordsToProcessLimit: Integer)
    var
        tempImportConfigLine: Record DMTImportConfigLine temporary;
        log: Codeunit "DMTLog";
        bufferRef: recordRef;
        Result: Enum DMTProcessingResultType;
        iReplacementHandler: Interface IReplacementHandler;
    begin
        // Checks
        CheckMappedFieldsExist(importConfigHeader);
        // Prepare Buffer
        DefineSourceRecords(bufferRef, importConfigHeader);
        // Prepare FieldMapping
        importConfigHeader.BufferTableMgt().LoadImportConfigLines(tempImportConfigLine);
        // Prepare Log
        log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", importConfigHeader);
        // Prepare Replacements
        DMTSetup.getDefaultReplacementImplementation(iReplacementHandler);
        iReplacementHandler.InitBatchProcess(importConfigHeader);
        // Process Records
        Clear(NoOfRecordsProcessedGlobal);
        while MoveNext(bufferRef, recordsToProcessLimit, NoOfRecordsProcessedGlobal) do begin
            NoOfRecordsProcessedGlobal += 1;
            ProcessSingleRecord(bufferRef, tempImportConfigLine, log, iReplacementHandler, false, Result);
        end;
    end;

    procedure MigrateSelectsFieldsFromSourceToExistingTarget()
    begin
    end;

    procedure ApplyFixValuesToTarget()
    begin
    end;

    local procedure DefineSourceRecords(var bufferRef: RecordRef; importConfigHeader: Record DMTImportConfigHeader)
    var
        noBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filter: "%1"',
                                    Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Filter: "%1"';
    begin
        Clear(bufferRef);
        importConfigHeader.BufferTableMgt().InitBufferRef(bufferRef, true);
        if not bufferRef.FindSet() then
            Error(noBufferTableRecorsInFilterErr, bufferRef.GetFilters);
    end;

    local procedure LoadImportConfigLinesForUsage(var TempImportConfigLine: Record DMTImportConfigLine temporary; importConfigHeader: Record DMTImportConfigHeader) hasLines: Boolean
    var
        ImportConfigLine: Record DMTImportConfigLine;
        TempImportConfigLine_ProcessingPlanSettings: Record DMTImportConfigLine temporary;
    begin
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        if not ImportConfigHeader.UseGenericBufferTable() then
            ImportConfigLine.SetFilter("Source Field No.", '<>0');

        if DMTImportSettings.UpdateFieldsFilter() <> '' then begin // Scope ProcessingPlan
            ImportConfigLine.SetRange("Is Key Field(Target)", true);
            // Mark Key Fields
            ImportConfigLine.FindSet();
            repeat
                ImportConfigLine.Mark(true);
            until ImportConfigLine.Next() = 0;

            // Mark Selected Fields
            ImportConfigLine.SetRange("Is Key Field(Target)");
            ImportConfigLine.SetFilter("Target Field No.", DMTImportSettings.UpdateFieldsFilter());
            ImportConfigLine.FindSet();
            repeat
                ImportConfigLine.Mark(true);
            until ImportConfigLine.Next() = 0;

            ImportConfigLine.SetRange("Target Field No.");
            ImportConfigLine.MarkedOnly(true);
        end;
        ImportConfigLine.CopyToTemp(TempImportConfigLine);
        // Apply Processing Plan Settings
        if DMTImportSettings.ProcessingPlan()."Line No." <> 0 then begin
            DMTImportSettings.ProcessingPlan().ConvertDefaultValuesViewToFieldLines(TempImportConfigLine_ProcessingPlanSettings);
            if TempImportConfigLine_ProcessingPlanSettings.FindSet() then
                repeat
                    TempImportConfigLine.Get(TempImportConfigLine_ProcessingPlanSettings.RecordId);
                    TempImportConfigLine := TempImportConfigLine_ProcessingPlanSettings;
                    TempImportConfigLine.Modify();
                until TempImportConfigLine_ProcessingPlanSettings.Next() = 0;
        end;

        // Update From Field No From Index To Gen.Buff Field No
        if ImportConfigHeader.UseGenericBufferTable() then begin
            TempImportConfigLine.Reset();
            if TempImportConfigLine.FindSet() then
                repeat
                    if TempImportConfigLine."Source Field No." < 1000 then begin
                        TempImportConfigLine."Source Field No." += 1000;
                        TempImportConfigLine.Modify();
                    end;
                until TempImportConfigLine.Next() = 0;
        end;

        OK := TempImportConfigLine.FindFirst();
        DMTImportSettings.SetImportConfigLine(TempImportConfigLine);
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

    local procedure ProcessSingleRecord(bufferRef: RecordRef; var tmpImportConfigLine: Record DMTImportConfigLine; log: Codeunit DMTLog; iReplacementHandler: Interface IReplacementHandler; UpdateExistingRecordsOnly: Boolean; var Result: Enum DMTProcessingResultType)
    var
        migrateRecord: Codeunit DMTMigrateRecord;
        targetRecordExists: Boolean;
    begin
        migrateRecord.Init(bufferRef, tmpImportConfigLine, iReplacementHandler);

        // 1. Read Key Fields
        if not ProcessKeyFields(migrateRecord) then begin
            migrateRecord.SaveErrors(log);
            Result := Enum::DMTProcessingResultType::Error;
            exit;
        end;

        // 2. Skip if no target record found for update
        targetRecordExists := migrateRecord.findExistingRecord();
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

    var
        DMTSetup: Record "DMTSetup";
        NoOfRecordsProcessedGlobal, RecordLimitGlobal : Integer;
        MigrationType: Option " ",MigrateRecordsFromSourceToTarget,MigrateSelectsFieldsFromSourceToExistingTarget,ApplyFixValuesToTarget;
}