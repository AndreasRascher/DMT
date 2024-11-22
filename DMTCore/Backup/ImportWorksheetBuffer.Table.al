table 91016 DMTImportWorksheetBuffer
{
    TableType = Temporary;
    fields
    {
        field(1; Type; Enum DMTBackupEntity) { Caption = 'Type', Comment = 'de-DE=Art'; Editable = false; }
        field(2; UniqueID; Text[250]) { Caption = 'Unique ID', Comment = 'de-DE=Eindeutige ID'; Editable = false; }
        field(3; ImportAction; Option)
        {
            Caption = 'Import Action', Comment = 'de-DE=Importaktion';
            OptionMembers = "Add",Replace,Skip;
        }
        field(4; SourceRecID; RecordID) { }
        field(5; mappedToID; Integer) { }
    }

    keys
    {
        key(PK; Type, UniqueID) { Clustered = true; }
    }
}