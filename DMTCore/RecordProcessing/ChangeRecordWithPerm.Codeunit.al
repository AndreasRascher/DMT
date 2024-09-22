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

    procedure InsertOrOverwriteRecFromTmp(var TmpTargetRef: RecordRef; var CurrTargetRecIDText: Text; UseTrigger: Boolean) InsertOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
        RecID, xRecID : RecordID;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);

        if TargetRef2.Get(TargetRef.RecordId) then begin

            if IsTriggerLogInterfaceInitializedGlobal then
                TriggerLogGlobal.InitBeforeModify(TargetRef, UseTrigger);

            InsertOK := TargetRef.Modify(UseTrigger);

            if IsTriggerLogInterfaceInitializedGlobal then
                TriggerLogGlobal.CheckAfterOnModiy(TargetRef);

        end else begin

            xRecID := TargetRef.RecordId;

            if IsTriggerLogInterfaceInitializedGlobal then
                TriggerLogGlobal.InitBeforeInsert(TargetRef, UseTrigger);

            InsertOK := TargetRef.Insert(UseTrigger);

            if IsTriggerLogInterfaceInitializedGlobal then
                TriggerLogGlobal.CheckAfterOnInsert(TargetRef);

            RecID := TargetRef.RecordId;
            if xRecID <> RecID then
                CurrTargetRecIDText := Format(RecID);  // update if key is changed after insert
        end;
    end;

    procedure ModifyRecFromTmp(var TmpTargetRef: RecordRef; UseTrigger: Boolean) ModifyOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);
        if IsTriggerLogInterfaceInitializedGlobal then
            TriggerLogGlobal.InitBeforeModify(TargetRef, UseTrigger);
        ModifyOK := TargetRef.Modify(UseTrigger);
        if IsTriggerLogInterfaceInitializedGlobal then
            TriggerLogGlobal.CheckAfterOnModiy(TargetRef);
    end;

    internal procedure SetTriggerLog(iTriggerLogNew: Interface ITriggerLog)
    begin
        TriggerLogGlobal := iTriggerLogNew;
        IsTriggerLogInterfaceInitializedGlobal := true;
    end;

    var
        IsTriggerLogInterfaceInitializedGlobal: Boolean;
        TriggerLogGlobal: Interface ITriggerLog;
}