codeunit 91015 DMTProcessingPlanMgt
{
    internal procedure ImportWithProcessingPlanParams(processingPlan: Record DMTProcessingPlan) Success: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        logEntry: Record DMTLogEntry;
        migrateRecordSet: Codeunit DMTMigrateRecordSet;
        bufferRef: RecordRef;
        currView: Text;
        lastLogEntryNoAfterProcessing, lastLogEntryNoBeforeProcessing : Integer;
        bufferTableEmptyErr: Label 'The buffer table is empty. Filename: "%1"', Comment = 'de-DE=Die Puffertable entält keine Zeilen. Dateiname: "%1"';
        noBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filename: "%1"\ Filter: "%2"', Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Dateiname: "%1"\ Filter: "%2"';
        noDefaultValuesSetErr: Label 'No default values has been set. \Line No: %1\Description: %2', Comment = 'de-DE=Es wurden keine Vorgabewerte definiert. \Zeilennr: %1 \Beschreibung: %2';
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
                bufferRef.SetView(currView);
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

        if processingPlan.Type = processingPlan.Type::"Enter default values in target table" then
            if processingPlan.ReadDefaultValuesView() = '' then begin
                Message(noDefaultValuesSetErr, processingPlan."Line No.", processingPlan.Description);
                exit(false);
            end;

        // Migration
        migrateRecordSet.Start(processingPlan);

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

    #region Journal
    procedure OpenJnl(CurrentJnlBatchName: Code[20]; var processingPlan: Record DMTProcessingPlan)
    begin
        processingPlan.FilterGroup := 2;
        processingPlan.SetRange("Journal Batch Name", CurrentJnlBatchName);
        processingPlan.FilterGroup := 0;
    end;

    procedure CheckName(var CurrentJnlBatchName: Code[20])
    var
        processingPlanBatch: Record DMTProcessingPlanBatch;
        standardLbl: Label 'Standard', Comment = 'de-DE=Standard';
        standardDescrLbl: Label 'Standard journal batch', Comment = 'de-DE=Standard Buch.-Blatt';
    begin
        if (CurrentJnlBatchName <> '') then begin
            processingPlanBatch.Get(CurrentJnlBatchName);
        end else begin
            if not processingPlanBatch.FindFirst() then begin
                processingPlanBatch.Init();
                processingPlanBatch.Name := standardLbl;
                processingPlanBatch.Description := standardDescrLbl;
                processingPlanBatch.Insert(true);
                Commit();
            end;
            CurrentJnlBatchName := processingPlanBatch.Name;
        end;
    end;

    procedure SetName(CurrentJnlBatchName: Code[20]; var processingPlan: Record DMTProcessingPlan)
    begin
        processingPlan.FilterGroup := 2;
        processingPlan.SetRange("Journal Batch Name", CurrentJnlBatchName);
        processingPlan.FilterGroup := 0;
        if processingPlan.Find('-') then;
    end;

    procedure LookupName(var CurrentJnlBatchName: Code[20]; var processingPlan: Record DMTProcessingPlan): Boolean
    var
        processingPlanBatch: Record DMTProcessingPlanBatch;
    begin
        Commit();
        processingPlanBatch.Name := processingPlan.GetRangeMax("Journal Batch Name");
        if Page.RunModal(0, processingPlanBatch) = Action::LookupOK then begin
            CurrentJnlBatchName := processingPlanBatch.Name;
            SetName(CurrentJnlBatchName, processingPlan);
        end;
    end;
    #endregion Journal
}