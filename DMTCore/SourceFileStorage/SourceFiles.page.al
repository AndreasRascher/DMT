page 90005 SourceFiles
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
                field(Extension; Rec.Extension) { }
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
            action(UploadFileToDefaultFolder)
            {
                Image = MoveUp;
                Caption = 'Upload File';
                ApplicationArea = All;
                trigger OnAction()
                var
                    SourceFileMgt: Codeunit DMTSourceFileMgt;
                begin
                    SourceFileMgt.UploadFileIntoFileStorage();
                end;
            }
        }
    }
}