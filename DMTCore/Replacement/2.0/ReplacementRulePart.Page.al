page 91020 DMTReplacementRulePart
{
    Caption = 'Rules', Comment = 'de-DE=Regeln';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTReplacementLine;
    SourceTableView = where("Line Type" = const(Rule));
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {

            repeater(Repeater)
            {
                field("Comp.Value 1"; Rec."Comp.Value 1") { StyleExpr = CV1_SpecialCharWarningStyle; }
                field("Comp.Value 2"; Rec."Comp.Value 2") { StyleExpr = CV2_SpecialCharWarningStyle; Visible = Source2Visible; }
                field("New Value 1"; Rec."New Value 1") { StyleExpr = NV1_SpecialCharWarningStyle; }
                field("New Value 2"; Rec."New Value 2") { StyleExpr = NV2_SpecialCharWarningStyle; Visible = Target2Visible; }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        setStyles();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        setStyles();
    end;

    procedure SetVisibility(replacementHeader: Record DMTReplacementHeader)
    begin
        Source2Visible := replacementHeader."No. of Source Values" = replacementHeader."No. of Source Values"::"2";
        Target2Visible := replacementHeader."No. of Values to modify" = replacementHeader."No. of Values to modify"::"2";
        CurrPage.Update(Rec."Replacement Code" <> '');
    end;

    local procedure GetWarningStyleIfValueContainsSpecialChars(textValue: Text[80]) newStyleExpr: Text
    var
        invalidChars: Text;
        invalidChar: Char;
    begin
        newStyleExpr := Format(enum::DMTFieldStyle::None);
        invalidChars[1] := 13; //CR
        invalidChars[2] := 10; //LF
        invalidChars[3] := 9; //Tab
        invalidChars[4] := 160; //No-Break Space (NBSP) ALT+0,1,6,0
        foreach invalidChar in invalidChars do begin
            if textValue.Contains(invalidChar) then
                newStyleExpr := Format(enum::DMTFieldStyle::"Blue + Italic");
        end;
    end;

    local procedure setStyles()
    begin
        CV1_SpecialCharWarningStyle := GetWarningStyleIfValueContainsSpecialChars(rec."Comp.Value 1");
        CV2_SpecialCharWarningStyle := GetWarningStyleIfValueContainsSpecialChars(rec."Comp.Value 2");
        NV1_SpecialCharWarningStyle := GetWarningStyleIfValueContainsSpecialChars(rec."New Value 1");
        NV2_SpecialCharWarningStyle := GetWarningStyleIfValueContainsSpecialChars(rec."New Value 2");
    end;

    var
        Source2Visible, Target2Visible : Boolean;
        NV1_SpecialCharWarningStyle, NV2_SpecialCharWarningStyle, CV1_SpecialCharWarningStyle, CV2_SpecialCharWarningStyle : Text;
}