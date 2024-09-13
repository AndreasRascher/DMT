page 50021 DMTImportConfigLines
{
    Caption = 'Import Config Lines', Comment = 'de-DE=Import Konfiguration Zeilen';
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = DMTImportConfigLine;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = "Source Field Caption";
                field("Target Table ID"; Rec."Target Table ID") { }
                field("Target Table Caption"; Rec."Target Table Caption") { }
                field("Target Field Caption"; Rec."Target Field Caption") { }
                field("Source Field Caption"; Rec."Source Field Caption") { }
                field("Target Table Relation"; Rec."Target Table Relation") { }
                field("Target Field No."; Rec."Target Field No.") { }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
    }
    procedure GetSelection(var ImportConfigLine_SELECTED: Record DMTImportConfigLine temporary) HasLines: Boolean
    var
        ImportConfigLine: Record DMTImportConfigLine;
        Debug: Integer;
    begin
        Clear(ImportConfigLine_SELECTED);
        if ImportConfigLine_SELECTED.IsTemporary then ImportConfigLine_SELECTED.DeleteAll();
        Debug := Rec.Count;
        ImportConfigLine.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(ImportConfigLine);
        Debug := ImportConfigLine.Count;
        ImportConfigLine.CopyToTemp(ImportConfigLine_SELECTED);
        HasLines := ImportConfigLine_SELECTED.FindFirst();
    end;
}