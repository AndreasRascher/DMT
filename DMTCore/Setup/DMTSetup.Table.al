table 91000 DMTSetup
{
    Caption = 'DMT Setup', Comment = 'de-DE=DMT Einrichtung';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key', Comment = 'de-DE=Primärschlüssel'; }
        field(10; MigrationProfil; Enum DMTMigrationProfile) { Caption = 'Migration Profil', Comment = 'de-DE=Migrationsprofil'; }
        field(20; "Obj. ID Range Buffer Tables"; Text[250]) { Caption = 'Obj. ID Range Buffer Tables', Comment = 'de-DE=Objekt ID Bereich für Puffertabellen'; }
        field(21; "Obj. ID Range XMLPorts"; Text[250]) { Caption = 'Obj. ID Range XMLPorts (Import)', Comment = 'de-DE=Objekt ID Bereich für XMLPorts (Import)'; }
        field(22; "Import with FlowFields"; Boolean) { Caption = 'Create Buffer Tables with Flowfields', Comment = 'de-DE=Puffertabellen mit Flowfields generieren'; }
        field(23; "Use exist. mappings"; Boolean) { Caption = 'Propose matching fields - Use existing mappings', Comment = 'de-DE=Feldzuordnung vorschlagen - Existierende Feld-Mappings verwenden'; InitValue = true; }

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

    procedure getDefaultReplacementImplementation(var IReplacementHandler: Interface IReplacementHandler)
    var
        // ReplacementHandlerImpl: codeunit ReplacementHandlerImpl;
        ReplacementHandlerImpl: codeunit ReplacementHandlerImpl2;
    begin
        IReplacementHandler := ReplacementHandlerImpl;
    end;

    procedure IsNAVExport(): Boolean
    begin
        if not RecordHasBeenRead then
            Rec.get();
        exit(rec.MigrationProfil = rec.MigrationProfil::"From NAV");
    end;

    var
        RecordHasBeenRead: Boolean;
}