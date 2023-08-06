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
        field(12; "Has Heading Row"; Boolean) { Caption = 'Has Heading Row', Comment = 'de-DE=Enthält Überschriftenzeile'; }
        field(13; "HeadingRowNo"; Integer) { Caption = 'Heading Row no.', Comment = 'de-DE=Überschrift Zeilennr.'; }
        field(100; CSVFieldSeparator; Text[50]) { Caption = 'Field Separator', Comment = 'de-DE=Feldtrenner'; InitValue = ';'; }
        field(101; CSVLineSeparator; Text[50]) { Caption = 'Line Separator', Comment = 'de-DE=Zeilentrenner'; InitValue = '<NewLine>'; }
        field(102; CSVFieldDelimiter; Text[50]) { Caption = 'Field Delimiter', Comment = 'de-DE=Feldbegrenzungszeichen'; InitValue = '"'; }
        field(103; CSVTextEncoding; Option) { Caption = 'Text Encoding', Comment = 'de-DE=Text Encoding'; OptionMembers = MSDos,UTF8,UTF16,Windows; }
        field(200; NAVTableID; Integer) { Caption = 'NAV TableID', Comment = 'de-DE=Tabellen ID'; Editable = false; }
        field(302; "XLSDefaultSheetName"; Text[250])
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
}