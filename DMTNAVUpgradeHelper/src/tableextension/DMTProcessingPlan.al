tableextension 50002 DMTProcessingPlan extends DMTProcessingPlan
{
    fields
    {
        // Add changes to table fields here
        field(90011; "Process Template Code"; Code[150])
        {
            Caption = 'Process Template Code', Comment = 'de-DE=Prozessvorlage Code';
            // TableRelation = DMTProcessTemplate;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
}