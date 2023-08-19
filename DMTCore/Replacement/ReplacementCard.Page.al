page 91020 DMTReplacementCard
{
    Caption = 'DMT Replacement Card', comment = 'de-DE=DMT Ersetzungen Karte';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTReplacement;
    DataCaptionExpression = Rec."Code" + ' ' + Rec.Description;
    SourceTableView = where("Line Type" = const(Replacement), "Line No." = const(0));

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-DE=Allgemein';
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; Importance = Promoted; }
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
                            field("No. of Compare Values"; Rec."No. of Compare Values")
                            {
                                ApplicationArea = All;
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    EnableControls(xRec, Rec);
                                end;
                            }
                        }
                        group(NoOfValuesGrid_Col2)
                        {
                            ShowCaption = false;
                            field("No. of fields to modify"; Rec."No. of Values to modify")
                            {
                                ApplicationArea = All;
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    EnableControls(xRec, Rec);
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
                            label(FieldCaption) { Caption = 'Caption'; }
                            label("Rel.to Table ID") { Caption = 'Rel.to Table ID'; }
                            label("Rel.to Table Name") { Caption = 'Rel.to Table'; }
                        }
                        group(FromField1Group)
                        {
                            Caption = 'Compare Value 1', Comment = 'de-DE=Vergleichswert 1';
                            field("Comp.Fld.1 Caption"; Rec."Comp.Val.1 Caption") { ApplicationArea = All; ShowCaption = false; }

                        }
                        group(FromField2Group)
                        {
                            Caption = 'Compare Value 2', Comment = 'de-DE=Vergleichswert 2';
                            Visible = CompareValue2_Visible;
                            field("Comp.Fld.2 Caption"; Rec."Comp.Val.2 Caption") { ApplicationArea = All; ShowCaption = false; }
                        }
                        group(ToFieldGroup1)
                        {
                            Caption = 'New Value 1', Comment = 'de-DE=Neuer Wert 1';
                            field("New Value 1 Caption"; Rec."New Value 1 Caption") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table ID (New Val.1)"; Rec."Rel.to Table ID (New Val.1)") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.1)"; Rec."Rel.to Table Cpt.(New Val.1)") { ApplicationArea = All; ShowCaption = false; }
                        }
                        group(ToFieldGroup2)
                        {
                            Visible = NewValue2_Visible;
                            Caption = 'New Value 2', Comment = 'de-DE=Neuer Wert 2';
                            ;
                            field("New Value 2 Caption"; Rec."New Value 2 Caption") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table ID (New Val.2)"; Rec."Rel.to Table ID (New Val.2)") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.2)"; Rec."Rel.to Table Cpt.(New Val.2)") { ApplicationArea = All; ShowCaption = false; }
                        }
                    }
                }
            }
            part(Rules; DMTReplacementRulesPart)
            {
                SubPageLink = Code = field(Code);
                UpdatePropagation = SubPart;
            }
            part(Assignments; DMTReplacementAssigmentsPart)
            {
                SubPageLink = Code = field(Code), "Line Type" = const(Assignment);
                ApplicationArea = All;
            }
        }
    }

    actions
    { }

    internal procedure EnableControls(ReplacementOld: Record DMTReplacement; Replacement: Record DMTReplacement)
    begin
        if Replacement.IsEqual(ReplacementOld) then
            exit;
        if SetVisiblity(Replacement) then
            CurrPage.Update();
    end;

    local procedure SetVisiblity(var ReplacementHeader: Record DMTReplacement): Boolean
    begin
        CompareValue2_Visible := ReplacementHeader."No. of Compare Values" in [ReplacementHeader."No. of Compare Values"::"2"];
        NewValue2_Visible := ReplacementHeader."No. of Values to modify" in [ReplacementHeader."No. of Values to modify"::"2"];
        CurrPage.Rules.Page.EnableControls(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls(xRec, Rec);
    end;

    var
        CompareValue2_Visible, NewValue2_Visible : Boolean;
}