table 91002 DMTDataLayout
{
    Caption = 'Data Layout', Comment = 'de-DE=Datenlayout';
    DataClassification = CustomerContent;
    LookupPageId = DMTDataLayouts;
    DrillDownPageId = DMTDataLayouts;

    fields
    {
        field(1; ID; Integer) { Caption = 'ID', Locked = true; }
        field(10; Name; Text[250]) { Caption = 'Name', Comment = 'de-DE=Name'; }
        field(11; SourceFileFormat; Enum DMTSourceFileFormat) { Caption = 'Source File Format', Comment = 'de-DE=Dateiformat'; }
        field(100; CSVFieldSeparator; Text[10]) { Caption = 'Field Separator', Comment = 'de-DE=Feldtrenner'; }
        field(101; CSVLineSeparator; Text[10]) { Caption = 'Line Separator', Comment = 'de-DE=Zeilentrenner'; }
        field(200; NAVTableID; Integer) { Caption = 'NAV TableID', Comment = 'de-DE=Tabellen ID'; Editable = false; }
        field(300; "XLSHeadingRowNo"; Integer) { Caption = 'Heading Row no.', Comment = 'de-DE=Überschrift Zeilennr.'; InitValue = 1; }
        field(301; "XLSDefaultSheetName"; Text[250])
        {
            Caption = 'Default Excel Sheet', Comment = 'de-DE=Standard Excel Blatt';
            Editable = false;
        }
        field(50000; NAVTableCaption; Text[80]) { Caption = 'Table Caption', Comment = 'de-DE=Tabellenbezeichnung'; Editable = false; }
        field(50001; NAVPrimaryKey; Text[250]) { Caption = 'Primary Key', Comment = 'de-DE=Primärschlüssel Felder'; Editable = false; }
        field(50004; NAVNoOfRecords; Integer) { Caption = 'No. of Records', Comment = 'de-DE=Anz. Datensätze'; Editable = false; }
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }
    trigger OnDelete()
    var
        DataLayoutLine: Record DMTDataLayoutLine;
    begin
        if filterDataLayoutLines(DataLayoutLine) then
            DataLayoutLine.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if Rec.ID = 0 then
            Rec.ID := Rec.GetNextID();
    end;

    procedure filterDataLayoutLines(var DataLayoutLine: Record DMTDataLayoutLine) HasLinesInFilter: Boolean
    begin
        DataLayoutLine.SetRange("Data Layout ID", Rec.ID);
        HasLinesInFilter := not DataLayoutLine.IsEmpty;
    end;

    procedure GetNextID() NextID: Integer
    var
        DataLayout: Record DMTDataLayout;
    begin
        NextID := 1;
        if DataLayout.FindLast() then
            NextID += DataLayout.ID;
    end;

    procedure LookupDefaultExcelSheetName()
    var
        excelMgt: Codeunit DMTExcelMgt;
    begin
        excelMgt.InitFileStreamFromUpload();
        Rec.XLSDefaultSheetName := CopyStr(excelMgt.SelectSheet(), 1, MaxStrLen(rec.XLSDefaultSheetName));
    end;
}