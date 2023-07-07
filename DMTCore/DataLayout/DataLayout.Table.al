table 90002 DMTDataLayout
{
    Caption = 'Data Layout', Comment = 'de-DE=Datenlayout';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer) { Caption = 'ID', Locked = true; }
        field(10; Name; Text[250]) { Caption = 'Name', Comment = 'de-DE=Name'; }
        field(11; SourceFileFormat; enum DMTSourceFileFormat) { Caption = 'Source File Format', Comment = 'de-DE=Dateiformat'; }
        field(100; CSVFieldSeparator; Text[10]) { Caption = 'Field Separator', Comment = 'de-DE=Feldtrenner'; }
        field(101; CSVLineSeparator; Text[10]) { Caption = 'Line Separator', Comment = 'de-DE=Zeilentrenner'; }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        DataLayoutLine: Record DMTDataLayoutLine;
    begin
        if filterDataLayoutLines(DataLayoutLine) then
            DataLayoutLine.DeleteAll();
    end;

    procedure filterDataLayoutLines(var DataLayoutLine: Record DMTDataLayoutLine) HasLinesInFilter: Boolean
    begin
        DataLayoutLine.SetRange("File Layout ID", Rec.ID);
        HasLinesInFilter := not DataLayoutLine.IsEmpty;
    end;
}