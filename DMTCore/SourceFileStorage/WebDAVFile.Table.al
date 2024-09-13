table 50141 DMTWebDAVFile
{
    TableType = Temporary;
    fields
    {
        field(1; "Path"; Text[2048]) { Caption = 'Path', Comment = 'de-DE=Pfad'; }
        field(2; "Is Folder"; Boolean) { Caption = 'Is Folder', Comment = 'de-DE=Ist Ordner'; }
        field(3; "Name"; Text[2048]) { Caption = 'Name', Comment = 'de-DE=Name'; }
        field(4; Size; Integer) { Caption = 'Size', Comment = 'de-DE=Größe'; }
        field(5; LastModified; DateTime) { Caption = 'Last Modified', Comment = 'de-DE=Letzte Änderung'; }
    }

    keys
    {
        key(pk; "Path", "Is Folder", "Name")
        {

        }
    }
}