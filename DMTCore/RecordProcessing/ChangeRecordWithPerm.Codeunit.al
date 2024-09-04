codeunit 50051 DMTChangeRecordWithPerm
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

    procedure InsertOrOverwriteRecFromTmp(var TmpTargetRef: RecordRef; var CurrTargetRecIDText: Text; UseTrigger: Boolean; IsTriggerLogInterfaceInitialized: Boolean; var triggerLog: Interface ITriggerLog) InsertOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
        RecID, xRecID : RecordID;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);

        if TargetRef2.Get(TargetRef.RecordId) then begin

            if IsTriggerLogInterfaceInitialized then
                triggerLog.InitBeforeModify(TargetRef, UseTrigger);

            InsertOK := TargetRef.Modify(UseTrigger);

            if IsTriggerLogInterfaceInitialized then
                triggerLog.CheckAfterOnModiy(TargetRef);

        end else begin

            xRecID := TargetRef.RecordId;

            if IsTriggerLogInterfaceInitialized then
                triggerLog.InitBeforeInsert(TargetRef, UseTrigger);

            InsertOK := TargetRef.Insert(UseTrigger);

            if IsTriggerLogInterfaceInitialized then
                triggerLog.CheckAfterOnInsert(TargetRef);

            RecID := TargetRef.RecordId;
            if xRecID <> RecID then
                CurrTargetRecIDText := Format(RecID);  // update if key is changed after insert
        end;
    end;

    procedure ModifyRecFromTmp(var TmpTargetRef: RecordRef; UseTrigger: Boolean; IsTriggerLogInterfaceInitialized: Boolean; triggerLog: Interface ITriggerLog) ModifyOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);
        triggerLog.InitBeforeModify(TargetRef, UseTrigger);
        ModifyOK := TargetRef.Modify(UseTrigger);
        triggerLog.CheckAfterOnModiy(TargetRef);
    end;
}