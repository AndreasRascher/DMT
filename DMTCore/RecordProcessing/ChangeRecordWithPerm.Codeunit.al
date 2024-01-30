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

    procedure InsertOrOverwriteRecFromTmp(var TmpTargetRef: RecordRef; var CurrTargetRecIDText: Text; InsertTrue: Boolean) InsertOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
        RecID, xRecID : RecordID;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);

        if TargetRef2.Get(TargetRef.RecordId) then begin
            InsertOK := TargetRef.Modify(InsertTrue);
        end else begin
            xRecID := TargetRef.RecordId;
            InsertOK := TargetRef.Insert(InsertTrue);
            RecID := TargetRef.RecordId;
            if xRecID <> RecID then
                CurrTargetRecIDText := Format(RecID);  // update if key is changed after insert
        end;
    end;

    procedure ModifyRecFromTmp(var TmpTargetRef: RecordRef; UseTrigger: Boolean) InsertOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);
        InsertOK := TargetRef.Modify(UseTrigger);
    end;
}