table 90000 DMTSetup
{
    Caption = 'DMT Setup', comment = 'de-DE=DMT Einrichtung';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key', comment = 'de-DE=Primärschlüssel'; }
        field(10; "Obj. ID Range Buffer Tables"; Text[250])
        {
            Caption = 'Obj. ID Range Buffer Tables', comment = 'de-DE=Objekt ID Bereich für Puffertabellen';
        }
        field(11; "Obj. ID Range XMLPorts"; Text[250])
        {
            Caption = 'Obj. ID Range XMLPorts (Import)', comment = 'de-DE=Objekt ID Bereich für XMLPorts (Import)';
        }

        field(41; "Import with FlowFields"; Boolean)
        {
            Caption = 'Gen. Buffer Tables with Flowfields', comment = 'de-DE=Puffertabellen mit Flowfields generieren';
        }
    }
    keys
    {
        key(Key1; "Primary Key") { Clustered = true; }
    }

    internal procedure InsertWhenEmpty()
    begin
        if Rec.Get() then
            exit;

        if not Rec.Get() then begin
            Rec.Insert();
        end;
    end;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Get();
        RecordHasBeenRead := true;
    end;

    var
        RecordHasBeenRead: Boolean;
}