table 50145 DMTDataLayoutLine
{
    Caption = 'Data Layout Line', Comment = 'de-DE=Datenlayoutzeile';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Data Layout ID"; Integer) { Caption = 'Data Layout ID', Comment = 'de-DE= Datenlayout ID'; NotBlank = true; }
        field(2; "Column No."; Integer) { Caption = 'Column No.', Comment = 'de-DE=Spaltennr.'; }
        field(10; ColumnName; Text[50]) { Caption = 'Column Name', Comment = 'de-DE=Spaltenname'; }
        field(100; "Import Config. ID Filter"; Integer) { Caption = 'Data File ID Filter', Locked = true; FieldClass = FlowFilter; }
        field(101; "Field Look Mode Filter"; Option) { Caption = 'Field Look Mode Filter', Locked = true; OptionMembers = "Look Up Source","Look Up Target"; FieldClass = FlowFilter; }
    }

    keys
    {
        key(PK; "Data Layout ID", "Column No.") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; ColumnName, "Column No.") { }
    }

    // procedure CopyToTemp(var TempDataLayoutLine: Record DMTDataLayoutLine temporary) LineCount: Integer
    // var
    //     DataLayoutLine: Record DMTDataLayoutLine;
    //     TempDataLayoutLine2: Record DMTDataLayoutLine temporary;
    // begin
    //     DataLayoutLine.Copy(Rec);
    //     if DataLayoutLine.FindSet(false) then
    //         repeat
    //             LineCount += 1;
    //             TempDataLayoutLine2 := DataLayoutLine;
    //             TempDataLayoutLine2.Insert(false);
    //         until DataLayoutLine.Next() = 0;
    //     TempDataLayoutLine.Copy(TempDataLayoutLine2, true);
    // end;

    trigger OnInsert()
    begin
        Rec.TestField("Data Layout ID");
    end;
}