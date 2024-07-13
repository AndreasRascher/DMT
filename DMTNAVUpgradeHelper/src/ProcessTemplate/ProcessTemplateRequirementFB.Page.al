
page 90014 ProcessTemplateRequirementFB
{
    Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
    PageType = ListPart;
    SourceTable = DMTProcessTemplateDetails;
    SourceTableView = where(Type = const(Requirement));
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
                field("Requirement Type"; Rec."Requirement Sub Type") { ApplicationArea = All; }
                field("Req. Src.Filename"; Rec."Req. Src.Filename") { ApplicationArea = All; }
                field("Object Type (Req.)"; Rec."Object Type (Req.)") { ApplicationArea = All; }
                field("Object ID (Req.)"; Rec."Object ID (Req.)") { ApplicationArea = All; }
                field("Object Name (Req.)"; Rec."Object Name (Req.)") { ApplicationArea = All; }
            }
        }
    }
}