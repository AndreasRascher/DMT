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
        field(11; SourceFileFormat; enum DMTSourceFileFormat) { Caption = 'Source File Format', Comment = 'de-DE=Dateiformat'; }
        field(100; CSVFieldSeparator; Text[10]) { Caption = 'Field Separator', Comment = 'de-DE=Feldtrenner'; }
        field(101; CSVLineSeparator; Text[10]) { Caption = 'Line Separator', Comment = 'de-DE=Zeilentrenner'; }
        field(200; NAVTableID; Integer) { Caption = 'NAV TableID', Comment = 'de-DE=NAV Tabellen ID'; }
        field(50000; "NAVTableCaption"; Text[80]) { Caption = 'Table Caption', Locked = true; }
        field(50001; "NAVPrimaryKey"; Text[250]) { Caption = 'Primary Key', Locked = true; }
        field(50004; "NAVNoOfRecords"; Integer) { Caption = 'No. of Records', Locked = true; }
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
        if ID = 0 then
            ID := GetNextID();
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