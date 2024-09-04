page 50171 DMTProcessTemplateSetup
{
    Caption = 'DMT Process Template Setup', Comment = 'de-DE=DMT Prozessvorlagen Einrichtung';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcessTemplateSetup;
    AutoSplitKey = true;
    SourceTableView = sorting("Sorting No.", "Template Code", "Line No.");

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                IndentationControls = "Template Code";
                IndentationColumn = Rec.Indentation;
                field("Template Code"; Rec."Template Code") { StyleExpr = lineStyleExpr; }
                // field("Line No."; Rec."Line No.") { }
                field("Sorting No."; Rec."Sorting No.") { }
                field("Type"; Rec."Type")
                {
                    StyleExpr = lineStyleExpr;
                    trigger OnValidate()
                    begin
                        UpdateMandatoryIndicator();
                        UpdateLineStyle();
                    end;
                }
                field("Source File Name"; Rec."Source File Name") { ShowMandatory = SourceFileName_Mandatory; }
                field(Indentation; Rec.Indentation) { ShowMandatory = Description_Mandatory; }
                field(Description; Rec.Description) { StyleExpr = lineStyleExpr; ShowMandatory = Description_Mandatory; }
                field("Field Name"; Rec."Field Name") { ShowMandatory = FieldName_Mandatory; }
                field("Filter Expression"; Rec."Filter Expression") { ShowMandatory = FilterExpression_Mandatory; }
                field("Default Value"; Rec."Default Value") { ShowMandatory = DefaultValue_Mandatory; }
                field("NAV Source Table No."; Rec."NAV Source Table No.") { ShowMandatory = NAVSourceTableNo_Mandatory; }
                field("Run Codeunit"; Rec."Run Codeunit") { ShowMandatory = RunCodeunit_Mandatory; }
                field("Target Table ID"; Rec."Target Table ID") { ShowMandatory = TargetTableID_Mandatory; }
            }
            group(SetupRequirementDetails)
            {
                Visible = IsSetupRequirementType;
                ShowCaption = false;
                field("Target Table ID2"; Rec."Target Table ID") { }
                field("Target Table Caption2"; Rec."Target Table Caption") { }
                field("Field Name2"; Rec."Field Name") { }
            }
            group(GroupTypeDetails)
            {
                Visible = IsGroupLineType;
                ShowCaption = false;
                field("Template Code2"; Rec."Template Code") { }
                field("Sorting No.2"; Rec."Sorting No.") { }
            }
            group(FilterDetails)
            {
                Visible = IsFilterType;
                ShowCaption = false;
                field("Field Name3"; Rec."Field Name") { }
                field("Filter Expression2"; Rec."Filter Expression") { }
            }
            group(ImportDetails)
            {
                Visible = IsImportToTargetType;
                ShowCaption = false;
                field("Source File Name3"; Rec."Source File Name") { }
                field("NAV Source Table No.3"; Rec."NAV Source Table No.") { }
                field("Target Table ID3"; Rec."Target Table ID") { }
                field("Target Table Caption3"; Rec."Target Table Caption") { }
            }
        }
        area(Factboxes) { }
    }

    actions
    {
        area(Processing)
        {
            action(XLSXExport)
            {
                Caption = 'Create Backup', Comment = 'de-DE=Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;

                trigger OnAction()
                var
                    processTemplateLib: Codeunit DMTProcessTemplateLib;
                begin
                    processTemplateLib.ExportTemplateSetupToExcel();
                end;
            }
            action(XLSXImport)
            {
                Caption = 'Import Backup', Comment = 'de-DE=Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    processTemplateLib: Codeunit DMTProcessTemplateLib;
                begin
                    processTemplateLib.ImportTemplateSetupFromExcel();
                end;
            }
            action(DownloadDefaultTemplate)
            {
                Caption = 'Download Default Template', Comment = 'de-DE=Standardvorlage herunterladen';
                ApplicationArea = All;
                Image = Download;

                trigger OnAction()
                var
                    processTemplateLib: Codeunit DMTProcessTemplateLib;
                    downloadedFile: Codeunit "Temp Blob";
                    importOption: Option "Replace entries","Add entries";
                begin
                    processTemplateLib.downloadProcessTemplateXLSFromGitHub(downloadedFile, importOption, false);
                    processTemplateLib.ImportTemplateSetupFromExcel(downloadedFile, importOption);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateMandatoryIndicator();
        UpdateLineDetails();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateMandatoryIndicator();
        UpdateLineStyle();
        UpdateLineDetails();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec.prepareNewLine(Rec);
    end;

    local procedure UpdateMandatoryIndicator()
    begin
        case Rec.Type of
            Rec.Type::" ":
                begin
                    resetMandatoryIndicator();
                end;
            Rec.Type::"Default Value":
                begin
                    resetMandatoryIndicator();
                    FieldName_Mandatory := true;
                    DefaultValue_Mandatory := true;
                end;
            Rec.Type::"Filter":
                begin
                    resetMandatoryIndicator();
                    FieldName_Mandatory := true;
                    FilterExpression_Mandatory := true;
                end;
            Rec.Type::Group:
                begin
                    resetMandatoryIndicator();
                    Description_Mandatory := true;
                end;
            Rec.Type::"Import Buffer",
            Rec.Type::"Import Buffer+Target",
            Rec.Type::"Import Target":
                begin
                    resetMandatoryIndicator();
                    SourceFileName_Mandatory := true;
                end;
            Rec.Type::"Run Codeunit":
                begin
                    resetMandatoryIndicator();
                    RunCodeunit_Mandatory := true;
                end;
            Rec.Type::"Req. Setup":
                begin
                    resetMandatoryIndicator();
                    TargetTableID_Mandatory := true;
                end;
        end;
    end;

    local procedure resetMandatoryIndicator()
    begin
        Description_Mandatory := false;
        SourceFileName_Mandatory := false;
        FieldName_Mandatory := false;
        FilterExpression_Mandatory := false;
        DefaultValue_Mandatory := false;
        NAVSourceTableNo_Mandatory := false;
        RunCodeunit_Mandatory := false;
        TargetTableID_Mandatory := false;
    end;

    local procedure UpdateLineStyle()
    begin
        case true of
            (Rec.Type = Rec.Type::Group):
                lineStyleExpr := Format(Enum::DMTFieldStyle::Bold);
            else
                lineStyleExpr := Format(Enum::DMTFieldStyle::None);
        end;
    end;

    local procedure UpdateLineDetails()
    begin
        IsSetupRequirementType := Rec.Type = Rec.Type::"Req. Setup";
        IsGroupLineType := Rec.Type = Rec.Type::Group;
        IsFilterType := Rec.Type = Rec.Type::Filter;
        IsImportToTargetType := Rec.Type in [Rec.Type::"Import Buffer+Target", Rec.Type::"Import Target"];
    end;

    var
        lineStyleExpr: Text;
        // mandatory boolean fields
        Description_Mandatory: Boolean;
        SourceFileName_Mandatory: Boolean;
        FieldName_Mandatory: Boolean;
        FilterExpression_Mandatory: Boolean;
        DefaultValue_Mandatory: Boolean;
        NAVSourceTableNo_Mandatory: Boolean;
        RunCodeunit_Mandatory: Boolean;
        TargetTableID_Mandatory: Boolean;
        IsGroupLineType, IsSetupRequirementType, IsFilterType, IsImportToTargetType : Boolean;

}