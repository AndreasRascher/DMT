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
                            field("No. of Compare Values"; Rec."No. of Source Values")
                            {
                                ApplicationArea = All;
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    UpdateAssignmentPart();
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
                                    UpdateAssignmentPart();
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
                            // Visible = CompareValue2_Visible;
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
                            // Visible = NewValue2_Visible;
                            Caption = 'New Value 2', Comment = 'de-DE=Neuer Wert 2';
                            ;
                            field("New Value 2 Caption"; Rec."New Value 2 Caption") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table ID (New Val.2)"; Rec."Rel.to Table ID (New Val.2)") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.2)"; Rec."Rel.to Table Cpt.(New Val.2)") { ApplicationArea = All; ShowCaption = false; }
                        }
                    }
                }
            }
            part(ReplacementAssigments; DMTReplacementAssigmentsPart)
            {
                SubPageLink = "Replacement Code" = field(Code);
            }
        }

        area(Factboxes)
        {

        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdateAssignmentPart();
    end;

    procedure UpdateAssignmentPart()
    begin
        CurrPage.ReplacementAssigments.Page.EnableControls(Rec);
    end;
}