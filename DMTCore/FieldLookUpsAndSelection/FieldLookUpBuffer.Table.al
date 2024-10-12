table 91015 DMTFieldLookUpBuffer
{
    TableType = Temporary;

    fields
    {
        field(1; "Field No."; Integer) { }
        field(10; LookUpType; Option) { OptionMembers = " ",SourceFields,TargetFields; }
        field(11; "Field Name"; Text[250]) { }
        field(12; "Field Caption"; Text[250]) { }
        field(13; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Conf.Header ID', Comment = 'de-DE=Import Konfig. Kopf ID';
            TableRelation = DMTImportConfigHeader;
        }
        field(14; "Table No."; Integer) { } // RecRef Filter
        field(30; "Source Field Caption"; Text[80])
        {
            Caption = 'Source Field Caption', Comment = 'de-DE=Herkunftsfeld';
            TableRelation = DMTFieldLookUpBuffer."Field Caption" where("Imp.Conf.Header ID" = field("Imp.Conf.Header ID"), LookUpType = const(SourceFields));
            ValidateTableRelation = false;
        }
        field(32; "Target Field Caption"; Text[80])
        {
            Caption = 'Target Field Caption', Comment = 'de-DE=Zielfeld';
            TableRelation = DMTFieldLookUpBuffer."Field Caption" where("Imp.Conf.Header ID" = field("Imp.Conf.Header ID"), "Table No." = field("Table No."), LookUpType = const(TargetFields));
            ValidateTableRelation = false;
        }
        field(50; FilterExpression; Text[2048])
        {
            Caption = 'Filter', Comment = 'de-DE=Filter';
        }
        field(51; DefaultValue; Text[2048])
        {
            Caption = 'Default Value', Comment = 'de-DE=Vorgabewert';
        }
    }

    keys
    {
        key(PK; "Field No.") { Clustered = true; }
    }

    fieldgroups
    {
        // Add changes to field groups here
        fieldgroup(DropDown; "Field No.", "Field Caption") { }
    }

    internal procedure OnAfterLookUpField(var Selected: RecordRef; FieldNo: Integer)
    var
        tempFieldSelectionBuffer: Record DMTFieldLookUpBuffer temporary;
    begin
        Selected.SetTable(tempFieldSelectionBuffer);
        case FieldNo of
            Rec.FieldNo("Source Field Caption"):
                begin
                    Rec.LookUpType := tempFieldSelectionBuffer.LookUpType::SourceFields;
                    Rec."Field No." := tempFieldSelectionBuffer."Field No.";
                    Rec."Field Caption" := tempFieldSelectionBuffer."Field Caption";
                end;
            Rec.FieldNo("Target Field Caption"):
                begin
                    Rec.LookUpType := tempFieldSelectionBuffer.LookUpType::TargetFields;
                    Rec."Field No." := tempFieldSelectionBuffer."Field No.";
                    Rec."Field Caption" := tempFieldSelectionBuffer."Field Caption";
                end;
            else
                error('unhandled case FieldNo=%1', FieldNo);
        end;
    end;

    internal procedure OnValidateOnAfterLookUp(var CurrREC: Record DMTFieldLookUpBuffer temporary; FieldNo: Integer)
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        case rec.LookUpType of
            rec.LookUpType::SourceFields:
                begin
                    importConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
                    importConfigLine.SetRange("Source Field No.", Rec."Field No.");
                    if importConfigLine.FindFirst() then
                        CurrREC."Field Caption" := importConfigLine."Source Field Caption";
                end;
            Rec.LookUpType::TargetFields:
                begin
                    importConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
                    importConfigLine.SetRange("Target Field No.", Rec."Field No.");
                    if importConfigLine.FindFirst() then begin
                        importConfigLine.CalcFields("Target Field Caption");
                        CurrREC."Field Caption" := importConfigLine."Target Field Caption";
                    end;
                end;
        end;

    end;
}