page 91024 DMTReplacementCard
{
    Caption = 'DMT Replacement Card', comment = 'de-DE=DMT Ersetzungen Karte';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTReplacementHeader;
    DataCaptionExpression = Rec."Code" + ' ' + Rec.Description;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-DE=Allgemein';
                field(Code; Rec.Code) { }
                field(Description; Rec.Description) { Importance = Promoted; }
                field("Replacement Type"; Rec."Replacement Type") { }
            }
            group("Field Setup")
            {
                Caption = 'Field Setup', Comment = 'de-DE=Feldeinrichtung';
                group(InnerFieldSetup)
                {
                    ShowCaption = false;
                    grid(NoOfValuesGrid)
                    {
                        ShowCaption = false;
                        GridLayout = Columns;
                        group(NoOfValuesGrid_Col1)
                        {
                            ShowCaption = false;
                            field("No. of Compare Values"; Rec."No. of Source Values")
                            {
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    UpdateLineParts(Rec);
                                end;
                            }
                        }
                        group(NoOfValuesGrid_Col2)
                        {
                            ShowCaption = false;
                            field("No. of fields to modify"; Rec."No. of Values to modify")
                            {
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    UpdateLineParts(Rec);
                                end;
                            }
                        }
                    }
                    grid(FieldDefGrid)
                    {
                        ShowCaption = false;
                        GridLayout = Rows;
                        group(GridLabels)
                        {
                            Caption = ' ', Locked = true;
                            label(FieldCaption) { Caption = 'Caption', Comment = 'de-DE=Feldcaption'; }
                            label("Rel.to Table ID") { Caption = 'Rel.to Table ID', Comment = 'de-DE=Rel. zu Tab.ID'; }
                            label("Rel.to Table Name") { Caption = 'Rel.to Table', Comment = 'de-DE=Rel. zu Tabelle'; }
                        }
                        group(FromField1Group)
                        {
                            Caption = 'Compare Value 1', Comment = 'de-DE=Vergleichswert 1';
                            field("Comp.Fld.1 Caption"; Rec."Comp.Val.1 Caption") { ShowCaption = false; }
                        }
                        group(FromField2Group)
                        {
                            Caption = 'Compare Value 2', Comment = 'de-DE=Vergleichswert 2';
                            Visible = (Rec."No. of Source Values" = Rec."No. of Source Values"::"2");
                            field("Comp.Fld.2 Caption"; Rec."Comp.Val.2 Caption") { ShowCaption = false; }
                        }
                        group(ToFieldGroup1)
                        {
                            Caption = 'New Value 1', Comment = 'de-DE=Neuer Wert 1';
                            field("New Value 1 Caption"; Rec."New Value 1 Caption") { ShowCaption = false; }
                            field("Rel.to Table ID (New Val.1)"; Rec."Rel.to Table ID (New Val.1)") { ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.1)"; Rec."Rel.to Table Cpt.(New Val.1)") { ShowCaption = false; }
                        }
                        group(ToFieldGroup2)
                        {
                            Visible = (Rec."No. of Values to modify" = Rec."No. of Values to modify"::"2");
                            Caption = 'New Value 2', Comment = 'de-DE=Neuer Wert 2';
                            field("New Value 2 Caption"; Rec."New Value 2 Caption") { ShowCaption = false; }
                            field("Rel.to Table ID (New Val.2)"; Rec."Rel.to Table ID (New Val.2)") { ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.2)"; Rec."Rel.to Table Cpt.(New Val.2)") { ShowCaption = false; }
                        }
                    }
                }
            }
            part(ReplacementAssigments; DMTReplacementAssignmentPart)
            {
                SubPageLink = "Replacement Code" = field(Code);
            }
            part(ReplacementRulePart; DMTReplacementRulePart)
            {
                SubPageLink = "Replacement Code" = field(Code);
            }
        }

        area(Factboxes) { }
    }

    actions
    {
    }
    trigger OnFindRecord(Which: Text): Boolean
    var
        found: Boolean;
    begin
        found := Rec.Find(Which);
        UpdateLineParts(Rec);
        exit(found);
    end;

    // trigger OnAfterGetCurrRecord()
    // begin
    //     UpdateLineParts();
    // end;

    procedure UpdateLineParts(replacementHeader: Record DMTReplacementHeader)
    begin
        CurrPage.ReplacementAssigments.Page.SetVisibility(replacementHeader);
        CurrPage.ReplacementRulePart.Page.SetVisibility(replacementHeader);
    end;
}