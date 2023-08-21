page 91019 DMTReplacementAssigmentPart
{
    Caption = 'Assignments', Comment = 'de-DE=Zuordnung';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTReplacementLine;
    SourceTableView = where("Line Type" = const(Assignment));
    AutoSplitKey = true;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Imp.Conf.Header ID"; Rec."Imp.Conf.Header ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field("Source Field 1 Caption"; Rec."Source 1 Field Caption")
                {
                    ApplicationArea = All;
                    Enabled = Source1Enabled;
                    LookupPageId = DMTFieldLookup;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field("Source 2 Field Caption"; Rec."Source 2 Field Caption")
                {
                    ApplicationArea = All;
                    Enabled = Source2Enabled;
                    Visible = Source2Visible;
                    LookupPageId = DMTFieldLookup;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 2 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 2 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field("Target 1 Field Caption"; Rec."Target 1 Field Caption")
                {
                    ApplicationArea = All;
                    Enabled = Target1Enabled;
                    LookupPageId = DMTFieldLookup;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field("Target 2 Field Caption"; Rec."Target 2 Field Caption")
                {
                    ApplicationArea = All;
                    Enabled = Target2Enabled;
                    Visible = Target2Visible;
                    LookupPageId = DMTFieldLookup;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 2 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 2 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddFieldMapping)
            {
                Caption = 'Add Field Mapping', Comment = 'de-DE=Feldmapping hinzufügen';
                Image = Add;
                ApplicationArea = All;
                trigger OnAction()
                begin
                end;
            }
            action(LoadListOfUniqueValues)
            {
                Caption = 'Import column values', comment = 'de-DE=Spaltenwerte importieren';
                Image = Column;
                ApplicationArea = All;
                trigger OnAction()
                var
                // genBuffTable: Record DMTGenBuffTable;
                // importConfigHeader: Record DMTImportConfigHeader;
                // importConfigLine: Record DMTImportConfigLine;
                // replacementRule: Record DMTReplacement;
                // uniqueValues: List of [Text];
                // uniqueValue: Text;
                begin
                    // importConfigHeader.Get(rec."Imp.Conf.Header ID");
                    // importConfigLine.Get(importConfigHeader.ID, rec."Compare Value 1 Field No.");
                    // uniqueValues := genBuffTable.GetUniqueColumnValues(importConfigLine);
                    // foreach uniqueValue in uniqueValues do begin
                    //     replacementRule.init();
                    //     replacementRule.Code := Rec.Code;
                    //     replacementRule."Line Type" := replacementRule."Line Type"::Rule;
                    //     replacementRule."Line No." := Rec.getNextLineNo(replacementRule.Code, replacementRule."Line Type");
                    //     replacementRule."Comp.Value 1" := CopyStr(uniqueValue, 1, MaxStrLen(rec."Comp.Value 1"));
                    //     replacementRule.Insert();
                    // end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        EnableControls();
    end;

    procedure SetVisibility(DMTReplacementHeader: Record DMTReplacementHeader)
    begin
        Source2Visible := DMTReplacementHeader."No. of Source Values" = DMTReplacementHeader."No. of Source Values"::"2";
        Target2Visible := DMTReplacementHeader."No. of Values to modify" = DMTReplacementHeader."No. of Values to modify"::"2";
        // CurrPage.Update(false);
    end;

    procedure EnableControls()
    begin
        Source1Enabled := Rec."Imp.Conf.Header ID" <> 0;
        Source2Enabled := Rec."Imp.Conf.Header ID" <> 0;
        Target1Enabled := Rec."Imp.Conf.Header ID" <> 0;
        Target2Enabled := Rec."Imp.Conf.Header ID" <> 0;
    end;

    var
        DataLayoutLineGlobal: Record DMTDataLayoutLine;
        Source1Enabled, Source2Enabled, Target1Enabled, Target2Enabled : Boolean;
        Source2Visible, Target2Visible : Boolean;
}