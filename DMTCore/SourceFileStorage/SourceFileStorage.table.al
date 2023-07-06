table 90004 DMTSourceFileStorage
{
    Caption = 'DMT Source Files', Comment = 'DMT Quelldateien';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File ID"; Integer) { }
        field(10; "File Blob"; Blob) { }
        field(100; Name; Text[99]) { Caption = 'Name'; Editable = false; }
        field(101; Extension; Text[10]) { Caption = 'Extension', Comment = 'de-DE=Dateiendung'; Editable = false; }
        field(102; Size; Integer) { Caption = 'Size'; Editable = false; }
        field(103; UploadDateTime; DateTime) { Caption = 'Uploaded at', Comment = 'de-DE=Hochgeladen am'; Editable = false; }
    }

    keys
    {
        key(PK; "File ID") { Clustered = true; }
    }
}