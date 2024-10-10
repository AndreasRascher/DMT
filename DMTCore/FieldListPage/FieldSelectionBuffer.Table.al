table 91015 DMTFieldSelectionBuffer
{
    TableType = Temporary;

    fields
    {
        field(1; Type; Option) { OptionMembers = " ",Source,Target; }
        field(2; "Field No."; Integer)
        {
        }
        field(10; "Field Name"; Text[250]) { }
        field(11; "Field Caption"; Text[250]) { }
        field(12; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Conf.Header ID', Comment = 'de-DE=Import Konfig. Kopf ID';
            TableRelation = DMTImportConfigHeader;
        }
        field(30; "Source Field Caption"; Text[80])
        {
            Caption = 'Source Field Caption', Comment = 'de-DE=Herkunftsfeld';
            TableRelation = DMTFieldSelectionBuffer."Field Caption" where("Imp.Conf.Header ID" = field("Imp.Conf.Header ID"), Type = const(Source), "Field No." = field("Exclude Source Fields Filter"));
            ValidateTableRelation = false;
        }
        field(31; "Exclude Source Fields Filter"; Integer)
        {
            Caption = 'Exclude Source Fields Filter', Comment = 'de-DE=Herkunftsfelder ausschließen';
            FieldClass = FlowFilter;
        }
        field(32; "Target Field Caption"; Text[80])
        {
            Caption = 'Target Field Caption', Comment = 'de-DE=Zielfeld';
            TableRelation = DMTFieldSelectionBuffer."Field Caption" where("Imp.Conf.Header ID" = field("Imp.Conf.Header ID"), Type = const(Target), "Field No." = field("Exclude Target Fields Filter"));
            ValidateTableRelation = false;
        }
        field(33; "Exclude Target Fields Filter"; Integer)
        {
            Caption = 'Exclude Target Fields Filter', Comment = 'de-DE=Zielfelder ausschließen';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; Type, "Field No.") { Clustered = true; }
    }

    fieldgroups
    {
        // Add changes to field groups here
        fieldgroup(DropDown; "Field No.", "Field Caption") { }
    }

    internal procedure OnAfterLookUpField(var Selected: RecordRef; FieldNo: Integer)
    var
        tempFieldSelectionBuffer: Record DMTFieldSelectionBuffer temporary;
    begin
        Selected.SetTable(tempFieldSelectionBuffer);
        case FieldNo of
            Rec.FieldNo("Source Field Caption"):
                begin
                    Rec.Type := tempFieldSelectionBuffer.Type::Source;
                    Rec."Field No." := tempFieldSelectionBuffer."Field No.";
                    Rec."Field Caption" := tempFieldSelectionBuffer."Field Caption";
                end;
        end;
    end;

    internal procedure OnValidateOnAfterLookUp(var CurrREC: Record DMTFieldSelectionBuffer temporary; FieldNo: Integer)
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        case rec.Type of
            rec.Type::Source:
                begin
                    importConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
                    importConfigLine.SetRange("Source Field No.", Rec."Field No.");
                    if importConfigLine.FindFirst() then
                        CurrREC."Field Caption" := importConfigLine."Source Field Caption";
                end;
            Rec.Type::Target:
                begin
                    importConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
                    importConfigLine.SetRange("Target Field No.", Rec."Field No.");
                    if importConfigLine.FindFirst() then
                        CurrREC."Field Caption" := importConfigLine."Target Field Caption";
                end;
        end;

    end;

    procedure updateExcludeFilter()
    var
        tempFieldSelectionBuffer: Record DMTFieldSelectionBuffer temporary;
        excludeFilter: Text;
    begin
        tempFieldSelectionBuffer.Copy(Rec, true);
        if tempFieldSelectionBuffer.FindSet(false) then
            repeat
                // if not current line
                if Rec."Field No." <> tempFieldSelectionBuffer."Field No." then
                    excludeFilter += StrSubstNo('&<>%1', tempFieldSelectionBuffer."Field No.");
            until tempFieldSelectionBuffer.Next() = 0;
        excludeFilter := excludeFilter.TrimStart('&');
        Rec.SetFilter("Exclude Source Fields Filter", excludeFilter);
    end;
}