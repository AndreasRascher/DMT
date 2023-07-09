page 91011 DMTDataLayoutCard
{
    Caption = 'DMT Data Layout', Comment = 'de-DE=DMT Datenlayout';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTDataLayout;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-De=Allgemein';
                field(ID; Rec.ID) { }
                field(Name; Rec.Name) { }
                field(SourceFileFormat; Rec.SourceFileFormat)
                {
                    trigger OnValidate()
                    begin
                        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
                        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
                    end;
                }
                group(NAV)
                {
                    field(NAVTableID; Rec.NAVTableID) { }
                }
            }
            part(DMTLayoutLinePart; DMTLayoutLinePart)
            {
                SubPageLink = "Data Layout ID" = field(ID);
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
    end;
}