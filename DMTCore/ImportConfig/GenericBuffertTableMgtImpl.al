codeunit 91019 DMTGenericBuffertTableMgtImpl implements IBufferTableMgt
{
    procedure setImportConfigHeader(var ImportConfigHeader: record DMTImportConfigHeader);
    begin
        ImportConfigHeaderGlobal.Copy(ImportConfigHeader);
    end;

    procedure checkHeaderIsSet();
    begin
        ImportConfigHeaderGlobal.TestField(ID);
    end;

    procedure InitBufferRef(var BufferRef: RecordRef);
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        checkHeaderIsSet();
        // GenBuffTable.SetRange(IsCaptionLine, false);
        GenBuffTable.FilterBy(ImportConfigHeaderGlobal);
        BufferRef.GetTable(GenBuffTable);
    end;

    internal procedure LoadImportConfigLines(var tempImportConfigLine: Record DMTImportConfigLine temporary) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        checkHeaderIsSet();
        ImportConfigHeaderGlobal.FilterRelated(importConfigLine);
        importConfigLine.SetFilter("Processing Action", '<>%1', importConfigLine."Processing Action"::Ignore);
        importConfigLine.CopyToTemp(tempImportConfigLine);
        OK := tempImportConfigLine.FindFirst();
    end;

    procedure CheckBufferTableIsNotEmpty()
    var
        genBuffTable: Record DMTGenBuffTable;
        bufferTableEmptyErr: Label 'The buffer table is empty. Filename: "%1"', Comment = 'de-DE=Die Puffertable entält keine Zeilen. Dateiname: "%1"';
        hasCaptionLine: Boolean;
    begin
        checkHeaderIsSet();
        hasCaptionLine := genBuffTable.FilterBy(ImportConfigHeaderGlobal);
        genBuffTable.SetRange(IsCaptionLine, false);
        if genBuffTable.IsEmpty then
            Error(bufferTableEmptyErr, ImportConfigHeaderGlobal."Source File Name");
    end;

    procedure ReadBufferTableColumnCaptions(var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        checkHeaderIsSet();
        OK := genBuffTable.GetColCaptionForImportedFile(ImportConfigHeaderGlobal, BuffTableCaptions);
    end;

    var
        ImportConfigHeaderGlobal: record DMTImportConfigHeader;

    procedure CountRecordsInBufferTable() NoOfRecords: Integer;
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        checkHeaderIsSet();
        GenBuffTable.Reset();
        GenBuffTable.FilterBy(ImportConfigHeaderGlobal);
        GenBuffTable.SetRange(IsCaptionLine, false); // don't count header line
        NoOfRecords := GenBuffTable.Count;
    end;

    internal procedure ShowBufferTable() OK: Boolean
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        OK := genBuffTable.FilterBy(ImportConfigHeaderGlobal);
        if OK then
            genBuffTable.ShowBufferTable(ImportConfigHeaderGlobal);
    end;

    internal procedure DeleteAllBufferData()
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        if ImportConfigHeaderGlobal."Source File ID" = 0 then
            exit;
        if genBuffTable.FilterBy(ImportConfigHeaderGlobal) then
            genBuffTable.DeleteAll();
    end;

    internal procedure updateImportToTargetPercentage()
    var
        genBuffTable: Record DMTGenBuffTable;
        recRef: RecordRef;
        noOfRecords, noOfRecordsMigrated : Integer;
        IsImported: Boolean;
    begin
        if not genBuffTable.FilterBy(ImportConfigHeaderGlobal) then
            exit;

        ImportConfigHeaderGlobal.get(ImportConfigHeaderGlobal.RecordId); // update
        genBuffTable.SetRange(IsCaptionLine, false);
        if genBuffTable.IsEmpty then begin
            Clear(ImportConfigHeaderGlobal.ImportToTargetPercentage);
            Clear(ImportConfigHeaderGlobal.ImportToTargetPercentage);
            ImportConfigHeaderGlobal.Modify();
            exit;
        end;

        genBuffTable.SetLoadFields("Entry No.", "Import from Filename", Imported, "RecId (Imported)");
        genBuffTable.FindSet();
        repeat
            noOfRecords += 1;
            IsImported := recRef.Get(genBuffTable."RecId (Imported)");
            if IsImported then
                noOfRecordsMigrated += 1;

            if genBuffTable.Imported <> IsImported then begin
                genBuffTable.Imported := IsImported;
                if not IsImported then
                    Clear(genBuffTable."RecId (Imported)");
                genBuffTable.Modify();
            end;
        until genBuffTable.Next() = 0;


        ImportConfigHeaderGlobal.ImportToTargetPercentage := (noOfRecordsMigrated / noOfRecords) * 100;
        case ImportConfigHeaderGlobal.ImportToTargetPercentage of
            100:
                ImportConfigHeaderGlobal.ImportToTargetPercentageStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            0:
                ImportConfigHeaderGlobal.ImportToTargetPercentageStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            else
                ImportConfigHeaderGlobal.ImportToTargetPercentageStyle := Format(Enum::DMTFieldStyle::Yellow);
        end;
        ImportConfigHeaderGlobal.Modify();
    end;

    procedure FindDMTFieldNosInBufferTable(var TargetRecIDFieldNo: Integer; var TargetRecIsImportedFieldNo: Integer) Found: Boolean
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        TargetRecIDFieldNo := genBuffTable.FieldNo("RecId (Imported)");
        TargetRecIsImportedFieldNo := genBuffTable.FieldNo(Imported);
        Found := (TargetRecIDFieldNo <> 0) and (TargetRecIsImportedFieldNo <> 0);
    end;

    procedure SetDMTImportFields(var SourceRef: RecordRef; CurrTargetRecIDText: Text)
    var
        genBuffTable: Record DMTGenBuffTable;
        TargetRecID: RecordId;
        targetRef: RecordRef;
    begin
        checkHeaderIsSet();
        SourceRef.SetTable(genBuffTable);
        if Evaluate(TargetRecID, CurrTargetRecIDText) then begin
            genBuffTable."RecId (Imported)" := TargetRecID;
            genBuffTable.Imported := targetRef.Get(TargetRecID);
        end else begin
            genBuffTable."RecId (Imported)" := TargetRecID;
            genBuffTable.Imported := false;
        end;
        genBuffTable.Modify();
    end;

}