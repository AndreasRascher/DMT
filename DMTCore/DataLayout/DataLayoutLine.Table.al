table 91005 DMTDataLayoutLine
{
    Caption = 'Data Layout Line', Comment = 'de-DE=Datenlayoutzeile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Layout ID"; Integer) { Caption = 'File ID'; }
        field(2; "Column No."; Integer) { Caption = 'Column No.', Comment = 'de-DE=Spaltennr.'; }
        field(10; ColumnName; Text[50]) { Caption = 'Column Name'; }
        field(11; DataType; Option)
        {
            Caption = 'Data Type';
            OptionMembers = Text,Date,Time,DateTime,Decimal,Boolean,Integer,GUID,BLOB;
        }
        #region NAVFieldInformation
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
        field(25; "NAV Table Caption"; Text[80]) { Caption = 'Table Caption', Locked = true; }
        field(26; "NAV Primary Key"; Text[250]) { Caption = 'Primary Key', Locked = true; }
        field(27; NAVOptionString; Text[2048]) { Caption = 'OptionString', Locked = true; }
        field(28; NAVOptionCaption; Text[2048]) { Caption = 'OptionCaption', Locked = true; }
        field(29; "NAVNo. of Records"; Integer) { Caption = 'No. of Records', Locked = true; }
        #endregion NAVFieldInformation
    }

    keys
    {
        key(PK; "Data Layout ID", "Column No.") { Clustered = true; }
    }
}