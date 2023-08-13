tableextension 90000 DMTDataLayoutLine extends DMTDataLayoutLine
{
    fields
    {
        #region NAVFieldInformation
        field(90000; NAVDataType; Option)
        {
            Caption = 'Data Type', Comment = 'de-DE=NAV Datentyp';
            OptionMembers = TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime;
        }
        field(90001; NAVLen; Integer) { Caption = 'Len', Comment = 'de-DE=NAV Len', Locked = true; }
        field(90002; NAVClass; Option)
        {
            Caption = 'Class', Locked = true;
            OptionMembers = Normal,FlowField,FlowFilter;
            OptionCaptionML = ENU = 'Normal,FlowField,FlowFilter', DEU = 'Normal,FlowField,FlowFilter';
        }
        field(90003; NAVEnabled; Boolean) { Caption = 'Enabled', Locked = true; }
        field(90004; NAVFieldCaption; Text[80]) { Caption = 'Field Caption', Locked = true; }
        field(90005; "NAV Table Caption"; Text[80]) { Caption = 'Table Caption', Locked = true; }
        field(90006; "NAV Primary Key"; Text[250]) { Caption = 'Primary Key', Locked = true; }
        field(90007; NAVOptionString; Text[2048]) { Caption = 'OptionString', Locked = true; }
        field(90008; NAVOptionCaption; Text[2048]) { Caption = 'OptionCaption', Locked = true; }
        field(90009; "NAVNo. of Records"; Integer) { Caption = 'No. of Records', Locked = true; }
        #endregion NAVFieldInformation
    }
}