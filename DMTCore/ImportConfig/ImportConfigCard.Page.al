page 90008 DMTImportConfigCard
{
    Caption = 'DMT Import Config Card', Comment = 'de-DE=Importkonfiguration Karte';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTImportConfigHeader;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-DE=Allgemein';

                field(ID; Rec.ID) { }
                field("Target Table Caption"; Rec."Target Table Caption") { }
                field("Target Table ID"; Rec."Target Table ID") { }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { }
                field("Data Layout Code"; Rec."Data Layout Code") { }
                field("Import Only New Records"; Rec."Import Only New Records") { }
            }
            part(LinePart; ImportConfigLinePart)
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
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
        CurrPage.LinePart.Page.DoUpdate(false);
    end;
}