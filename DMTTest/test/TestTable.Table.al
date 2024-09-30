table 90021 TestTable
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PK1; Integer) { }
        field(10; OptionEvalutionTest; Option) { OptionMembers = "1","2","3"; OptionCaption = '1,2,3'; }
        field(20; DoModifyInValidate; Boolean)
        {
            trigger OnValidate()
            begin
                if DoModifyInValidate then
                    Modify();
            end;
        }
        field(30; ThrowErrorWhenInsert; Boolean) { }
        field(40; ThrowErrorOnDelete; Boolean) { }
    }

    keys
    {
        key(Key1; PK1) { Clustered = true; }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    trigger OnInsert()
    begin
        if ThrowErrorWhenInsert then
            Error('Error on insert');
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        if ThrowErrorOnDelete then
            Error('Error on delete');
    end;

    trigger OnRename()
    begin

    end;

}