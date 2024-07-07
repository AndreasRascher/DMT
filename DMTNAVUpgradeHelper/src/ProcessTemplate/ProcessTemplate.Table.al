// Aufbau:
// - Code - Description Tabelle
// - Requirements
//      - benötige Dateinamen in den DMT Quelldateien
//      - Pufferobjekte (Migrationstabellen + Codeunits)
// Logik:
// - Prüfung ob die Vorraussetzungen erfüllt sind
// - Anbieten des Migrationspakets

table 90012 DMTProcessTemplate
{
    DataClassification = ToBeClassified;
    Caption = 'DMT Process Template', Comment = 'de-DE=DMT Prozessvorlage';
    LookupPageId = DMTProcessTemplateList;
    DrillDownPageId = DMTProcessTemplateList;

    fields
    {
        field(1; Code; Code[150])
        {
            Caption = 'Code', Comment = 'de-DE=Code';
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description', Comment = 'de-DE=Beschreibung';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
    trigger OnDelete()
    var
        processTemplateRequirement: Record DMTProcessTemplateDetails;
        processTemplateSteps: Record DMTProcessTemplateSteps;
    begin
        if processTemplateRequirement.filterFor(Rec) then
            processTemplateRequirement.DeleteAll();
        if processTemplateSteps.filterFor(Rec) then
            processTemplateSteps.DeleteAll();
    end;
}