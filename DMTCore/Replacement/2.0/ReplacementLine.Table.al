table 91012 DMTReplacementLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Replacement Code"; Code[100]) { Caption = 'Replacement Code', Comment = 'de-DE=Ersetzungscode'; NotBlank = true; }
        field(2; "Line Type"; Option) { Caption = 'Line Type', Comment = 'de-DE=Zeilenart'; OptionMembers = Rule,Assignment; }
        field(3; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennr.'; }
        field(20; "Imp.Conf.Header ID"; Integer)
        {
            Caption = 'Imp.Config. ID', Comment = 'de-DE=Import Konfig. ID';
            TableRelation = DMTImportConfigHeader;
            trigger OnValidate()
            var
                importConfigHeader: Record DMTImportConfigHeader;
            begin
                if not importConfigHeader.Get("Imp.Conf.Header ID") then
                    Init()
                else begin
                    "Target Table ID" := importConfigHeader."Target Table ID";
                    "Source File Name" := importConfigHeader."Source File Name";
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
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(31; "Source 1 Field Caption"; Text[80])
        {
            Caption = 'Source 1 Field Caption', Comment = 'de-DE=Herkunftsfeld 1';
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            ValidateTableRelation = false;
        }
        field(32; "Source 2 Field No."; Integer)
        {
            Caption = 'Source 2 Field No.', Comment = 'de-DE=Herkunftsfeld 2 Nr.';
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(33; "Source 2 Field Caption"; Text[80])
        {
            Caption = 'Source 2 Field Caption', Comment = 'de-DE=Herkunftsfeld 2';
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"));
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
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), "Field Look Mode Filter" = const("Look Up Target"));
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
            TableRelation = DMTDataLayoutLine."Column No." where("Import Config. ID Filter" = field("Imp.Conf.Header ID"), "Field Look Mode Filter" = const("Look Up Target"));
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
        ImportConfigLine: Record DMTReplacementLine;
        TempImportConfigLine2: Record DMTReplacementLine temporary;
    begin
        ImportConfigLine.Copy(Rec);
        if ImportConfigLine.FindSet(false) then
            repeat
                LineCount += 1;
                TempImportConfigLine2 := ImportConfigLine;
                TempImportConfigLine2.Insert(false);
            until ImportConfigLine.Next() = 0;
        TempReplacementLine.Copy(TempImportConfigLine2, true);
    end;

    internal procedure OnAfterLookUpField(var Selected: RecordRef; fromFieldNo: Integer; var currDataLayoutLine: Record DMTDataLayoutLine)
    var
        dataLayoutLineSelected: Record DMTDataLayoutLine;
        importConfigHeaderSelected: Record DMTImportConfigHeader;
    begin
        case fromFieldNo of
            Rec.FieldNo("Target 1 Field Caption"):
                begin
                    Selected.SetTable(dataLayoutLineSelected);
                    Rec."Target 1 Field No." := dataLayoutLineSelected."Column No.";
                    Rec."Target 1 Field Caption" := dataLayoutLineSelected.ColumnName;
                    currDataLayoutLine := dataLayoutLineSelected;
                end;
            Rec.FieldNo("Target 2 Field Caption"):
                begin
                    Selected.SetTable(dataLayoutLineSelected);
                    Rec."Target 2 Field No." := dataLayoutLineSelected."Column No.";
                    Rec."Target 2 Field Caption" := dataLayoutLineSelected.ColumnName;
                    currDataLayoutLine := dataLayoutLineSelected;
                end;
            Rec.FieldNo("Source 1 Field Caption"):
                begin
                    Selected.SetTable(dataLayoutLineSelected);
                    Rec."Source 1 Field No." := dataLayoutLineSelected."Column No.";
                    Rec."Source 1 Field Caption" := dataLayoutLineSelected.ColumnName;
                    currDataLayoutLine := dataLayoutLineSelected;
                end;
            Rec.FieldNo("Source 2 Field Caption"):
                begin
                    Selected.SetTable(dataLayoutLineSelected);
                    Rec."Source 2 Field No." := dataLayoutLineSelected."Column No.";
                    Rec."Source 2 Field Caption" := dataLayoutLineSelected.ColumnName;
                    currDataLayoutLine := dataLayoutLineSelected;
                end;
            else
                Error('unhandled case');
        end;
    end;

    internal procedure OnValidateOnAfterLookUp(fromFieldNo: Integer; var currDataLayoutLine: Record DMTDataLayoutLine)
    begin
        case fromFieldNo of
            Rec.FieldNo("Target 1 Field Caption"):
                begin
                    if (currDataLayoutLine.ColumnName = '') then
                        exit;
                    Rec."Target 1 Field No." := currDataLayoutLine."Column No.";
                    Rec."Target 1 Field Caption" := currDataLayoutLine.ColumnName;
                end;
            Rec.FieldNo("Target 2 Field Caption"):
                begin
                    if (currDataLayoutLine.ColumnName = '') then
                        exit;
                    Rec."Target 2 Field No." := currDataLayoutLine."Column No.";
                    Rec."Target 2 Field Caption" := currDataLayoutLine.ColumnName;
                end;
            Rec.FieldNo("Source 1 Field Caption"):
                begin
                    if (currDataLayoutLine.ColumnName = '') then
                        exit;
                    Rec."Source 1 Field No." := currDataLayoutLine."Column No.";
                    Rec."Source 1 Field Caption" := currDataLayoutLine.ColumnName;
                end;
            Rec.FieldNo("Source 2 Field Caption"):
                begin
                    if (currDataLayoutLine.ColumnName = '') then
                        exit;
                    Rec."Source 2 Field No." := currDataLayoutLine."Column No.";
                    Rec."Source 2 Field Caption" := currDataLayoutLine.ColumnName;
                end;
            else
                Error('unhandled case');
        end;
        Clear(currDataLayoutLine);
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