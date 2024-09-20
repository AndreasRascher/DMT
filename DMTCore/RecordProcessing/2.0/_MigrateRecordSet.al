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
        log: Codeunit "DMTLog";
        bufferRef: recordRef;
        tmpImportConfigLine: Record DMTImportConfigLine temporary;
        iReplacementHandler: Interface IReplacementHandler;
    begin
        // Checks
        CheckMappedFieldsExist(importConfigHeader);
        // Prepare Buffer
        DefineSourceRecords(bufferRef, importConfigHeader);
        // Prepare FieldMapping
        importConfigHeader.BufferTableMgt().LoadImportConfigLines(tmpImportConfigLine);
        // Prepare Log
        log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", importConfigHeader);
        // Prepare Replacements
        DMTSetup.getDefaultReplacementImplementation(iReplacementHandler);
        iReplacementHandler.InitBatchProcess(importConfigHeader);
        // Process Records
        Clear(NoOfRecordsProcessedGlobal);
        while MoveNext(bufferRef, recordsToProcessLimit, NoOfRecordsProcessedGlobal) do begin
            NoOfRecordsProcessedGlobal += 1;
            ProcessSingleRecord(bufferRef, tmpImportConfigLine, log, iReplacementHandler);
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

    local procedure ProcessSingleRecord(bufferRef: RecordRef; var tmpImportConfigLine: Record DMTImportConfigLine; log: Codeunit DMTLog; iReplacementHandler: Interface IReplacementHandler)
    var
        migrateRecord: Codeunit DMTMigrateRecord;
    begin
        migrateRecord.Init(bufferRef, tmpImportConfigLine, iReplacementHandler);
        ProcessKeyFields(migrateRecord, bufferRef, tmpImportConfigLine);
        if not migrateRecord.HasErrors then
            if not migrateRecord.findExistingRecord() then begin
                ProcessNonKeyFields(migrateRecord);
                if not migrateRecord.HasErrors then
                    InsertRecord(migrateRecord);
            end;

    end;

    local procedure ProcessKeyFields(var migrateRecord: Codeunit DMTMigrateRecord; bufferRef: RecordRef; var tmpImportConfigLine: Record DMTImportConfigLine)
    begin
        migrateRecord.SetRunMode_ProcessKeyFields(tmpImportConfigLine);

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
}