page 91009 DMTImportConfigLinePart
{
    Caption = 'Lines', Comment = 'de-DE=Zeilen';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigLine;
    SourceTableView = sorting("Validation Order");
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(LineRepeater)
            {
                // Editable = HasDataLayoutAssigned;
                field("Processing Action"; Rec."Processing Action") { }
                field("To Field No."; Rec."Target Field No.") { Visible = false; Editable = false; }
                field("To Field Caption"; Rec."Target Field Caption") { StyleExpr = LineStyleExpr; Editable = false; }
                field("From Field Caption"; Rec."Source Field Caption")
                {
                    HideValue = IsFixedValue;
                    StyleExpr = LineStyleExpr;
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    Visible = false;
                    StyleExpr = LineStyleExpr;
                }
                field("From Field No."; Rec."Source Field No.")
                {
                    LookupPageId = DMTFieldLookup;
                    HideValue = IsFixedValue;
                }
                field("Ignore Validation Error"; Rec."Ignore Validation Error")
                {
                    ToolTip = 'Ingore occuring field error and import data',
                    Comment = 'de-DE=VerarbeitungsfehlerDaten importieren auch';
                }
                field("Validation Type"; Rec."Validation Type") { }
                field("Fixed Value"; Rec."Fixed Value") { }
                field(ValidationOrder; Rec."Validation Order") { Visible = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitTargetFields)
            {
                Caption = 'Init Target Fields', Comment = 'de-DE=Feldliste initialisieren';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    ImportConfigMgt.PageAction_InitImportConfigLine(Rec.GetRangeMin("Imp.Conf.Header ID"));
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Propose Matching Fields', Comment = 'de-DE=Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    ImportConfigMgt.PageAction_ProposeMatchingFields(Rec.GetRangeMin("Imp.Conf.Header ID"));
                end;
            }
            group(Lines)
            {
                Caption = 'Lines', Comment = 'de-DE=Zeilen';
                action(ImportConfigLine_SetValidateFieldToAlways)
                {
                    Caption = 'Set Field Validate to always', Comment = 'de-DE=Validierungsart auf Immer setzen';
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempImportConfigLine_Selected);
                        ImportConfigMgt.PageAction_ImportConfigLine_SetValidateField(TempImportConfigLine_Selected, Enum::DMTFieldValidationType::AlwaysValidate);
                    end;
                }
                action(DMTField_SetValidateFieldToFalse)
                {
                    Caption = 'Set Validation Type to assign without validate', Comment = 'de-DE=Validierungsart auf Zuweisen ohne validieren setzen';
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempImportConfigLine_Selected);
                        ImportConfigMgt.PageAction_ImportConfigLine_SetValidateField(TempImportConfigLine_Selected, Enum::DMTFieldValidationType::AssignWithoutValidate);
                    end;
                }
            }
            group(ChangeValidationOrder)
            {
                Image = Allocate;
                Caption = 'Change Validation Order', Comment = 'de-DE=Validierungsreihenfolge ändern';
                action(MoveSelectedUp)
                {
                    Caption = 'Up', Comment = 'de-DE=Oben';
                    Image = MoveUp;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempImportConfigLine_Selected) then
                            ImportConfigMgt.PageAction_MoveSelectedLines(TempImportConfigLine_Selected, Direction::Up);
                    end;
                }
                action(MoveSelectedDown)
                {
                    Caption = 'Down', Comment = 'de-DE=Unten';
                    Image = MoveDown;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempImportConfigLine_Selected) then
                            ImportConfigMgt.PageAction_MoveSelectedLines(TempImportConfigLine_Selected, Direction::Down);
                    end;
                }
                action(MoveSelectedToTop)
                {
                    Caption = 'Top', Comment = 'de-DE=Anfang';
                    Image = ChangeTo;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempImportConfigLine_Selected) then
                            ImportConfigMgt.PageAction_MoveSelectedLines(TempImportConfigLine_Selected, Direction::Top);
                    end;
                }
                action(MoveSelectedToEnd)
                {
                    Caption = 'Bottom', Comment = 'de-DE=Ende';
                    Image = Apply;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempImportConfigLine_Selected) then
                            ImportConfigMgt.PageAction_MoveSelectedLines(TempImportConfigLine_Selected, Direction::Bottom);
                    end;
                }
            }
        }
    }


    procedure DoUpdate(SaveRecord: Boolean)
    begin
        CurrPage.Update(SaveRecord);
    end;

    local procedure GetSelection(var ImportConfigLine_SELECTED: Record DMTImportConfigLine temporary) HasLines: Boolean
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

    trigger OnAfterGetRecord()
    var
        Log: Codeunit DMTLog;
    begin
        // IsFixedValue := Rec."Processing Action" = Rec."Processing Action"::FixedValue;
        LineStyleExpr := '';
        if Rec."Processing Action" = Rec."Processing Action"::Ignore then
            LineStyleExpr := Format(Enum::DMTFieldStyle::Grey);
        if Log.FieldErrorsExistFor(Rec) then
            LineStyleExpr := Format(Enum::DMTFieldStyle::"Red + Italic");
    end;

    var
        TempImportConfigLine_Selected: Record DMTImportConfigLine temporary;
        ImportConfigMgt: Codeunit DMTImportConfigMgt;
        IsFixedValue, HasDataLayoutAssigned : Boolean;
        LineStyleExpr: Text;
}