table 90004 DMTSourceFileStorage
{
    Caption = 'DMT Source Files', Comment = 'DMT Quelldateien';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File ID"; Integer) { }
        field(10; "File Blob"; Blob) { }
        field(100; Path; Code[98]) { Caption = 'Path'; Editable = false; }
        field(102; Name; Text[99]) { Caption = 'Name'; Editable = false; }
        field(103; Size; Integer) { Caption = 'Size'; Editable = false; }
        field(104; "DateTime"; DateTime) { Caption = 'DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "File ID") { Clustered = true; }
    }
}