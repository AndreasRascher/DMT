table 91012 DMTReplacementLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Replacement Code"; Code[100]) { Caption = 'Replacement Code', Comment = 'de-DE=Ersetzungscode'; NotBlank = true; }
        field(2; "Line Type"; Option) { Caption = 'Line Type', Comment = 'de-DE=Zeilenart'; OptionMembers = Rule,Assignment; OptionCaption = 'Rule,Assignment', comment = 'de-DE=Regel,Zuordnung'; ; }
        field(3; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennr.'; }
        field(20; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Config. ID', Comment = 'de-DE=Import Konfig. ID';
            TableRelation = DMTImportConfigHeader;
            trigger OnValidate()
            var
                importConfigHeader: Record DMTImportConfigHeader;
                ImportConfigLine: Record DMTImportConfigLine;
                ImportConfigHasNoFieldsErr: Label 'The Import Configuration %1 has no fields to assign.', Comment = 'de-DE=Für die Importkonfiguration %1 sind keine Felder zum Zuweisen vorhanden.';
            begin
                if not importConfigHeader.Get("Imp.Conf.Header ID") then
                    Init()
                else begin
                    "Target Table ID" := importConfigHeader."Target Table ID";
                    "Source File Name" := importConfigHeader."Source File Name";
                    if not importConfigHeader.FilterRelated(ImportConfigLine) then
                        Error(ImportConfigHasNoFieldsErr, importConfigHeader.ID);
                end;
            end;
        }
        field(21; "Source File Name"; Text[250])
        {
            Caption = 'Source File Name', Comment = 'de-DE=Quelldatei';
            Editable = false;
        }
        field(22; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', Comment = 'de-DE=Zieltabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            Editable = false;
        }
        field(30; "Source 1 Field No."; Integer)
        {
            Caption = 'Source Field 1 No.', Comment = 'de-DE=Herkunftsfeld 1 Nr.';
            //TableRelation = DMTfieldLookUpBuffer."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            TableRelation = DMTFieldLookUpBuffer."Field No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), LookUpType = const(SourceFields));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(31; "Source 1 Field Caption"; Text[80])
        {
            Caption = 'Source 1 Field Caption', Comment = 'de-DE=Herkunftsfeld 1';
            // TableRelation = DMTfieldLookUpBuffer."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            TableRelation = DMTFieldLookUpBuffer."Field Caption" where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), LookUpType = const(SourceFields));
            ValidateTableRelation = false;
        }
        field(32; "Source 2 Field No."; Integer)
        {
            Caption = 'Source 2 Field No.', Comment = 'de-DE=Herkunftsfeld 2 Nr.';
            // TableRelation = DMTfieldLookUpBuffer."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            TableRelation = DMTFieldLookUpBuffer."Field No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), LookUpType = const(SourceFields));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(33; "Source 2 Field Caption"; Text[80])
        {
            Caption = 'Source 2 Field Caption', Comment = 'de-DE=Herkunftsfeld 2';
            // TableRelation = DMTfieldLookUpBuffer."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            TableRelation = DMTFieldLookUpBuffer."Field Caption" where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), LookUpType = const(SourceFields));
            ValidateTableRelation = false;
        }
        field(34; "Target 1 Field No."; Integer)
        {
            Caption = 'Target 1 Field No.', Comment = 'de-DE=Ziel 1 Feldnr.';
            TableRelation = Field."No." where(TableNo = field("Target Table ID"));
        }
        field(35; "Target 1 Field Caption"; Text[80])
        {
            Caption = 'Target Field 1 Caption', Comment = 'de-DE=Zielfeld 1';
            // TableRelation = DMTfieldLookUpBuffer."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), "Field Look Mode Filter" = const("Look Up Target"));
            TableRelation = DMTFieldLookUpBuffer."Field Caption" where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), LookUpType = const(TargetFields));
            ValidateTableRelation = false;
        }
        field(36; "Target 2 Field No."; Integer)
        {
            Caption = 'Target 2 Field No.', Comment = 'de-DE=Ziel 2 Feldnr.';
            TableRelation = Field."No." where(TableNo = field("Target Table ID"));
        }
        field(37; "Target 2 Field Caption"; Text[80])
        {
            Caption = 'Target Field 2 Caption', Comment = 'de-DE=Zielfeld 2';
            // TableRelation = DMTfieldLookUpBuffer."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), "Field Look Mode Filter" = const("Look Up Target"));
            TableRelation = DMTFieldLookUpBuffer."Field Caption" where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), LookUpType = const(TargetFields));
            ValidateTableRelation = false;
        }

        field(200; "Comp.Value 1"; Text[80]) { Caption = 'Old Value 1', Comment = 'de-DE=Alter Wert 1'; }
        field(201; "Comp.Value 2"; Text[80]) { Caption = 'Old Value 2', Comment = 'de-DE=Alter Wert 2'; }
        field(300; "New Value 1"; Text[80]) { Caption = 'New Value 1 Caption', Comment = 'de-DE=Neuer Wert 1'; }
        field(301; "New Value 2"; Text[80]) { Caption = 'New Value 2 Caption', Comment = 'de-DE=Neuer Wert 2'; }
    }

    keys
    {
        key(PK; "Replacement Code", "Line Type", "Line No.") { Clustered = true; }
    }

    trigger OnDelete()
    begin
    end;

    procedure FilterFor(replacementHeader: Record DMTReplacementHeader) HasLines: Boolean
    begin
        Rec.SetRange("Replacement Code", replacementHeader.Code);
        HasLines := not Rec.IsEmpty;
    end;

    procedure CopyToTemp(var TempReplacementLine: Record DMTReplacementLine temporary) LineCount: Integer
    var
        replacementLine: Record DMTReplacementLine;
        tempReplacementLines2: Record DMTReplacementLine temporary;
    begin
        replacementLine.Copy(Rec);
        if replacementLine.FindSet(false) then
            repeat
                LineCount += 1;
                tempReplacementLines2 := replacementLine;
                tempReplacementLines2.Insert(false);
            until replacementLine.Next() = 0;
        TempReplacementLine.Copy(tempReplacementLines2, true);
    end;

    internal procedure OnAfterLookUpField(var Selected: RecordRef; fromFieldNo: Integer; var currfieldLookUpBuffer: Record DMTFieldLookUpBuffer)
    var
        fieldLookUpBufferSelected: Record DMTFieldLookUpBuffer;
    begin
        case fromFieldNo of
            Rec.FieldNo("Target 1 Field Caption"):
                begin
                    Selected.SetTable(fieldLookUpBufferSelected);
                    Rec."Target 1 Field No." := fieldLookUpBufferSelected."Field No.";
                    Rec."Target 1 Field Caption" := CopyStr(fieldLookUpBufferSelected."Field Caption", 1, MaxStrLen(Rec."Target 1 Field Caption"));
                    currfieldLookUpBuffer := fieldLookUpBufferSelected;
                end;
            Rec.FieldNo("Target 2 Field Caption"):
                begin
                    Selected.SetTable(fieldLookUpBufferSelected);
                    Rec."Target 2 Field No." := fieldLookUpBufferSelected."Field No.";
                    Rec."Target 2 Field Caption" := CopyStr(fieldLookUpBufferSelected."Field Caption", 1, MaxStrLen(Rec."Target 2 Field Caption"));
                    currfieldLookUpBuffer := fieldLookUpBufferSelected;
                end;
            Rec.FieldNo("Source 1 Field Caption"):
                begin
                    Selected.SetTable(fieldLookUpBufferSelected);
                    Rec."Source 1 Field No." := fieldLookUpBufferSelected."Field No.";
                    Rec."Source 1 Field Caption" := CopyStr(fieldLookUpBufferSelected."Field Caption", 1, MaxStrLen(Rec."Source 1 Field Caption"));
                    currfieldLookUpBuffer := fieldLookUpBufferSelected;
                end;
            Rec.FieldNo("Source 2 Field Caption"):
                begin
                    Selected.SetTable(fieldLookUpBufferSelected);
                    Rec."Source 2 Field No." := fieldLookUpBufferSelected."Field No.";
                    Rec."Source 2 Field Caption" := CopyStr(fieldLookUpBufferSelected."Field Caption", 1, MaxStrLen(Rec."Source 2 Field Caption"));
                    currfieldLookUpBuffer := fieldLookUpBufferSelected;
                end;
            else
                Error('unhandled case');
        end;
    end;

    internal procedure OnValidateOnAfterLookUp(fromFieldNo: Integer; var currfieldLookUpBuffer: Record DMTfieldLookUpBuffer)
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        importConfigMgt: Codeunit DMTImportConfigMgt;
        TargetFieldNames: Dictionary of [Integer, Text];
        foundAtIndex: Integer;
    begin
        // Field Name from user input (e.g. Copy & Paste)
        Rec.TestField("Imp.Conf.Header ID");
        if (currfieldLookUpBuffer."Field No." = 0) then begin
            ImportConfigHeader.Get(Rec."Imp.Conf.Header ID");
            ImportConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
            TargetFieldNames := importConfigMgt.CreateTargetFieldNamesDict(ImportConfigLine, false);
            if fromFieldNo = rec.FieldNo("Target 1 Field Caption") then begin
                if TargetFieldNames.Values.Contains(Rec."Target 1 Field Caption") then begin
                    foundAtIndex := TargetFieldNames.Values.IndexOf(Rec."Target 1 Field Caption");
                    Rec."Target 1 Field No." := TargetFieldNames.Keys.Get(foundAtIndex);
                    Rec."Target 1 Field Caption" := CopyStr(TargetFieldNames.Values.Get(foundAtIndex), 1, MaxStrLen(Rec."Target 1 Field Caption"));
                end;
            end;
            if fromFieldNo = rec.FieldNo("Target 2 Field Caption") then begin
                if TargetFieldNames.Values.Contains(Rec."Target 2 Field Caption") then begin
                    foundAtIndex := TargetFieldNames.Values.IndexOf(Rec."Target 2 Field Caption");
                    Rec."Target 2 Field No." := TargetFieldNames.Keys.Get(foundAtIndex);
                    Rec."Target 2 Field Caption" := CopyStr(TargetFieldNames.Values.Get(foundAtIndex), 1, MaxStrLen(Rec."Target 2 Field Caption"));
                end;
            end;
        end;

        // Field Name Selected from selection
        if currfieldLookUpBuffer."Field No." <> 0 then
            case fromFieldNo of
                Rec.FieldNo("Target 1 Field Caption"):
                    begin
                        if (currfieldLookUpBuffer."Field Caption" = '') then
                            exit;
                        Rec."Target 1 Field No." := currfieldLookUpBuffer."Field No.";
                        Rec."Target 1 Field Caption" := CopyStr(currfieldLookUpBuffer."Field Caption", 1, MaxStrLen(Rec."Target 1 Field Caption"));
                    end;
                Rec.FieldNo("Target 2 Field Caption"):
                    begin
                        if (currfieldLookUpBuffer."Field Caption" = '') then
                            exit;
                        Rec."Target 2 Field No." := currfieldLookUpBuffer."Field No.";
                        Rec."Target 2 Field Caption" := CopyStr(currfieldLookUpBuffer."Field Caption", 1, MaxStrLen(Rec."Target 2 Field Caption"));
                    end;
                Rec.FieldNo("Source 1 Field Caption"):
                    begin
                        if (currfieldLookUpBuffer."Field Caption" = '') then
                            exit;
                        Rec."Source 1 Field No." := currfieldLookUpBuffer."Field No.";
                        Rec."Source 1 Field Caption" := CopyStr(currfieldLookUpBuffer."Field Caption", 1, MaxStrLen(Rec."Source 1 Field Caption"));
                    end;
                Rec.FieldNo("Source 2 Field Caption"):
                    begin
                        if (currfieldLookUpBuffer."Field Caption" = '') then
                            exit;
                        Rec."Source 2 Field No." := currfieldLookUpBuffer."Field No.";
                        Rec."Source 2 Field Caption" := CopyStr(currfieldLookUpBuffer."Field Caption", 1, MaxStrLen(Rec."Source 2 Field Caption"));
                    end;
                else
                    Error('unhandled case');
            end;
        Clear(currfieldLookUpBuffer);
    end;

    internal procedure FindReplacementHeaderForPageRec(var replacementHeader: Record DMTReplacementHeader) Found: Boolean
    var
        replacementLine: Record DMTReplacementLine;
    begin
        Clear(replacementHeader);
        replacementLine.Copy(Rec);
        // Source: Table Relation
        if replacementLine."Replacement Code" <> '' then
            if replacementHeader.Get(replacementLine."Replacement Code") then
                exit(true);
        // Source: Filter
        if (replacementLine.GetFilter("Replacement Code") <> '') then
            if replacementHeader.Get(replacementLine.GetRangeMin("Replacement Code")) then
                exit(true);
        // Source: SubPageLink
        replacementLine.FilterGroup(4);
        if (replacementLine.GetFilter("Replacement Code") <> '') then
            if replacementHeader.Get(replacementLine.GetRangeMin("Replacement Code")) then
                exit(true);
    end;

    internal procedure GetNextLineNo(replacmentCode: Code[100]; LineType: Option) nextLineNo: Integer
    var
        replacementLine: Record DMTReplacementLine;
    begin
        nextLineNo := 10000;
        replacementLine.SetRange("Replacement Code", replacmentCode);
        replacementLine.SetRange("Line Type", LineType);
        if replacementLine.FindLast() then
            nextLineNo += replacementLine."Line No.";
    end;
}