page 91023 DMTFieldMappings
{
    Caption = 'DMT Field Mappings', Comment = 'de-DE=DMT Feldermapping';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigLine;
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Imp.Conf.Header ID"; Rec."Imp.Conf.Header ID") { }
                field("Source Field Caption"; Rec."Source Field Caption") { }
                field("Target Field Caption"; Rec."Search Target Field Caption") { }
                field("Target Field Name"; Rec."Search Target Field Name") { }
                field("Fixed Value"; Rec."Fixed Value") { }
                field("Source Field No."; Rec."Source Field No.") { }
                field("Target Field No."; Rec."Target Field No.") { }
                field("Target Table ID"; Rec."Target Table ID") { }
                field("Is Key Field(Target)"; Rec."Is Key Field(Target)") { }
                field("Target Table Relation"; Rec."Target Table Relation") { }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        LoadLines();
    end;

    procedure LoadLines()
    var
        importConfigLine: Record DMTImportConfigLine;
        tempImportConfigLine: Record DMTImportConfigLine temporary;
    begin
        importConfigLine.SetAutoCalcFields("Target Field Caption", "Target Field Name", "Target Table Relation");
        if importConfigLine.FindSet(false) then
            repeat
                tempImportConfigLine := importConfigLine;
                tempImportConfigLine."Search Target Field Caption" := importConfigLine."Target Field Caption";
                tempImportConfigLine."Search Target Field Name" := importConfigLine."Target Field Name";
                tempImportConfigLine.Insert(false);
            until importConfigLine.Next() = 0;
        rec.copy(tempImportConfigLine, true);
    end;

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