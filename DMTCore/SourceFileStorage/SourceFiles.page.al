page 91005 SourceFiles
{
    Caption = 'DMT Source Files', Comment = 'de-DE=DMT Quelldateien';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTSourceFileStorage;
    Editable = false;

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
        area(FactBoxes)
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
                Caption = 'Upload File', Comment = 'de=DE=Datei hochladen';
                ApplicationArea = All;
                trigger OnAction()
                var
                    SourceFileMgt: Codeunit DMTSourceFileMgt;
                begin
                    SourceFileMgt.UploadFileIntoFileStorage();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Upload; UploadFileToDefaultFolder) { }
        }
    }
}