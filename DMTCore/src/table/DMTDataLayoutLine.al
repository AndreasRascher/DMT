table 91005 DMTDataLayoutLine
{
    Caption = 'Data Layout Line', Comment = 'de-DE=Datenlayoutzeile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Layout ID"; Integer) { Caption = 'Data Layout ID', Comment = 'de-DE= Datenlayout ID'; NotBlank = true; }
        field(2; "Column No."; Integer) { Caption = 'Column No.', Comment = 'de-DE=Spaltennr.'; }
        field(10; ColumnName; Text[50]) { Caption = 'Column Name', Comment = 'de-DE=Spaltenname'; }
    }

    keys
    {
        key(PK; "Data Layout ID", "Column No.") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; ColumnName, "Column No.") { }
    }

    trigger OnInsert()
    begin
        Rec.TestField("Data Layout ID");
    end;
}