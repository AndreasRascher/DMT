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
                field("Line No."; Rec."Line No.") { StyleExpr = lineStyleExpr; }
                field("Source File Name"; Rec."Source File Name") { StyleExpr = lineStyleExpr; }
                field("PrPl Type"; Rec."PrPl Type") { StyleExpr = lineStyleExpr; }
                field("PrPl Indentation"; Rec."PrPl Indentation") { StyleExpr = lineStyleExpr; }
                field("PrPl Description"; Rec."PrPl Description") { StyleExpr = lineStyleExpr; }
                field("NAV Source Table No."; Rec."NAV Source Table No.") { StyleExpr = lineStyleExpr; }
                field("PrPl Default Target Table ID"; Rec."PrPl Default Target Table ID") { }
                field("PrPl Run Codeunit"; Rec."PrPl Run Codeunit") { StyleExpr = lineStyleExpr; }
                field("PrPl Default Field 1"; Rec."PrPl Default Field 1") { }
                field("PrPl Default Field 2"; Rec."PrPl Default Field 2") { }
                field("PrPl Default Value 1"; Rec."PrPl Default Value 1") { }
                field("PrPl Default Value 2"; Rec."PrPl Default Value 2") { }
                field("PrPl Filter Field 1"; Rec."PrPl Filter Field 1") { }
                field("PrPl Filter Field 2"; Rec."PrPl Filter Field 2") { }
                field("PrPl Filter Value 1"; Rec."PrPl Filter Value 1") { }
                field("PrPl Filter Value 2"; Rec."PrPl Filter Value 2") { }
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

    trigger OnAfterGetRecord()
    begin
        case true of
            (Rec."PrPl Type" = Rec."PrPl Type"::Group):
                lineStyleExpr := Format(Enum::DMTFieldStyle::Bold);
            else
                lineStyleExpr := Format(Enum::DMTFieldStyle::None);
        end;

    end;

    var
        lineStyleExpr: Text;
}