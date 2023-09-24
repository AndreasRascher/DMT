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
        GenBuffTable.FilterGroup(2);
        GenBuffTable.SetRange(IsCaptionLine, false);
        GenBuffTable.FilterBy(ImportConfigHeaderGlobal);
        GenBuffTable.FilterGroup(0);
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
        bufferTableEmptyErr: Label 'The buffer table is empty for %1:%2', Comment = 'de-DE=Die Puffertable entält keine Zeilen für %1:%2';
    begin
        checkHeaderIsSet();
        if not genBuffTable.FilterBy(ImportConfigHeaderGlobal) then
            Error(bufferTableEmptyErr, ImportConfigHeaderGlobal.TableCaption, ImportConfigHeaderGlobal.ID);
    end;

    procedure ReadBufferTableColumnCaptions(var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        checkHeaderIsSet();
        OK := genBuffTable.GetColCaptionForImportedFile(ImportConfigHeaderGlobal, BuffTableCaptions);
    end;

    procedure InitKeyFieldFilter(var BufferRef: RecordRef) FilterFields: Dictionary of [Integer, Text];
    begin
        checkHeaderIsSet();
    end;

    var
        ImportConfigHeaderGlobal: record DMTImportConfigHeader;
}