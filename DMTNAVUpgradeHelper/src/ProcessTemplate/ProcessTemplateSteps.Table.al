table 90014 DMTProcessTemplateSteps
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Process Template Code"; Code[150])
        {
            Caption = 'Process Template Code', Comment = 'de-DE=Prozessvorlage Code';
            TableRelation = DMTProcessTemplate;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'de-DE=Zeilennummer';
        }
        field(3; "Step Type"; Option)
        {
            Caption = 'Step Type', Comment = 'de-DE=Schritt Typ';
            OptionMembers = ,MigrationTable,MigrationCodeunit;
        }
    }

    keys
    {
        key(PK; "Process Template Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }


    procedure filterFor(DMTProcessTemplate: Record DMTProcessTemplate) HasLinesInFilter: Boolean
    begin
        Rec.SetRange(Rec."Process Template Code", DMTProcessTemplate.Code);
        HasLinesInFilter := not Rec.IsEmpty;
    end;

}