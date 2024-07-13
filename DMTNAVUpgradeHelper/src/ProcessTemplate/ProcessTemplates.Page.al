page 90012 DMTProcessTemplateList
{
    Caption = 'DMT Process Templates', Comment = 'de-DE=DMT Prozessvorlagen';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcessTemplate;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { }
                field(Description; Rec.Description) { }
                field("Required Files"; Rec."Required Files Ratio") { StyleExpr = Rec.RequiredFilesStyle; }
                field("Required Objects"; Rec."Required Objects Ratio") { StyleExpr = Rec.RequiredObjectsStyle; }
            }
        }
        area(Factboxes)
        {
            part(ProcessTemplateRequirementFB; ProcessTemplateRequirementFB)
            {
                SubPageLink = "Process Template Code" = field(Code);
            }
            part(ProcessTemplateStepsFB; ProcessTemplateStepsFB)
            {
                SubPageLink = "Process Template Code" = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TransferToProcessingPlan)
            {
                ApplicationArea = All;
                Image = Process;
                Caption = 'Transfer to Processing Plan', Comment = 'de-DE=In Verarbeitungsplan übertragen';
                trigger OnAction()
                var
                    ProcessTemplateLib: Codeunit DMTProcessTemplateLib;
                begin
                    ProcessTemplateLib.TransferToProcessingPlan(Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(TransferToProcessingPlanRef; TransferToProcessingPlan)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        ProcessTemplateLib: Codeunit DMTProcessTemplateLib;
    begin
        ProcessTemplateLib.InsertProcessTemplateData();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.UpdateIndicators();
    end;

}