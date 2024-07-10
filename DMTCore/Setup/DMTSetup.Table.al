table 50140 DMTSetup
{
    Caption = 'DMT Setup', Comment = 'de-DE=DMT Einrichtung';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key', Comment = 'de-DE=Primärschlüssel'; }
        field(10; MigrationProfil; Enum DMTMigrationProfile)
        {
            Caption = 'Migration Profil', Comment = 'de-DE=Migrationsprofil';
            trigger OnValidate()
            var
                DMTDataLayouts: Page DMTDataLayouts;
            begin
                Modify();
                if Rec.IsNAVExport() then
                    DMTDataLayouts.InsertPresetDataLayouts();
            end;
        }
        field(23; "Use exist. mappings"; Boolean) { Caption = 'Propose matching fields - Use existing mappings', Comment = 'de-DE=Feldzuordnung vorschlagen - Existierende Feld-Mappings verwenden'; InitValue = true; }
        field(30; "Exports include FlowFields"; Boolean) { Caption = 'Exports include Flowfields', Comment = 'de-DE=Exportdateien enthalten FlowFields'; }

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
        // ToDo: Dialog DMT Einrichtung öffnen wenn Get fehlschlägt
        RecordHasBeenRead := true;
    end;

    procedure getDefaultReplacementImplementation(var IReplacementHandler: Interface IReplacementHandler)
    var
        // ReplacementHandlerImpl: codeunit ReplacementHandlerImpl;
        ReplacementHandlerImpl: codeunit ReplacementHandlerImpl2;
    begin
        IReplacementHandler := ReplacementHandlerImpl;
    end;

    // Interface used as return value because only atomic procedure calls are possible
    procedure getDefaultImportConfigPageActionImplementation() IImportConfigPageAction: Interface IImportConfigPageAction
    var
        // ReplacementHandlerImpl: codeunit ReplacementHandlerImpl;
        importConfigPageActionImpl: codeunit DMTImportConfigPageActionImpl;
    begin
        IImportConfigPageAction := importConfigPageActionImpl;
    end;

    internal procedure getDefaultTriggerLogImplementation(var IValueMigrationLog: Interface ITriggerLog) IsInterfaceInititalized: Boolean
    var
        ITriggerLog: Codeunit DMTTriggerLogImpl;
    begin
        IValueMigrationLog := ITriggerLog;
        IsInterfaceInititalized := true;
    end;

    procedure IsNAVExport(): Boolean
    begin
        if not RecordHasBeenRead then
            Rec.get();
        exit(Rec.MigrationProfil = Rec.MigrationProfil::"From NAV");
    end;

    var
        RecordHasBeenRead: Boolean;
}