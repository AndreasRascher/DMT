table 50154 DMTWebDAVFile
{
    TableType = Temporary;
    fields
    {
        field(1; "Path"; Text[2048]) { }
        field(2; "Is Folder"; Boolean) { }
        field(3; "Name"; Text[2048]) { }
        field(4; Size; Integer) { }
        field(5; LastModified; DateTime) { }
    }

    keys
    {
        key(pk; "Path", "Is Folder", "Name")
        {

        }
    }
}