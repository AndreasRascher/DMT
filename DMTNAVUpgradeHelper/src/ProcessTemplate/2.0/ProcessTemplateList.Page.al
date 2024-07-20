page 90012 DMTProcessTemplateList
{
    Caption = 'DMT Process Templates', Comment = 'de-DE=DMT Prozessvorlagen';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcTemplSelection;
    SourceTableTemporary = true;

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
            part(ProcessTemplateRequirementFB; ProcessTemplateRequirementFB) { }
            part(ProcessTemplateStepsFB; ProcessTemplateStepsFB) { }
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
                    // ProcessTemplateLib.TransferToProcessingPlan(Rec);
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
        processTemplateSetup: Record DMTProcessTemplateSetup;
        TemplateCodeList: List of [Text[150]];
        templateCode: Text[150];
    begin
        if processTemplateSetup.FindSet() then
            repeat
                if processTemplateSetup."Template Code" <> '' then
                    if not TemplateCodeList.Contains(processTemplateSetup."Template Code") then
                        TemplateCodeList.Add(processTemplateSetup."Template Code");
            until processTemplateSetup.Next() = 0;
        processTemplateSetup.Reset();
        foreach templateCode in TemplateCodeList do begin
            processTemplateSetup.SetRange("Template Code", templateCode);
            processTemplateSetup.FindFirst();
            Rec.Code := processTemplateSetup."Template Code";
            Rec.Description := processTemplateSetup."PrPl Description";
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        // Rec.UpdateIndicators();
    end;

    trigger OnAfterGetCurrRecord()
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.initTemplateSetupFor(Rec.Code);
        CurrPage.ProcessTemplateRequirementFB.Page.Set(processTemplateSetup);
        CurrPage.ProcessTemplateStepsFB.Page.Set(processTemplateSetup);
    end;

}