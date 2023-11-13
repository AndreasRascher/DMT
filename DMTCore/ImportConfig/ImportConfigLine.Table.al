table 91006 DMTImportConfigLine
{
    Caption = 'DMT Import Configuration Line', Comment = 'de-DE=Import Konfiguration Zeile';
    fields
    {
        field(1; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Conf.Header ID', Comment = 'de-DE=Import Konfig. Kopf ID';
            TableRelation = DMTImportConfigHeader;
        }
        field(10; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', Comment = 'de-DE=Ziel Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(11; "Target Field No."; Integer)
        {
            Caption = 'Target Field No.', Comment = 'de-DE=Ziel Feldnr.';
            TableRelation = Field."No." where(TableNo = field("Target Table ID"));
        }
        field(12; "Target Field Name"; Text[80])
        {
            Caption = 'Target Field Name', Comment = 'de-DE=Zielfeld Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
        }
        field(13; "Target Field Caption"; Text[80])
        {
            Caption = 'Target Field Caption', Comment = 'de-DE=Zielfeld Bezeichnung';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
        }
        field(14; "Target Table Relation"; Integer)
        {
            Caption = 'Target Table Relation', Comment = 'de-DE=Tab. -Rel. (Zielfeld)';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field.RelationTableNo where(TableNo = field("Target Table ID"), "No." = field("Target Field No.")));
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(15; "Is Key Field(Target)"; Boolean) { Caption = 'Key Field', Comment = 'de-DE=Schlüsselfeld'; Editable = false; }
        field(16; "Target Table Caption"; Text[250])
        {
            Caption = 'Target Table', Comment = 'de-DE=Zieltabelle';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
            TableRelation = AllObjWithCaption."Object Caption" where("Object Type" = const(Table));
        }
        field(20; "Source Field No."; Integer)
        {
            Caption = 'Source Field No.', Comment = 'de-DE=Herkunftsfeld Nr.';
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            ValidateTableRelation = false;
            BlankZero = true;
            trigger OnValidate()
            begin
                UpdateSourceFieldCaptionAndProcessingAction(Rec.FieldNo("Source Field No."));
            end;
        }
        field(21; "Source Field Caption"; Text[80]) { Caption = 'Source Field Caption', Comment = 'de-DE=Herkunftsfeld Bezeichnung'; Editable = false; }
        field(50; "Validation Type"; Enum DMTFieldValidationType) { Caption = 'Valid. Type', Comment = 'de-DE=Valid. Typ'; }
        field(52; "Ignore Validation Error"; Boolean) { Caption = 'Ignore Errors', Comment = 'de-DE=Fehler ignorieren '; }
        field(100; "Processing Action"; Enum DMTFieldProcessingType)
        {
            Caption = 'Action', Comment = 'de-DE=Aktion';
            trigger OnValidate()
            begin
                if xRec."Processing Action" = rec."Processing Action" then
                    exit;
                if rec."Processing Action" = Rec."Processing Action"::Transfer then
                    rec.TestField("Source Field No.");
            end;
        }
        field(101; "Fixed Value"; Text[250])
        {
            Caption = 'Fixed Value', Comment = 'de-DE=Fester Wert';
            trigger OnValidate()
            var
                ConfigValidateMgt: Codeunit "Config. Validate Management";
                RecRef: RecordRef;
                FldRef: FieldRef;
                ErrorMsg: Text;
            begin
                Rec.TestField("Target Table ID");
                Rec.TestField("Target Field No.");
                if "Fixed Value" <> '' then begin
                    RecRef.Open(Rec."Target Table ID");
                    FldRef := RecRef.Field(Rec."Target Field No.");
                    ErrorMsg := ConfigValidateMgt.EvaluateValue(FldRef, "Fixed Value", false);
                    if ErrorMsg <> '' then begin
                        Error(ErrorMsg);
                    end else begin
                        "Fixed Value" := Format(FldRef.Value);
                    end;
                end;
            end;
        }
        field(102; "Validation Order"; Integer) { Caption = 'Validation Order', Comment = 'de-DE=Reihenfolge Validierung'; }
        #region SelectMulipleFields
        field(200; "Search Target Field Name"; Text[80])
        {
            Description = 'Searchable field because Flowfields are not covered by the page search';
            Caption = 'Target Field Name', Comment = 'de-DE=Zielfeld Name';
            Editable = false;
        }
        field(201; "Search Target Field Caption"; Text[80])
        {
            Description = 'Searchable field because Flowfields are not covered by the page search';
            Caption = 'Target Field Caption', Comment = 'de-DE=Zielfeld Bezeichnung';
            Editable = false;
        }
        field(202; Selection; Boolean) { Caption = 'Selection', Comment = 'de-DE=Auswahl'; }

        #endregion SelectMulipleFields
    }

    keys
    {
        key(Key1; "Imp.Conf.Header ID", "Target Field No.")
        {
            Clustered = true;
        }
        key(Key2; "Validation Order") { }

    }

    trigger OnDelete()
    var
        DMTSetup: Record DMTSetup;
        IReplacementHandler: Interface IReplacementHandler;
    begin
        DMTSetup.getDefaultReplacementImplementation(IReplacementHandler);
        IReplacementHandler.RemoveAssignmentOnDelete(Rec);
    end;

    local procedure UpdateSourceFieldCaptionAndProcessingAction(FromFieldNo: Integer)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        BuffTableCaptions: Dictionary of [Integer, Text];
    begin
        case FromFieldNo of
            Rec.FieldNo("Source Field No."):
                begin
                    // clear fields
                    Clear(Rec."Source Field Caption");
                    Clear(Rec."Processing Action");

                    // Load Header
                    ImportConfigHeader.Get(Rec."Imp.Conf.Header ID");

                    //Read Captions from Buffer Table Fields
                    ImportConfigHeader.BufferTableMgt().ReadBufferTableColumnCaptions(BuffTableCaptions);
                    if BuffTableCaptions.ContainsKey(Rec."Source Field No.") then begin
                        Rec."Source Field Caption" := CopyStr(BuffTableCaptions.Get(Rec."Source Field No."), 1, MaxStrLen(Rec."Source Field Caption"));
                        Rec."Processing Action" := Rec."Processing Action"::Transfer;
                    end;
                end;
            else
                Error('unhandled %1', FromFieldNo);
        end;
    end;

    procedure CopyToTemp(var TempImportConfigLine: Record DMTImportConfigLine temporary) LineCount: Integer
    var
        ImportConfigLine: Record DMTImportConfigLine;
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
    begin
        ImportConfigLine.Copy(Rec);
        ImportConfigLine.SetAutoCalcFields("Target Field Caption");
        if ImportConfigLine.FindSet(false) then
            repeat
                LineCount += 1;
                TempImportConfigLine2 := ImportConfigLine;
                TempImportConfigLine2.Insert(false);
            until ImportConfigLine.Next() = 0;
        TempImportConfigLine.Copy(TempImportConfigLine2, true);
    end;
}