page 99999 SourceFiles
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTSourceFileStorage;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("File ID"; Rec."File ID") { Visible = false; }
                field(Name; Rec.Name) { }
                field(Path; Rec.Path) { }
                field(Size; Rec.Size) { }
                field("DateTime"; Rec.UploadDateTime) { }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}