table 91005 DMTDataLayoutLine
{
    Caption = 'Data Layout Line', Comment = 'de-DE=Datenlayoutzeile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File Layout ID"; Integer) { Caption = 'File ID'; }
        field(2; "Column No."; Text[50]) { Caption = 'Column No.', Comment = 'de-DE=Spaltennr.'; }
        field(10; ColumnName; Text[50]) { Caption = 'Column Name'; }
        field(11; DataType; Option)
        {
            Caption = 'Data Type';
            OptionMembers = Text,Date,Time,DateTime,Decimal,Boolean,Integer,GUID,BLOB;
        }
        field(20; NAVDataType; Option)
        {
            Caption = 'Data Type';
            OptionMembers = TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime;
        }
        field(21; NAVLen; Integer) { Caption = 'Len', Locked = true; }
        field(22; NAVClass; Option)
        {
            Caption = 'Class', locked = true;
            OptionMembers = Normal,FlowField,FlowFilter;
            OptionCaptionML = ENU = 'Normal,FlowField,FlowFilter', DEU = 'Normal,FlowField,FlowFilter';
        }
        field(23; NAVEnabled; Boolean) { Caption = 'Enabled', Locked = true; }
        field(24; "NAVFieldCaption"; Text[80]) { Caption = 'Field Caption', Locked = true; }

    }

    keys
    {
        key(PK; "File Layout ID", "Column No.") { Clustered = true; }
    }
}