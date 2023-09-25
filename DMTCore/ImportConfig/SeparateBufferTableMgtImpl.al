codeunit 91022 DMTSeparateBufferTableMgtImpl implements IBufferTableMgt
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
        TableMetadata: Record "Table Metadata";
        BufferTableMissingErr: Label 'Buffer Table %1 not found', Comment = 'de-DE=Eine Puffertabelle mit der ID %1 wurde nicht gefunden.';
    begin
        checkHeaderIsSet();
        if not TableMetadata.Get(ImportConfigHeaderGlobal."Buffer Table ID") then
            Error(BufferTableMissingErr, ImportConfigHeaderGlobal."Buffer Table ID");
        BufferRef.Open(ImportConfigHeaderGlobal."Buffer Table ID");
    end;

    internal procedure LoadImportConfigLines(var tempImportConfigLine: Record DMTImportConfigLine temporary) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        checkHeaderIsSet();
        importConfigHeaderGlobal.FilterRelated(importConfigLine);
        importConfigLine.SetFilter("Processing Action", '<>%1', importConfigLine."Processing Action"::Ignore);
        importConfigLine.SetFilter("Source Field No.", '<>0');
        importConfigLine.CopyToTemp(tempImportConfigLine);
        OK := tempImportConfigLine.FindFirst();
    end;

    procedure CheckBufferTableIsNotEmpty()
    var
        genBuffTable: Record DMTGenBuffTable;
        bufferTableEmptyErr: Label 'The buffer table is empty for %1:%2', Comment = 'de-DE=Die Puffertable entält keine Zeilen für %1:%2';
    begin
        checkHeaderIsSet();
        if not genBuffTable.FilterBy(ImportConfigHeaderGlobal) then
            Error(bufferTableEmptyErr, ImportConfigHeaderGlobal.TableCaption, ImportConfigHeaderGlobal.ID);
    end;

    procedure ReadBufferTableColumnCaptions(var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    var
        field: Record field;
    begin
        checkHeaderIsSet();
        ImportConfigHeaderGlobal.TestField("Target Table ID");
        field.SetRange(TableNo, ImportConfigHeaderGlobal."Target Table ID");
        field.SetFilter("No.", '<2000000000'); // exclude system fields
        field.SetRange(Enabled, true);
        field.SetRange(Class, Field.Class::Normal);
        if field.FindSet(false) then
            repeat
                BuffTableCaptions.Add(field."No.", field."Field Caption");
            until field.Next() = 0;
    end;

    procedure CountRecordsInBufferTable() NoOfRecords: Integer;
    var
        recRef: RecordRef;
    begin
        InitBufferRef(recRef);
        NoOfRecords := recRef.Count;
    end;

    internal procedure ShowBufferTable() OK: Boolean
    begin
        OK := ImportConfigHeaderGlobal.ShowTableContent(ImportConfigHeaderGlobal."Buffer Table ID");
    end;

    var
        ImportConfigHeaderGlobal: record DMTImportConfigHeader;

    procedure DeleteAllBufferData();
    var
        TableMetadata: Record "Table Metadata";
        bufferRef: RecordRef;
    begin
        if ImportConfigHeaderGlobal."Buffer Table ID" = 0 then
            exit;
        if not TableMetadata.Get(ImportConfigHeaderGlobal."Buffer Table ID") then
            exit;
        InitBufferRef(bufferRef);
        bufferRef.DeleteAll();
    end;
}