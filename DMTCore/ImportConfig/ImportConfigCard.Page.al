page 91008 DMTImportConfigCard
{
    Caption = 'DMT Import Config Card', Comment = 'de-DE=Importkonfiguration Karte';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigHeader;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-DE=Allgemein';

                field(ID; Rec.ID) { }
                field(SourceFileID; Rec.SourceFileID) { }
                field("Data Layout Code"; Rec."Data Layout ID")
                {
                    trigger OnValidate()
                    begin
                        CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
                        CurrPage.LinePart.Page.DoUpdate(false);
                    end;
                }
                field("Target Table Caption"; Rec."Target Table Caption") { }
                field("Target Table ID"; Rec."Target Table ID") { }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { }
                field("Import Only New Records"; Rec."Import Only New Records") { }
            }
            part(LinePart; ImportConfigLinePart)
            {
                SubPageLink = "Imp.Conf.Header ID" = field(ID), "Imp.Conf.Header ID Filter" = field("Data Layout ID");
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