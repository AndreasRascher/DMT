page 91015 DMTDeleteDataInTargetTable
{
    Caption = 'Delete Data in Target Table', Comment = 'de-DE=Daten in Zieltabelle löschen';
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field(SourceTableView; SourceFilterGlobal)
                {
                    Caption = 'Source Table Filter', Comment = 'de-DE=Quelltabellenfilter';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        EditSourceTableView(SourceViewGlobal, SourceFilterGlobal, CurrImportConfigHeader);
                    end;
                }
                field(TargetTableFilter; TargetFilterGlobal)
                {
                    Caption = 'Target Table Filter', Comment = 'de-DE=Zieltabellenfilter';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        EditTargetTableFilter(TargetViewGlobal, TargetFilterGlobal, CurrImportConfigHeader);
                    end;
                }
                field(UseOnDeleteTriggerCtrl; UseOnDeleteTriggerGlobal) { Caption = 'Use On Delete Trigger', Comment = 'de-DE=OnDelete Trigger verwenden'; ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StartDeletingCtrl)
            {
                ApplicationArea = All;
                Caption = 'Start', Locked = true;
                Image = Start;
                trigger OnAction();
                begin
                    if (SourceViewGlobal <> '') or (TargetViewGlobal <> '') then
                        FindRecordIdsInCombinedView(SourceViewGlobal, TargetViewGlobal, CurrImportConfigHeader, UseOnDeleteTriggerGlobal)
                    else
                        DeleteFullTable(CurrImportConfigHeader, UseOnDeleteTriggerGlobal)
                end;
            }
        }
    }

    trigger OnInit()
    begin
        UseOnDeleteTriggerGlobal := true;
    end;

    procedure EditSourceTableView(var sourceView: Text; var sourceFilter: Text; ImportConfigHeader: Record DMTImportConfigHeader)
    var
        FPBuilder: Codeunit DMTFPBuilder;
        BufferRef: RecordRef;
    begin
        ImportConfigHeader.BufferTableMgt().InitBufferRef(BufferRef);
        if sourceView <> '' then
            BufferRef.SetView(sourceView);
        if not FPBuilder.RunModal(BufferRef, ImportConfigHeader) then
            exit;
        sourceView := BufferRef.GetView();
        sourceFilter := BufferRef.GetFilters;
    end;

    procedure EditTargetTableFilter(var targetView: Text; var targetFilter: Text; ImportConfigHeader: Record DMTImportConfigHeader)
    var
        FPBuilder: Codeunit DMTFPBuilder;
        RecRef: RecordRef;
    begin
        RecRef.Open(ImportConfigHeader."Target Table ID");
        if targetView <> '' then
            RecRef.SetView(targetView);
        if FPBuilder.RunModal(RecRef) then begin
            targetView := RecRef.GetView();
            targetFilter := RecRef.GetFilters;
        end;
    end;

    local procedure CreateSourceToTargetRecIDMapping(ImportConfigHeader: Record DMTImportConfigHeader; SourceView: Text; var NotTransferedRecords: List of [RecordId]) RecordMapping: Dictionary of [RecordId, RecordId]
    var
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        GenBuffTable: Record DMTGenBuffTable;
        TargetRecID: RecordId;
        SourceRef, TargetRef : RecordRef;
    begin
        Clear(NotTransferedRecords);
        Clear(RecordMapping);

        ImportConfigHeader.BufferTableMgt().LoadImportConfigLines(TempImportConfigLine);
        // FindSourceRef - GenBuffer
        if ImportConfigHeader.UseGenericBufferTable() then begin
            GenBuffTable.Reset();
            GenBuffTable.SetRange(IsCaptionLine, false);
            GenBuffTable.FilterBy(ImportConfigHeader);
            if not GenBuffTable.FindSet(false) then
                exit;
            SourceRef.GetTable(GenBuffTable);
            if SourceRef.IsEmpty then
                exit;
        end;
        // FindSourceRef - CSVBuffer
        if ImportConfigHeader.UseSeparateBufferTable() then begin
            SourceRef.Open(ImportConfigHeader."Buffer Table ID");
            if SourceRef.IsEmpty then
                exit;
        end;
        // Map RecordIDs
        if SourceView <> '' then
            SourceRef.SetView(SourceView);
        SourceRef.FindSet(false);
        repeat
            TargetRecID := GetTargetRefRecordID(ImportConfigHeader, SourceRef, TempImportConfigLine);
            if not TargetRef.Get(TargetRecID) then begin
                NotTransferedRecords.Add(TargetRecID)
            end else begin
                RecordMapping.Add(SourceRef.RecordId, TargetRecID);
            end;
        until SourceRef.Next() = 0;
    end;

    local procedure FindRecordIdsInCombinedView(sourceView: Text; targetView: Text; ImportConfigHeader: Record DMTImportConfigHeader; useOnDeleteTrigger: Boolean)
    var
        RecID: RecordId;
        TargetRef: RecordRef;
        SourceToTargetRecordMapping: Dictionary of [RecordId, RecordId];
        NotTransferedRecords: List of [RecordId];
        TargetRecordIDsToDelete: List of [RecordId];
    begin

        // Create RecordID Mapping between Buffer and Target Table
        if sourceView <> '' then begin
            SourceToTargetRecordMapping := CreateSourceToTargetRecIDMapping(ImportConfigHeader, sourceView, NotTransferedRecords);
            TargetRecordIDsToDelete := SourceToTargetRecordMapping.Values;
            // Remove TargetRecordID not in Filter
            if targetView <> '' then begin
                foreach RecID in TargetRecordIDsToDelete do begin
                    if not IsRecIDInView(RecID, targetView) then begin
                        TargetRecordIDsToDelete.Remove(RecID);
                    end;
                end;
            end;
        end else begin
            // Read all RecordIDs from Target
            TargetRef.Open(ImportConfigHeader."Target Table ID");
            TargetRef.SetView(targetView);
            if TargetRef.FindSet(false) then
                repeat
                    TargetRecordIDsToDelete.Add(TargetRef.RecordId);
                until TargetRef.Next() = 0;
        end;

        DeleteRecordsInList(ImportConfigHeader, useOnDeleteTrigger, TargetRecordIDsToDelete);
    end;

    local procedure IsRecIDInView(RecID: RecordId; TableView: Text) Result: Boolean;
    var
        RecRef: RecordRef;
    begin
        if TableView = '' then exit(true);
        RecRef.Get(RecID);
        RecRef.SetView(TableView);
        Result := RecRef.FindFirst();
    end;

    local procedure ConfirmDeletion(NoOfLinesToDelete: Integer; TableCaption: Text) OK: Boolean
    var
        DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! %1 Records in table "%2" (company "%3") will be deleted. Continue?',
                                             Comment = 'de-DE=Warnung! %1 Datensätze in Tabelle "%2" (Mandant "%3") werden gelöscht. Fortfahren?';
    begin
        OK := Confirm(StrSubstNo(DeleteAllRecordsInTargetTableWarningMsg, NoOfLinesToDelete, TableCaption, CompanyName), false);
    end;

    local procedure DeleteFullTable(ImportConfigHeader: Record DMTImportConfigHeader; useOnDeleteTrigger: Boolean)
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        Log: Codeunit DMTLog;
        RecRef: RecordRef;
        MaxSteps: Integer;
        ProcessStoppedErr: Label 'Process Stopped', Comment = 'de-DE=Vorgang abgebrochen';
    begin
        ImportConfigHeader.TestField("Target Table ID");
        RecRef.Open(ImportConfigHeader."Target Table ID");
        MaxSteps := RecRef.Count;
        if ConfirmDeletion(MaxSteps, RecRef.Caption) then begin
            if RecRef.FindSet() then begin
                Log.InitNewProcess(Enum::DMTLogUsage::"Delete Record", ImportConfigHeader);
                DeleteRecordsWithErrorLog.DialogOpen(RecRef.Caption + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
                repeat
                    if not DeleteRecordsWithErrorLog.DialogUpdate(1, Log.GetProgress(MaxSteps), 2, StrSubstNo('%1/%2', Log.GetNoOfProcessedRecords(), MaxSteps), 3, RecRef.RecordId) then begin
                        Error(ProcessStoppedErr);
                    end;
                    Commit();
                    DeleteSingeRecordWithLog(ImportConfigHeader, useOnDeleteTrigger, Log, RecRef.RecordId);
                until RecRef.Next() = 0;
                Log.CreateSummary();
                Log.ShowLogForCurrentProcess();
            end;
        end;
    end;

    local procedure DeleteRecordsInList(var ImportConfigHeader: Record DMTImportConfigHeader; useOnDeleteTrigger: Boolean; var TargetRecordIDsToDelete: List of [RecordId])
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        Log: Codeunit DMTLog;
        RecID: RecordId;
        MaxSteps: Integer;
        ProcessStoppedErr: Label 'Process Stopped', Comment = 'de-DE=Vorgang abgebrochen';
    begin
        Log.InitNewProcess(Enum::DMTLogUsage::"Delete Record", ImportConfigHeader);
        MaxSteps := TargetRecordIDsToDelete.Count;
        if ConfirmDeletion(MaxSteps, ImportConfigHeader."Target Table Caption") then begin
            DeleteRecordsWithErrorLog.DialogOpen(ImportConfigHeader."Target Table Caption" + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
            foreach RecID in TargetRecordIDsToDelete do begin
                if not DeleteRecordsWithErrorLog.DialogUpdate(1, Log.GetProgress(MaxSteps), 2, StrSubstNo('%1/%2', Log.GetNoOfProcessedRecords(), MaxSteps), 3, RecID) then begin
                    Error(ProcessStoppedErr);
                end;
                Commit();
                DeleteSingeRecordWithLog(ImportConfigHeader, useOnDeleteTrigger, Log, RecID);
            end;
            Log.CreateSummary();
            Log.ShowLogForCurrentProcess();
        end;
    end;

    local procedure DeleteSingeRecordWithLog(var ImportConfigHeader: Record DMTImportConfigHeader; useOnDeleteTrigger: Boolean; var log: Codeunit DMTLog; recID: RecordId)
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
    begin
        DeleteRecordsWithErrorLog.InitRecordToDelete(recID, useOnDeleteTrigger);
        if DeleteRecordsWithErrorLog.Run() then begin
            log.AddTargetSuccessEntry(recID, ImportConfigHeader);
            log.IncNoOfSuccessfullyProcessedRecords();
            log.IncNoOfProcessedRecords();
        end else begin
            log.AddTargetErrorByIDEntry(recID, ImportConfigHeader, log.CreateErrorItem());
            log.IncNoOfRecordsWithErrors();
            ClearLastError();
        end;
    end;

    procedure SetImportConfigHeaderID(ImportConfigHeader: Record DMTImportConfigHeader)
    begin
        CurrImportConfigHeader := ImportConfigHeader;
    end;

    procedure GetTargetRefRecordID(importConfigHeader: Record DMTImportConfigHeader; SourceRef: RecordRef; var TmpImportConfigLine: Record DMTImportConfigLine temporary) TargetRecID: RecordId
    var
        Migrate: Codeunit DMTMigrate;
        RefHelper: Codeunit DMTRefHelper;
        TmpTargetRef: RecordRef;
        ToFieldRef: FieldRef;
    begin
        TmpTargetRef.Open(importConfigHeader."Target Table ID", true);

        TmpImportConfigLine.Reset();
        TmpImportConfigLine.SetRange("Is Key Field(Target)", true);
        TmpImportConfigLine.FindSet();
        repeat

            case TmpImportConfigLine."Processing Action" of
                TmpImportConfigLine."Processing Action"::Ignore:
                    ;
                TmpImportConfigLine."Processing Action"::Transfer:
                    Migrate.AssignFieldWithoutValidate(TmpTargetRef, SourceRef, TmpImportConfigLine, false);
                TmpImportConfigLine."Processing Action"::FixedValue:
                    begin
                        ToFieldRef := TmpTargetRef.Field(TmpImportConfigLine."Target Field No.");
                        RefHelper.AssignFixedValueToFieldRef(ToFieldRef, TmpImportConfigLine."Fixed Value");
                    end;
            end;
        until TmpImportConfigLine.Next() = 0;
        TargetRecID := TmpTargetRef.RecordId;
    end;


    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        UseOnDeleteTriggerGlobal: Boolean;
        SourceViewGlobal, TargetViewGlobal, SourceFilterGlobal, TargetFilterGlobal : Text;
}