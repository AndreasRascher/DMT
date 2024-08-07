codeunit 91015 DMTProcessingPlanMgt
{
    internal procedure ImportWithProcessingPlanParams(processingPlan: Record DMTProcessingPlan) Success: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        logEntry: Record DMTLogEntry;
        Migrate: Codeunit DMTMigrate;
        bufferRef: RecordRef;
        currView: Text;
        lastLogEntryNoAfterProcessing, lastLogEntryNoBeforeProcessing : Integer;
        bufferTableEmptyErr: Label 'The buffer table is empty. Filename: "%1"', Comment = 'de-DE=Die Puffertable entält keine Zeilen. Dateiname: "%1"';
        noBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filename: "%1"\ Filter: "%2"', Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Dateiname: "%1"\ Filter: "%2"';
    begin
        Success := true;
        // Pre-Checks
        if processingPlan.Type in [processingPlan.Type::"Buffer + Target", processingPlan.Type::"Import To Target"] then begin
            // is buffer table empty
            importConfigHeader.Get(processingPlan.ID);
            if importConfigHeader.BufferTableMgt().IsBufferTableEmpty() then begin
                Message(bufferTableEmptyErr, importConfigHeader."Source File Name");
                exit(false);
            end;
            // buffer has no lines in filter
            importConfigHeader.BufferTableMgt().InitBufferRef(bufferRef, true);
            currView := processingPlan.ReadSourceTableView();
            if currView <> '' then
                BufferRef.SetView(currView);
            if not bufferRef.FindSet() then begin
                Message(noBufferTableRecorsInFilterErr, importConfigHeader."Source File Name", bufferRef.GetFilters);
                exit(false);
            end;
            // read last log entry
            logEntry.Reset();
            if logEntry.FilterFor(importConfigHeader) then
                if logEntry.FindLast() then
                    lastLogEntryNoBeforeProcessing := logEntry."Entry No.";
        end;

        // Migration
        Migrate.BufferFor(processingPlan);

        // Post-Checks
        if processingPlan.Type in [processingPlan.Type::"Buffer + Target", processingPlan.Type::"Import To Target"] then begin
            // Is migration without errors
            logEntry.Reset();
            logEntry.SetRange("Entry Type", logEntry."Entry Type"::Error);
            if logEntry.FilterFor(importConfigHeader) then
                if logEntry.FindLast() then
                    lastLogEntryNoAfterProcessing := logEntry."Entry No.";
            if lastLogEntryNoAfterProcessing > lastLogEntryNoBeforeProcessing then
                Success := false;
        end;
    end;

    internal procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader; HideDialog: Boolean) Success: Boolean
    var
        SourceFileImport: Interface ISourceFileImport;
    begin
        Success := true;
        SourceFileImport := ImportConfigHeader.GetDataLayout().SourceFileFormat;
        SourceFileImport.ImportToBufferTable(ImportConfigHeader);
    end;
}