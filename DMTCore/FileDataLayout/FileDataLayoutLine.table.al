table 90003 DMTFileDataLayoutLine
{
    Caption = 'File Data Layout Line', Comment = 'de-DE=Dateilayoutzeile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File Layout ID"; Integer) { Caption = 'File ID'; }
        field(2; "Line No."; Integer) { Caption = 'Line Number'; }
        field(3; ColumnName; Text[50]) { Caption = 'Column Name'; }
        field(4; ColumnWidth; Integer) { Caption = 'Column Width'; }
        field(5; DataType; Text[30]) { Caption = 'Data Type'; }
    }

    keys
    {
        key(PK; "File Layout ID", "Line No.") { Clustered = true; }
    }
}