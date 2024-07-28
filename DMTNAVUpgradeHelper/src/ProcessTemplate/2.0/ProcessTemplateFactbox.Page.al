
page 90014 DMTProcessTemplateFactbox
{
    PageType = ListPart;
    SourceTable = Integer;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    ApplicationArea = All;
    UsageCategory = None;
    //     Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
    layout
    {
        area(Content)
        {
            repeater(RequirementListView)
            {
                Visible = IsRequirementListView;
                Enabled = IsRequirementListView;

                Caption = 'Required Files & Objects', Comment = 'de-DE=Benötigte Dateien & Objekte';
                field("Requirement Type"; DataTableMgtGlobal.Get('Requirement Type', Rec.Number, DataTableMgtGlobal.Constant_RequirementList())) { Caption = 'Type', Comment = 'de-DE=Art'; ApplicationArea = All; StyleExpr = lineStyle; }
                field("Name"; DataTableMgtGlobal.Get('Name', Rec.Number, DataTableMgtGlobal.Constant_RequirementList())) { Caption = 'Name', Comment = 'de-DE=Name'; ApplicationArea = All; StyleExpr = lineStyle; }
            }

            repeater(StepsView)
            {
                Visible = IsStepView;
                Enabled = IsStepView;
                Caption = 'Steps', Comment = 'de-DE=Schritte';
                field("Processing Plan Type"; DataTableMgtGlobal.Get('Processing Plan Type', Rec.Number, DataTableMgtGlobal.Constant_StepsView())) { Caption = 'Type', Comment = 'de-DE=Art'; ApplicationArea = All; StyleExpr = lineStyle; }
                field("Step Name"; DataTableMgtGlobal.Get('Name', Rec.Number, DataTableMgtGlobal.Constant_StepsView())) { Caption = 'Name', Comment = 'de-DE=Name'; ApplicationArea = All; StyleExpr = lineStyle; }
            }
            repeater(ReqData)
            {
                Visible = IsReqDataView;
                Enabled = IsReqDataView;
                Caption = 'Data Requirements', Comment = 'de-DE=Erforderliche Daten';
                field("Target Table Caption"; DataTableMgtGlobal.Get('Table', Rec.Number, DataTableMgtGlobal.Constant_ReqData())) { Caption = 'Table', Comment = 'de-DE=Tabelle'; ApplicationArea = All; StyleExpr = lineStyle; }
                field("Field Name"; DataTableMgtGlobal.Get('Field', Rec.Number, DataTableMgtGlobal.Constant_ReqData())) { Caption = 'Field Name', Comment = 'de-DE=Feldname'; ApplicationArea = All; StyleExpr = lineStyle; }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        lineStyle := DataTableMgtGlobal.Get('LineStyle', Rec.Number, '');
    end;


    internal procedure InitAsRequirementsList(templateCode: Text; var dataTableMgt: Codeunit DMTDataTableMgt)
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        lineStyleNew: Text;
    begin
        IsRequirementListView := true;
        IsStepView := false;
        IsReqDataView := false;
        CurrPage.Update(false);

        dataTableMgt.Dispose();
        dataTableMgt.setContext(dataTableMgt.Constant_RequirementList());
        dataTableMgt.setCaptions('Requirement Type', 'Name', 'LineStyle');

        processTemplateSetup.SetRange("Template Code", templateCode);
        if processTemplateSetup.FindSet() then
            repeat
                if processTemplateSetup.IsCodeunitRequirement() then begin
                    setFieldStyle(lineStyleNew, processTemplateSetup.IsCodeunitRequirementFulfilled());
                    dataTableMgt.addLine('Codeunit', processTemplateSetup."Run Codeunit", lineStyleNew);
                end;
                if processTemplateSetup.IsSourceFileRequirement() then begin
                    setFieldStyle(lineStyleNew, processTemplateSetup.IsSourceFileRequirementFulfilled());
                    dataTableMgt.addLine('Source File', processTemplateSetup."Source File Name", lineStyleNew);
                end;
                if processTemplateSetup.IsTableRequirement() then begin
                    setFieldStyle(lineStyleNew, processTemplateSetup.IsTableRequirementFulfilled());
                    dataTableMgt.addLine('Table', processTemplateSetup."Target Table ID", lineStyleNew);
                end;
            until processTemplateSetup.Next() = 0;

        Rec.SetRange(Number, 1, dataTableMgt.Count());
        DataTableMgtGlobal := dataTableMgt;
        CurrPage.Update(false);
    end;

    internal procedure InitAsStepsView(templateCode: Text; var dataTableMgt: Codeunit DMTDataTableMgt)
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        processingPlanType: Enum DMTProcessingPlanType;
        lineStyleNew: Text;
    begin
        IsRequirementListView := false;
        IsStepView := true;
        IsReqDataView := false;
        CurrPage.Update(false);

        dataTableMgt.Dispose();
        dataTableMgt.setContext(dataTableMgt.Constant_StepsView());
        dataTableMgt.setCaptions('Processing Plan Type', 'Name', 'LineStyle');
        processTemplateSetup.Reset();
        processTemplateSetup.SetRange("Template Code", templateCode);
        if processTemplateSetup.FindSet() then
            repeat
                if processTemplateSetup.tryFindMappedProcessingPlanType(processingPlanType) then begin
                    if processTemplateSetup."Description" = '' then
                        processTemplateSetup."Description" := processTemplateSetup."Source File Name";
                    dataTableMgt.addLine(format(processingPlanType), processTemplateSetup."Description", lineStyleNew);
                end;
            until processTemplateSetup.Next() = 0;
        Rec.SetRange(Number, 1, dataTableMgt.Count());
        DataTableMgtGlobal := dataTableMgt;
        CurrPage.Update(false);
    end;

    internal procedure InitAsReqData(templateCode: Text; var dataTableMgt: Codeunit DMTDataTableMgt)
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        TableMetadata: Record "Table Metadata";
        dataTypeMgt: Codeunit "Data Type Management";
        recordRef: RecordRef;
        fieldRef: FieldRef;
        recordFound: Boolean;
        fieldFound: Boolean;
        fieldHasValue: Boolean;
        tableCaptionText: Text;
        lineStyleNew: Text;
    begin
        IsRequirementListView := false;
        IsStepView := false;
        IsReqDataView := true;
        CurrPage.Update(false);

        dataTableMgt.Dispose();
        dataTableMgt.setContext(dataTableMgt.Constant_ReqData());
        dataTableMgt.setCaptions('Table', 'Field', 'LineStyle');

        processTemplateSetup.SetRange("Template Code", templateCode);
        processTemplateSetup.SetRange("Type", processTemplateSetup.Type::"Req. Setup");
        if processTemplateSetup.FindSet(false) then
            repeat
                Clear(tableCaptionText);
                Clear(fieldFound);
                Clear(recordFound);
                Clear(fieldHasValue);
                tableCaptionText := Format(processTemplateSetup."Target Table ID");
                if TableMetadata.Get(processTemplateSetup."Target Table ID") then begin
                    tableCaptionText := TableMetadata."Caption";
                    recordRef.Open(processTemplateSetup."Target Table ID");
                    recordFound := recordRef.FindFirst();
                    fieldFound := dataTypeMgt.FindFieldByName(recordRef, fieldRef, processTemplateSetup."Field Name");
                    fieldHasValue := format(fieldRef.Value) <> '';
                end;

                case true of
                    (not recordFound) or (not fieldHasValue):
                        lineStyleNew := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    fieldHasValue:
                        lineStyleNew := Format(Enum::DMTFieldStyle::"Bold + Green");
                    else
                        lineStyleNew := Format(Enum::DMTFieldStyle::None);
                end;
                dataTableMgt.addLine(tableCaptionText, processTemplateSetup."Field Name", lineStyleNew);
            until processTemplateSetup.Next() = 0;

        Rec.SetRange(Number, 1, dataTableMgt.Count());
        DataTableMgtGlobal := dataTableMgt;
        CurrPage.Update(false);
    end;

    local procedure setFieldStyle(var lineStyleNew: Text; IsRequirementFulfilled: Boolean)
    begin
        lineStyleNew := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
        if IsRequirementFulfilled then
            lineStyleNew := Format(Enum::DMTFieldStyle::"Bold + Green");
    end;

    var
        DataTableMgtGlobal: Codeunit DMTDataTableMgt;
        IsStepView, IsRequirementListView, IsReqDataView : Boolean;
        lineStyle: Text;
}