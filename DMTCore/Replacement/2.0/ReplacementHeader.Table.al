table 91011 DMTReplacementHeader
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[100]) { Caption = 'Code', Locked = true; NotBlank = true; }
        field(10; Description; Text[100]) { Caption = 'Description', Comment = 'de-DE=Beschreibung'; }
        #region Compare Values
        field(100; "No. of Source Values"; Option)
        {
            Caption = 'No. of Compare Values', Comment = 'de-DE=Anz. Vergleichswerte';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(102; "Comp.Val.1 Caption"; Text[80]) { Caption = 'Compare Field 1 Caption', Comment = 'de-DE=Vgl.-Wert 1 Bezeichnung'; }
        field(104; "Comp.Val.2 Caption"; Text[80]) { Caption = 'Compare Field 2 Caption', Comment = 'de-DE=Vgl.-Wert 2 Bezeichnung'; ; }
        #endregion Compare Values
        #region NewValues
        field(200; "No. of Values to modify"; Option)
        {
            Caption = 'No. of Values to modify', Comment = 'de-DE=Anz. zu ändernder Werte';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(211; "New Value 1 Caption"; Text[80]) { Caption = 'New Value 1 Caption', Comment = 'de-DE=Neuer Wert 1 Bezeichnung'; }
        field(212; "Rel.to Table ID (New Val.1)"; Integer)
        {
            Caption = 'Related to Table ID (New.Fld.1)', Comment = 'de-DE=Tabellenrelation ID (Neu 1)';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Rel.to Table Cpt.(New Val.1)");
            end;
        }
        field(213; "Rel.to Table Cpt.(New Val.1)"; Text[100])
        {
            Caption = 'Related Table Caption (New Val.1)', Comment = 'de-DE=Relation zu Tabelle (Neu 1)';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (New Val.1)")));
            Editable = false;
        }
        field(221; "New Value 2 Caption"; Text[80]) { Caption = 'New Value 2 Caption', Comment = 'de-DE=Neuer Wert 2 Bezeichnung'; }
        field(222; "Rel.to Table ID (New Val.2)"; Integer)
        {
            Caption = 'Related to Table ID (New Val.2)', Comment = 'de-DE=Tabellenrelation ID (Neu 2)';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Rel.to Table Cpt.(New Val.1)");
            end;
        }
        field(223; "Rel.to Table Cpt.(New Val.2)"; Text[100])
        {
            Caption = 'Related Table Caption (New Val.2)', Comment = 'de-DE=Relation zu Tabelle (Neu 2)';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (New Val.2)")));
            Editable = false;
        }
        #endregion NewValues
        field(300; "No. of Rules"; Integer)
        {
            Description = 'Show No. of Rules in List';
            Caption = 'No. of Rules', Comment = 'de-DE=Anzahl Regeln';
            FieldClass = FlowField;
            CalcFormula = count(DMTReplacement where("Line Type" = const(Rule), Code = field(Code)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(Brick; Description, "No. of Source Values", "No. of Values to modify") { }
    }

    trigger OnDelete()
    var
        replacementLine: Record DMTReplacementLine;
    begin
        if replacementLine.FilterFor(Rec) then
            replacementLine.DeleteAll(true);
    end;


}