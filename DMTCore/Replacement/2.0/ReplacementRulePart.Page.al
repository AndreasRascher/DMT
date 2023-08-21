page 91020 DMTReplacementRulePart
{
    Caption = 'Rules', Comment = 'de-DE=Regeln';
    PageType = ListPart;
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
                field("Comp.Value 1"; Rec."Comp.Value 1") { ApplicationArea = All; }
                field("Comp.Value 2"; Rec."Comp.Value 2") { ApplicationArea = All; Visible = Source2Visible; }
                field("New Value 1"; Rec."New Value 1") { ApplicationArea = All; }
                field("New Value 2"; Rec."New Value 2") { ApplicationArea = All; Visible = Target2Visible; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }

    procedure SetVisibility(DMTReplacementHeader: Record DMTReplacementHeader)
    begin
        Source2Visible := DMTReplacementHeader."No. of Source Values" = DMTReplacementHeader."No. of Source Values"::"2";
        Target2Visible := DMTReplacementHeader."No. of Values to modify" = DMTReplacementHeader."No. of Values to modify"::"2";
        // CurrPage.Update(false);
    end;

    var
        Source2Visible, Target2Visible : Boolean;
}