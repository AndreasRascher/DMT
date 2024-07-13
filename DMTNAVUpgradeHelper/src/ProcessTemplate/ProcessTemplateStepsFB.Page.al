
page 90013 ProcessTemplateStepsFB
{
    Caption = 'Steps', Comment = 'de-DE=Schritte';
    PageType = ListPart;
    SourceTable = DMTProcessTemplateDetails;
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
                field("Requirement Type"; Rec."Requirement Sub Type") { ApplicationArea = All; }
                field("Req. Src.Filename"; Rec."Name") { ApplicationArea = All; }
                field("Object Type (Req.)"; Rec."Object Type (Req.)") { ApplicationArea = All; }
                field("Object ID (Req.)"; Rec."Object ID (Req.)") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
            }
        }
    }
}