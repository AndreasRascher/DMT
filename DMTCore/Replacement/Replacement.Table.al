table 91010 DMTReplacement
{
    DataClassification = ToBeClassified;

    fields
    {

        #region TableKeys
        field(1; "Line Type"; Option) { Caption = 'Line Type', Comment = 'de-DE=Zeilenart'; OptionMembers = Replacement,Rule,Assignment; }
        field(2; "Code"; Code[100]) { Caption = 'Code', Locked = true; NotBlank = true; }
        field(3; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennr.'; }
        #endregion TableKeys
        field(10; Description; Text[100]) { Caption = 'Description', Comment = 'de-DE=Beschreibung'; }
        #region Compare Values
        field(100; "No. of Compare Values"; Option)
        {
            Caption = 'No. of Compare Values', Comment = 'de-DE=Anz. Vergleichswerte';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(110; "Comp.Value 1"; Text[80]) { Caption = 'Compare Value 1', Comment = 'de-DE=Vgl.-Wert 1'; CaptionClass = Rec.GetCaption(Rec.FieldNo("Comp.Value 1")); }
        field(111; "Comp.Val.1 Caption"; Text[80]) { Caption = 'Compare Field 1 Caption', Comment = 'de-DE=Vgl.-Wert 1 Bezeichnung'; }
        field(120; "Comp.Value 2"; Text[80]) { Caption = 'Compare Value 2', Comment = 'de-DE=Vgl.-Wert 2'; CaptionClass = Rec.GetCaption(Rec.FieldNo("Comp.Value 2")); }
        field(121; "Comp.Val.2 Caption"; Text[80]) { Caption = 'Compare Field 2 Caption'; }
        #endregion Compare Values
        #region NewValues
        field(200; "No. of Values to modify"; Option)
        {
            Caption = 'No. of Values to modify', Comment = 'de-DE=Anz. zu ändernder Werte';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(210; "New Value 1"; Text[250]) { Caption = 'New Value 1', Comment = 'de-DE=Neuer Wert 1'; CaptionClass = Rec.GetCaption(Rec.FieldNo("New Value 1")); }
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
        field(220; "New Value 2"; Text[80]) { Caption = 'New Value 2 Caption', Comment = 'de-DE=Neuer Wert 2'; CaptionClass = Rec.GetCaption(Rec.FieldNo("New Value 2")); }
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
        #region ImportConfigHeaderTargetFieldAssignment
        field(400; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'ImportConfigHeader ID';
            TableRelation = DMTImportConfigHeader.ID;
        }
        field(401; "Data File Name"; Text[250])
        {
            Caption = 'ImportConfigHeader Name', Comment = 'de-DE=Dateiname';
            // FieldClass = FlowField;
            // CalcFormula = lookup(DMTImportConfigHeader.Name where(ID = field("Imp.Conf.Header ID")));
            // Editable = false;
        }
        field(402; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', Comment = 'de-DE=Ziel Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(403; "Compare Value 1 Field No."; Integer)
        {
            Caption = 'Compare Value 1 Field No.', Comment = 'de-DE=Vgl.-Wert 1 Feld Nr.';
            TableRelation = DMTImportConfigLine."Source Field No." where("Target Table ID" = field("Target Table ID"), "Source Field No." = field("Compare Value 1 Field No."));
        }
        field(404; "Compare Value 2 Field No."; Integer)
        {
            Caption = 'Compare Value 2 Field No.', Comment = 'de-DE=Vgl.-Wert 2 Feld Nr.';
            TableRelation = DMTImportConfigLine."Source Field No." where("Target Table ID" = field("Target Table ID"), "Source Field No." = field("Compare Value 2 Field No."));
        }
        field(405; "New Value 1 Field No."; Integer)
        {
            Caption = 'Compare Value 1 Field No.', Comment = 'de-DE=Vgl.-Wert 1 Feld Nr.';
            TableRelation = DMTImportConfigLine."Target Field No." where("Target Table ID" = field("Target Table ID"), "Target Field No." = field("New Value 1 Field No."));
        }
        field(406; "New Value 2 Field No."; Integer)
        {
            Caption = 'Compare Value 2 Field No.', Comment = 'de-DE=Vgl.-Wert 2 Feld Nr.';
            TableRelation = DMTImportConfigLine."Target Field No." where("Target Table ID" = field("Target Table ID"), "Target Field No." = field("New Value 2 Field No."));
        }
        #endregion ImportConfigHeaderTargetFieldAssignment
    }

    keys
    {
        key(Key1; "Line Type", Code, "Line No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description) { }
    }

    trigger OnInsert()
    begin
        case Rec."Line Type" of
            Rec."Line Type"::Replacement:
                Rec.TestField("Line No.", 0);
            Rec."Line Type"::Rule:
                Rec.TestField("Line No.");
            Rec."Line Type"::Assignment:
                begin
                    Rec.TestField("Imp.Conf.Header ID");
                    Rec.TestField(Code);
                    Rec."Line No." := Rec."Imp.Conf.Header ID";
                end;
        end;
    end;

    trigger OnDelete()
    var
        DMTReplacement: Record DMTReplacement;
    begin
        if Rec."Line Type" = Rec."Line Type"::Replacement then begin
            DMTReplacement.SetRange(Code, Rec.Code);
            // delete Rules
            DMTReplacement.SetRange("Line Type", Rec."Line Type"::Rule);
            if not DMTReplacement.IsEmpty then
                DMTReplacement.DeleteAll();
            DMTReplacement.SetRange(Code, Rec.Code);
            // delete Assignments
            DMTReplacement.SetRange("Line Type", Rec."Line Type"::Assignment);
            if not DMTReplacement.IsEmpty then
                DMTReplacement.DeleteAll();
        end;
    end;

    internal procedure GetCaption(FieldNo: Integer) FieldCaption: Text
    var
        Replacement, ReplacementLine : Record DMTReplacement;
        CurrentFilter: Text;
        CustomFieldCaption: Text;
    begin
        // GetPagePartFilter
        ReplacementLine.Copy(Rec);
        ReplacementLine.FilterGroup(4);
        CurrentFilter := ReplacementLine.GetFilter(Code);
        if CurrentFilter in [''/*Not loaded*/, ''''''/*New header Record with empty code*/] then
            exit('');
        if not Replacement.Get(Replacement."Line Type"::Replacement, ReplacementLine.Code) then
            exit;

        case FieldNo of
            Rec.FieldNo("Comp.Value 1"):
                begin
                    FieldCaption := Rec.FieldCaption("Comp.Value 1");
                    CustomFieldCaption := Replacement."Comp.Val.1 Caption";
                end;
            Rec.FieldNo("Comp.Value 2"):
                begin
                    FieldCaption := Rec.FieldCaption("Comp.Value 2");
                    CustomFieldCaption := Replacement."Comp.Val.2 Caption";

                end;
            Rec.FieldNo("New Value 1"):
                begin
                    FieldCaption := Rec.FieldCaption("New Value 1");
                    CustomFieldCaption := Replacement."New Value 1 Caption";
                end;
            Rec.FieldNo("New Value 2"):
                begin
                    FieldCaption := Rec.FieldCaption("New Value 2");
                    CustomFieldCaption := Replacement."New Value 2 Caption";
                end;
        end;
        if CustomFieldCaption <> '' then
            exit('3,' + CustomFieldCaption)
        else
            exit('3,' + FieldCaption);
    end;

    internal procedure getRelatedTableIDsFilter() Filter: Text
    begin
        if Rec."Rel.to Table ID (New Val.1)" <> 0 then
            Filter += '|' + Format(Rec."Rel.to Table ID (New Val.1)");
        if Rec."Rel.to Table ID (New Val.2)" <> 0 then
            Filter += '|' + Format(Rec."Rel.to Table ID (New Val.2)");
        Filter := Filter.TrimStart('|');
    end;

    internal procedure contains(ReplacementCode: Code[100]; var tempImportConfigLine: Record DMTImportConfigLine temporary): Boolean
    var
        ReplacementAssignment: Record DMTReplacement;
    begin
        ReplacementAssignment.SetRange(Code, ReplacementCode);
        ReplacementAssignment.SetRange("Line Type", ReplacementAssignment."Line Type"::Assignment);
        ReplacementAssignment.SetRange("Imp.Conf.Header ID", tempImportConfigLine."Imp.Conf.Header ID");
        ReplacementAssignment.SetRange("Target Table ID", tempImportConfigLine."Target Table ID");
        ReplacementAssignment.SetRange("Compare Value 1 Field No.", tempImportConfigLine."Target Field No.");
        exit(not ReplacementAssignment.IsEmpty);
    end;

    procedure getNextLineNo(ReplacementCode: Code[100]; LineType: Option) nextLineNo: Integer
    var
        replacement: Record DMTReplacement;
    begin
        replacement.SetRange(Code, ReplacementCode);
        replacement.SetRange("Line Type", LineType);
        nextLineNo := 10000;
        if replacement.FindLast() then
            nextLineNo += replacement."Line No.";
    end;

    procedure filterAssignmentFor(ImportConfigHeader: Record DMTImportConfigHeader) HasLines: Boolean;
    begin
        Rec.SetRange("Line Type", "Line Type"::Assignment);
        Rec.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        Rec.SetRange("Target Table ID", ImportConfigHeader."Target Table ID");
        HasLines := not Rec.IsEmpty;
    end;

    procedure IsEqual(DMTReplacement: Record DMTReplacement): Boolean
    begin
        exit(Format(Rec) = Format(DMTReplacement));
    end;
}