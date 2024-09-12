page 50020 DMTReplacementRulePart
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

            repeater(Repeater_1_1)
            {
                Visible = is1By1Mapping;
                field(Repeater_1_1_CompValue1; Rec."Comp.Value 1") { StyleExpr = CV1_SpecialCharWarningStyle; }
                field(Repeater_1_1_NewValue1; Rec."New Value 1") { StyleExpr = NV1_SpecialCharWarningStyle; }
            }
            repeater(Repeater_2_1)
            {
                Visible = is2By1Mapping;
                field(Repeater_2_1_CompValue1; Rec."Comp.Value 1") { StyleExpr = CV1_SpecialCharWarningStyle; }
                field(Repeater_2_1_CompValue2; Rec."Comp.Value 2") { StyleExpr = CV2_SpecialCharWarningStyle; }
                field(Repeater_2_1_NewValue1; Rec."New Value 1") { StyleExpr = NV1_SpecialCharWarningStyle; }
            }
            repeater(Repeater_1_2)
            {
                Visible = is1By2Mapping;
                field(Repeater_1_2_CompValue1; Rec."Comp.Value 1") { StyleExpr = CV1_SpecialCharWarningStyle; }
                field(Repeater_1_2_NewValue1; Rec."New Value 1") { StyleExpr = NV1_SpecialCharWarningStyle; }
                field(Repeater_1_2_NewValue2; Rec."New Value 2") { StyleExpr = NV2_SpecialCharWarningStyle; }
            }
            repeater(Repeater_2_2)
            {
                Visible = is2By2Mapping;
                field(Repeater_2_2_CompValue1; Rec."Comp.Value 1") { StyleExpr = CV1_SpecialCharWarningStyle; }
                field(Repeater_2_2_CompValue2; Rec."Comp.Value 2") { StyleExpr = CV2_SpecialCharWarningStyle; }
                field(Repeater_2_2_NewValue1; Rec."New Value 1") { StyleExpr = NV1_SpecialCharWarningStyle; }
                field(Repeater_2_2_NewValue2; Rec."New Value 2") { StyleExpr = NV2_SpecialCharWarningStyle; }
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
        is1By1Mapping := replacementHeader.IsMapping(1, 1);
        is1By2Mapping := replacementHeader.IsMapping(1, 2);
        is2By1Mapping := replacementHeader.IsMapping(2, 1);
        is2By2Mapping := replacementHeader.IsMapping(2, 2);
        CurrPage.Update(replacementHeader.Code <> '');
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
        is1By1Mapping, is1By2Mapping, is2By1Mapping, is2By2Mapping : Boolean;
        NV1_SpecialCharWarningStyle, NV2_SpecialCharWarningStyle, CV1_SpecialCharWarningStyle, CV2_SpecialCharWarningStyle : Text;
}