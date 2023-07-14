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

    procedure InsertOrOverwriteRecFromTmp(var TmpTargetRef: RecordRef; InsertTrue: Boolean) InsertOK: Boolean
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        RefHelper.CopyRecordRef(TmpTargetRef, TargetRef);

        if TargetRef2.Get(TargetRef.RecordId) then begin
            InsertOK := TargetRef.Modify(InsertTrue);
        end else begin
            InsertOK := TargetRef.Insert(InsertTrue);
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