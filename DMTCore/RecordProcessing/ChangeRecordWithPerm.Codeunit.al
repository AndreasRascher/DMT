codeunit 91011 DMTChangeRecordWithPerm
{
    Permissions = tabledata "Dimension Set Entry" = rimd,
                  tabledata "Dimension Set Tree Node" = rimd;

    procedure DeleteRecordsInTargetTable(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        DMTDeleteDatainTargetTable: Page DMTDeleteDataInTargetTable;
    begin
        DMTDeleteDatainTargetTable.SetImportConfigHeaderID(ImportConfigHeader);
        DMTDeleteDatainTargetTable.Run();
    end;

    procedure InsertOrOverwriteRecFromTmp(var TmpTargetRef: RecordRef; var CurrTargetRecIDText: Text; InsertTrue: Boolean; var triggerLog: Codeunit DMTTriggerLog) InsertOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
        RecID, xRecID : RecordID;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);

        if TargetRef2.Get(TargetRef.RecordId) then begin
            triggerLog.setBeforeState(TargetRef);
            InsertOK := TargetRef.Modify(InsertTrue);
            triggerLog.logTriggerChanges(TargetRef, Enum::DMTRecOperationType::ModifyRecord);
        end else begin
            xRecID := TargetRef.RecordId;
            triggerLog.setBeforeState(TargetRef);
            InsertOK := TargetRef.Insert(InsertTrue);
            triggerLog.logTriggerChanges(TargetRef, Enum::DMTRecOperationType::InsertRecord);
            RecID := TargetRef.RecordId;
            if xRecID <> RecID then
                CurrTargetRecIDText := Format(RecID);  // update if key is changed after insert
        end;
    end;

    procedure ModifyRecFromTmp(var TmpTargetRef: RecordRef; UseTrigger: Boolean; var triggerLog: Codeunit DMTTriggerLog) ModifyOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);
        triggerLog.setBeforeState(TargetRef);
        ModifyOK := TargetRef.Modify(UseTrigger);
        triggerLog.logTriggerChanges(TargetRef, Enum::DMTRecOperationType::ModifyRecord);
    end;
}