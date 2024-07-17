
page 90013 ProcessTemplateStepsFB
{
    Caption = 'Steps', Comment = 'de-DE=Schritte';
    PageType = ListPart;
    SourceTable = DMTProcessTemplateDetail;
    SourceTableView = where(Type = const(Step));
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(RequirementList)
            {
                Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
                field("Processing Plan Type"; Rec."PrPl Type") { ApplicationArea = All; }
                field("Name"; Rec."Name") { ApplicationArea = All; }
            }
        }
    }
}