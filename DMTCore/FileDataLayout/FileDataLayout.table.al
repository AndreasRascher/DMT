table 90002 DMTFileDataLayout
{
    Caption = 'File Data Layout', Comment = 'de-DE=Dateilayout';
    DataClassification = CustomerContent;

    fields
    {
        field(1; SourceFileFormat; enum DMTSourceFileFormat) { Caption = 'Source File Format', Comment = 'de-DE=Dateiformat'; }
        field(2; ID; Integer) { Caption = 'ID', Locked = true; }
        field(10; CSVFieldSeparator; Text[10]) { Caption = 'Field Separator', Comment = 'de-DE=Feldtrenner'; }
        field(11; CSVLineSeparator; Text[10]) { Caption = 'Line Separator', Comment = 'de-DE=Zeilentrenner'; }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}