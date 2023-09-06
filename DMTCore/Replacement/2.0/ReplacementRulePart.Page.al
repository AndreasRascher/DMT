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
                field("Comp.Value 1"; Rec."Comp.Value 1") { }
                field("Comp.Value 2"; Rec."Comp.Value 2") { Visible = Source2Visible; }
                field("New Value 1"; Rec."New Value 1") { }
                field("New Value 2"; Rec."New Value 2") { Visible = Target2Visible; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }

    procedure SetVisibility(replacementHeader: Record DMTReplacementHeader)
    begin
        Source2Visible := replacementHeader."No. of Source Values" = replacementHeader."No. of Source Values"::"2";
        Target2Visible := replacementHeader."No. of Values to modify" = replacementHeader."No. of Values to modify"::"2";
        CurrPage.Update(Rec."Replacement Code" <> '');
    end;

    var
        Source2Visible, Target2Visible : Boolean;
}