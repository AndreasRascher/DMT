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
                field(Name; Rec.Name) { }
                field(Extension; Rec.Extension) { }
                field(SizeInKB; Rec.SizeInKB) { }
                field("DateTime"; Rec.UploadDateTime) { }
                field(SourceFileFormat; Rec.SourceFileFormat) { }
                field("Data Layout Name"; Rec."Data Layout Name")
                {
                    ShowMandatory = true;
                    TableRelation = DMTDataLayout where(SourceFileFormat = field(SourceFileFormat));

                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.DataLayoutName_OnAfterLookup(Selected);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.DataLayoutName_OnValidate();
                    end;
                }
            }
        }
        area(FactBoxes) { }
    }

    actions
    {
        area(Processing)
        {
            action(UploadFile)
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
            actionref(Upload; UploadFile) { }
        }
    }
}