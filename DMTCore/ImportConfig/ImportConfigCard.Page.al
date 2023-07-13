page 91008 DMTImportConfigCard
{
    Caption = 'DMT Import Config Card', Comment = 'de-DE=Importkonfiguration Karte';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigHeader;
    DelayedInsert = true;
    DataCaptionExpression = Rec."Target Table Caption";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-DE=Allgemein';

                field(ID; Rec.ID) { Visible = false; }
                field(SourceFileID; Rec.SourceFileID) { ShowMandatory = true; }
                field("Data Layout Code"; Rec."Data Layout ID")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
                        CurrPage.LinePart.Page.DoUpdate(false);
                    end;
                }
                field("Target Table Caption"; Rec."Target Table Caption") { }
                field("Target Table ID"; Rec."Target Table ID") { ShowMandatory = true; }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { }
                field("Import Only New Records"; Rec."Import Only New Records") { }
            }
            part(LinePart; DMTImportConfigLinePart)
            {
                SubPageLink = "Imp.Conf.Header ID" = field(ID);
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
        CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
        CurrPage.LinePart.Page.DoUpdate(false);
    end;

    // trigger OnAfterGetCurrRecord()
    // begin
    //     CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
    //     CurrPage.LinePart.Page.DoUpdate(false);
    // end;
}