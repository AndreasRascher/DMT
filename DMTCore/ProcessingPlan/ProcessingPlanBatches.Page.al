page 91027 DMTProcessingPlanBatches
{
    Caption = 'Processing Plan Batches', Comment = 'de-DE=Verarbeitungsplan Buch.-Blätter';
    Editable = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = DMTProcessingPlanBatch;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the name of this project journal. You can enter a maximum of 10 characters, both numbers and letters.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a description of this journal.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Journal")
            {
                ApplicationArea = Jobs;
                Caption = 'Edit Journal', Comment = 'de-DE=Buch.-Blatt bearbeiten';
                Image = OpenJournal;
                ShortCutKey = 'Return';

                trigger OnAction()
                var
                    processingPlan: Record DMTProcessingPlan;
                begin
                    ProcessingPlanMgt.OpenJnl(rec.Name, processingPlan);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref("Edit Journal_Promoted"; "Edit Journal") { }
            }
        }
    }

    trigger OnOpenPage()
    begin
    end;

    var
        ProcessingPlanMgt: Codeunit DMTProcessingPlanMgt;
}

