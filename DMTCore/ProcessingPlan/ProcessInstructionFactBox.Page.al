page 91016 DMTProcessInstructionFactBox
{
    Caption = 'Processing Instructions', Comment = 'de-DE=Verarbeitungsanweisungen';
    PageType = ListPart;
    SourceTable = DMTImportConfigLine;
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(FilterList)
            {
                Caption = 'Filter', Comment = 'de-DE=Filter';
                Visible = IsSourceTableFilterView;
                field(FieldCaption; Rec."Source Field Caption") { ApplicationArea = All; }
                field(FilterValue; Rec."Fixed Value") { ApplicationArea = All; Caption = 'Filter', Locked = true; }
            }

            repeater(FixedValuesList)
            {
                Caption = 'Fixed Values', Comment = 'de-DE=Vorgabwerte';
                Visible = IsFixedValueView;
                field(FilterFieldCaption; Rec."Source Field Caption") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
            }
            repeater(UpdateFieldsList)
            {
                Caption = 'Fields', Comment = 'de-DE=Update-Felder';
                Visible = IsUpdateSelectedFieldsView;
                field(UpdateFieldCaption; Rec."Source Field Caption") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Edit)
            {
                Caption = 'Edit', Comment = 'de-DE=Bearbeiten';
                ApplicationArea = All;
                Image = Edit;

                trigger OnAction()
                begin
                    if IsSourceTableFilterView then
                        CurrProcessingPlan.EditSourceTableFilter();
                    if IsFixedValueView then
                        CurrProcessingPlan.EditDefaultValues();
                    ReloadPageContent();
                    CurrPage.Update(false);
                end;
            }
            action(AddField)
            {
                Caption = 'Add/Remove Field', Comment = 'de-DE=Feld hinzufügen/entfernen';
                ApplicationArea = All;
                Visible = ActionAddFieldVisible;
                Image = Add;

                trigger OnAction()
                var
                    SelectMultipleFields: Page DMTSelectMultipleFields;
                    RunModalAction: Action;
                begin
                    // Show only Non-Key Fields for selection
                    if not SelectMultipleFields.InitSelectTargetFields(CurrProcessingPlan) then
                        exit;
                    RunModalAction := SelectMultipleFields.RunModal();
                    if RunModalAction = Action::OK then begin
                        if SelectMultipleFields.RunModal() = Action::LookupOK then begin
                            CurrProcessingPlan.Get(CurrProcessingPlan.RecordId);
                            CurrProcessingPlan.SaveUpdateFieldsFilter(SelectMultipleFields.GetTargetFieldIDListAsText());
                        end;
                    end;
                end;
            }
            action(ResetSelection)
            {
                Caption = 'Reset Selection', Comment = 'de-DE=Auswahl zurücksetzen';
                ApplicationArea = All;
                Visible = ActionResetSelectionVisible;
                Image = Add;

                trigger OnAction()
                begin
                    CurrProcessingPlan.SaveUpdateFieldsFilter('');
                end;
            }
        }
    }

    internal procedure InitFactBoxAsSourceTableFilter(ProcessingPlan: Record DMTProcessingPlan)
    begin
        CurrProcessingPlan := ProcessingPlan;
        Clear(IsFixedValueView);
        Clear(IsUpdateSelectedFieldsView);
        Clear(IsSourceTableFilterView);
        if not ProcessingPlan.TypeSupportsSourceTableFilter() then begin
            IsSourceTableFilterView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsSourceTableFilterView := true;
        CurrProcessingPlan.ConvertSourceTableFilterToFieldLines(Rec);
        CurrPage.Update(false);
    end;

    internal procedure InitFactBoxAsFixedValueView(ProcessingPlan: Record DMTProcessingPlan)
    begin
        CurrProcessingPlan := ProcessingPlan;
        Clear(IsFixedValueView);
        Clear(IsUpdateSelectedFieldsView);
        Clear(IsSourceTableFilterView);
        if not ProcessingPlan.TypeSupportsFixedValues() then begin
            IsFixedValueView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsFixedValueView := true;
        CurrProcessingPlan.ConvertDefaultValuesViewToFieldLines(Rec);
        CurrPage.Update(false);
    end;

    internal procedure InitFactBoxAsUpdateSelectedFields(ProcessingPlan: Record DMTProcessingPlan)
    begin
        CurrProcessingPlan := ProcessingPlan;
        Clear(IsFixedValueView);
        Clear(IsUpdateSelectedFieldsView);
        Clear(IsSourceTableFilterView);
        if not ProcessingPlan.TypeSupportsProcessSelectedFieldsOnly() then begin
            IsUpdateSelectedFieldsView := false;
            Rec.DeleteAll();
            exit;
        end;

        IsUpdateSelectedFieldsView := true;
        ActionAddFieldVisible := true;
        ActionResetSelectionVisible := true;

        CurrProcessingPlan.ConvertUpdateFieldsListToFieldLines(Rec);
        CurrPage.Update(false);
    end;

    procedure ReloadPageContent()
    begin
        if Rec.IsTemporary then begin
            Rec.Reset();
            Rec.DeleteAll();
        end;
        if IsFixedValueView then begin
            CurrProcessingPlan.Get(CurrProcessingPlan.RecordId);
            CurrProcessingPlan.ConvertDefaultValuesViewToFieldLines(Rec);
        end;
        if IsSourceTableFilterView then begin
            CurrProcessingPlan.Get(CurrProcessingPlan.RecordId);
            CurrProcessingPlan.ConvertSourceTableFilterToFieldLines(Rec);
        end;
        CurrPage.Update();
    end;

    var
        CurrProcessingPlan: Record DMTProcessingPlan;
        // [InDataSet]
        IsFixedValueView, IsSourceTableFilterView, IsUpdateSelectedFieldsView : Boolean;
        ActionAddFieldVisible, ActionResetSelectionVisible : Boolean;
}
