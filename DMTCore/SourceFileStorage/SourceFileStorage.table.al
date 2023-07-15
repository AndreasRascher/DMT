table 91004 DMTSourceFileStorage
{
    LookupPageId = 91005;
    Caption = 'DMT Source File', Comment = 'de-DE=DMT Quelldatei';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File ID"; Integer) { }
        field(10; "File Blob"; Blob) { }
        field(100; Name; Text[99]) { Caption = 'Name', Comment = 'de-DE=Name'; Editable = false; }
        field(101; Extension; Text[10]) { Caption = 'Extension', Comment = 'de-DE=Dateiendung'; Editable = false; }
        field(102; Size; Integer) { Caption = 'Size', Comment = 'de-DE=Größe'; Editable = false; }
        field(103; UploadDateTime; DateTime) { Caption = 'Uploaded at', Comment = 'de-DE=Hochgeladen am'; Editable = false; }
    }

    keys
    {
        key(PK; "File ID") { Clustered = true; }
    }
}