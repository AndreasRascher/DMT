page 91009 ImportConfigLinePart
{
    Caption = 'Lines', Comment = 'de-DE=Zeilen';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigLine;

    layout
    {
        area(Content)
        {
            label(AssignDataLayout)
            {
                Caption = 'Assign a data layout to assign fields.',
                Comment = 'de-DE=Weisen Sie ein Datenlayout zu um eine Felderzuordnung einzurichten.';
                Visible = not HasDataLayoutAssigned;
            }
            repeater(LineRepeater)
            {
                Editable = HasDataLayoutAssigned;
                field("Processing Action"; Rec."Processing Action") { ApplicationArea = All; }
                field("To Field No."; Rec."Target Field No.") { Visible = false; ApplicationArea = All; Editable = false; }
                field("To Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; StyleExpr = LineStyleExpr; Editable = false; }
                field("From Field Caption"; Rec."Source Field Caption")
                {
                    HideValue = IsFixedValue;
                    ApplicationArea = All;
                    StyleExpr = LineStyleExpr;
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    Visible = false;
                    ApplicationArea = All;
                    StyleExpr = LineStyleExpr;
                }
                field("From Field No."; Rec."Source Field No.") { LookupPageId = DMTFieldLookup; HideValue = IsFixedValue; ApplicationArea = All; }
                field("Ignore Validation Error"; Rec."Ignore Validation Error") { ApplicationArea = All; }
                field("Validation Type"; Rec."Validation Type") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
                field(ValidationOrder; Rec."Validation Order") { ApplicationArea = All; Visible = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitTargetFields)
            {
                Caption = 'Init Target Fields', comment = 'de-DE=Feldliste initialisieren';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    ImportConfigMgt.PageAction_InitFieldMapping(Rec.GetRangeMin("Imp.Conf.Header ID"));
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Popose Matching Fields', comment = 'de-DE=Feldzuordnung vorschlagen';
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
                action(FieldMapping_SetValidateFieldToAlways)
                {
                    Caption = 'Set Field Validate to always', Comment = 'de-DE=Validierungsart auf Immer setzen';
                    ApplicationArea = All;
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempImportConfigLine_Selected);
                        ImportConfigMgt.PageAction_FieldMapping_SetValidateField(TempImportConfigLine_Selected, Enum::DMTFieldValidationType::AlwaysValidate);
                    end;
                }
                action(DMTField_SetValidateFieldToFalse)
                {
                    Caption = 'Set Validation Type to assign without validate', Comment = 'de-DE=Validierungsart auf Zuweisen ohne validieren setzen';
                    ApplicationArea = All;
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempImportConfigLine_Selected);
                        ImportConfigMgt.PageAction_FieldMapping_SetValidateField(TempImportConfigLine_Selected, Enum::DMTFieldValidationType::AssignWithoutValidate);
                    end;
                }
            }
            group(ChangeValidationOrder)
            {
                Image = Allocate;
                Caption = 'Change Validation Order', Comment = 'de-DE=Validierungsreihenfolge ändern';
                action(MoveSelectedUp)
                {
                    ApplicationArea = All;
                    Caption = 'Up', Comment = 'de-DE=Oben';
                    // Scope = Repeater;
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
                    ApplicationArea = All;
                    Caption = 'Down', Comment = 'de-DE=Unten';
                    // Scope = Repeater;
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
                    ApplicationArea = All;
                    Caption = 'Top', Comment = 'de-DE=Anfang';
                    // Scope = Repeater;
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
                    ApplicationArea = All;
                    Caption = 'Bottom', Comment = 'de-DE=Ende';
                    // Scope = Repeater;
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

    procedure SetRepeaterProperties(ImportConfigHeader: Record DMTImportConfigHeader)
    begin
        HasDataLayoutAssigned := ImportConfigHeader."Data Layout ID" <> '';
    end;

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

    var
        TempImportConfigLine_Selected: Record DMTImportConfigLine temporary;
        ImportConfigMgt: Codeunit DMTImportConfigMgt;
        IsFixedValue, HasDataLayoutAssigned : Boolean;
        LineStyleExpr: Text;
}