page 90015 DMTProcessTemplateSetup
{
    Caption = 'DMT Process Template Setup', Comment = 'de-DE=DMT Prozessvorlagen Einrichtung';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcessTemplateSetup;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Template Code"; Rec."Template Code") { StyleExpr = lineStyleExpr; }
                field("Line No."; Rec."Line No.") { }
                field("Type"; Rec."Type")
                {
                    StyleExpr = lineStyleExpr;
                    trigger OnValidate()
                    begin
                        UpdateMandatoryIndicator();
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
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
    trigger OnOpenPage()
    var
        processTemplateLib: Codeunit DMTProcessTemplateLib;
    begin
        processTemplateLib.InitDefaults();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateMandatoryIndicator();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateMandatoryIndicator();
        case true of
            (Rec.Type = Rec.Type::Group):
                lineStyleExpr := Format(Enum::DMTFieldStyle::Bold);
            else
                lineStyleExpr := Format(Enum::DMTFieldStyle::None);
        end;
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

}