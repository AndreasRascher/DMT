page 90012 DMTProcessTemplateList
{
    Caption = 'DMT Process Templates', Comment = 'de-DE=DMT Prozessvorlagen';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcTemplSelection;
    SourceTableTemporary = true;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Template Code") { }
                field(Description; Rec.Description) { }
                field("Required Files"; Rec."Required Files Ratio") { StyleExpr = Rec.RequiredFilesStyle; }
                field("Required Objects"; Rec."Required Objects Ratio") { StyleExpr = Rec.RequiredObjectsStyle; }
                field("Required Data"; Rec."Required Data Ratio") { StyleExpr = Rec.RequiredDataStyle; }
            }
        }
        area(Factboxes)
        {
            part(ProcessTemplateRequirementFB; DMTProcessTemplateFactbox) { Caption = 'Required Files & Objects', Comment = 'de-DE=Benötigte Dateien & Objekte'; }
            part(ProcessTemplateDataReqsFB; DMTProcessTemplateFactbox) { Caption = 'Data Requirements', Comment = 'de-DE=Benötigte Daten'; Visible = ProcessTemplateDataReqsFB_Visible; }
            part(ProcessTemplateStepsFB; DMTProcessTemplateFactbox)
            {
                Caption = 'Steps', Comment = 'de-DE=Schritte';
                SubPageLink = Number = field(no) }
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
                    processingPlan: Page DMTProcessingPlan;
                begin
                    ProcessTemplateLib.TransferToProcessingPlan(Rec."Template Code");
                    processingPlan.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(TransferToProcessingPlanRef; TransferToProcessingPlan) { }
        }
    }

    trigger OnOpenPage()
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        // processTemplateLib: codeunit DMTProcessTemplateLib;
        // downloadedFile: Codeunit "Temp Blob";
        TemplateCodeList: List of [Text[150]];
        templateCode: Text[150];
    begin
        // if processTemplateSetup.IsEmpty then begin
        //     processTemplateLib.downloadProcessTemplateXLSFromGitHub(downloadedFile);
        //     processTemplateLib.ImportTemplateSetupFromExcel(downloadedFile);
        // end;

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
            Rec."Template Code" := processTemplateSetup."Template Code";
            Rec.Description := processTemplateSetup."Description";
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetRecord()
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.SetRange("Template Code", Rec."Template Code");
        processTemplateSetup.SetRange("Type", processTemplateSetup.Type::"Req. Setup");
        ProcessTemplateDataReqsFB_Visible := not processTemplateSetup.IsEmpty;
        Rec.UpdateIndicators();
    end;

    trigger OnAfterGetCurrRecord()
    begin

    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        tempProcTemplSelection: Record DMTProcTemplSelection temporary;
        found: Boolean;
    begin
        tempProcTemplSelection.Copy(Rec, true);
        found := Rec.Find(Which);
        updateFactBoxes();
        exit(found);
    end;

    local procedure updateFactBoxes()
    var
        DataTableMgt_ReqList: Codeunit DMTDataTableMgt;
        DataTableMgt_Steps: Codeunit DMTDataTableMgt;
        DataTableMgt_DataReq: Codeunit DMTDataTableMgt;
    begin
        CurrPage.ProcessTemplateRequirementFB.Page.doUpdate();
        CurrPage.ProcessTemplateRequirementFB.Page.InitAsRequirementsList(Rec."Template Code", DataTableMgt_ReqList);
        CurrPage.ProcessTemplateRequirementFB.Page.doUpdate();
        CurrPage.ProcessTemplateStepsFB.Page.InitAsStepsView(Rec."Template Code", DataTableMgt_Steps);
        CurrPage.ProcessTemplateStepsFB.Page.doUpdate();
        CurrPage.ProcessTemplateDataReqsFB.Page.InitAsReqData(Rec."Template Code", DataTableMgt_DataReq);
        CurrPage.ProcessTemplateDataReqsFB.Page.doUpdate();
    end;

    var
        ProcessTemplateDataReqsFB_Visible: Boolean;
}