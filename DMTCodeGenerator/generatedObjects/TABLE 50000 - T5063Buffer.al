table 90012 T5063Buffer
{
    CaptionML = DEU = 'Aktivitätengruppe(DMT)', ENU = 'Interaction Group(DMT)';
    fields
    {
        field(1; "Code"; Code[10])
        {
            CaptionML = ENU = 'Code', DEU = 'Code';
        }
        field(2; "Description"; Text[50])
        {
            CaptionML = ENU = 'Description', DEU = 'Beschreibung';
        }
        field(59999; "DMT Target Record Exists"; Boolean)
        {
            CaptionML = ENU = 'DMT target record exists', DEU = 'DMT Zieldatensatz vorhanden';
            FieldClass = FlowField;
            CalcFormula = exist("Interaction Group" where(Code = field(Code)));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
