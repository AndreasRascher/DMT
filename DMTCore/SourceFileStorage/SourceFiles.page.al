page 91005 DMTSourceFiles
{
    Caption = 'DMT Source Files', Comment = 'de-DE=DMT Quelldateien';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTSourceFileStorage;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("File ID"; Rec."File ID") { Visible = false; Editable = false; }
                field(Name; Rec.Name) { Editable = false; }
                field(Extension; Rec.Extension) { Editable = false; }
                field(Size; Rec.Size) { Editable = false; }
                field("DateTime"; Rec.UploadDateTime) { Editable = false; }
                field(SourceFileFormat; Rec.SourceFileFormat) { }
                field("Data Layout ID"; Rec."Data Layout ID") { }
            }
        }
        area(FactBoxes) { }
    }

    actions
    {
        area(Processing)
        {
            action(UploadFileToDefaultFolder)
            {
                Image = MoveUp;
                Caption = 'Upload File', Comment = 'de-DE=Datei hochladen';
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