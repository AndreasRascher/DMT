/*
Idee:
- Die Seite soll die Möglichkeit bieten, Felder auszuwählen, die in einem Importprozess verwendet werden sollen.
- Eine Sicht zur Auswahl der Felder
- eine Sicht zum eingeben von Filtern
- eine Sicht zum eingeben von festen Werten
*/
page 91028 DMTFieldList
{
    Caption = '';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTImportConfigLine;

    layout
    {
        area(Content)
        {
            repeater(SelectedFields)
            {
                Caption = 'Select Fields', Comment = 'de-DE=Felder auswählen';
                field("Target Field No."; Rec."Target Field No.") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                field("Target Field Name"; Rec."Target Field Name") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                // field("Target Field Caption"; Rec."Search Target Field Caption") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                field("Target Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                field("Source Field No."; Rec."Source Field No.") { ApplicationArea = All; Editable = false; Visible = ShowSourceFieldInfo; }
                field("Source Field Caption"; Rec."Source Field Caption") { ApplicationArea = All; Editable = false; Visible = ShowSourceFieldInfo; }
                field(Selection; Rec.Selection)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.Modify();
                        RefreshSelectedFieldsCaption();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
    procedure SetUsage_SelectFieldsToProcess()
    var
        pageCaptionTxt: Label 'Select multiple fields', Comment = 'de-DE=Mehrere Felder auswählen';
    begin
        Usage := Usage::SelectFieldsToProcess;
        CurrPage.Caption := pageCaptionTxt;
    end;

    procedure SetUsage_EditTableFilters()
    begin
        Usage := Usage::EditTableFilters;
    end;

    procedure SetUsage_EditFixedValues()
    begin
        Usage := Usage::EditFixedValues;
    end;


    var
        Usage: Option " ",SelectFieldsToProcess,EditTableFilters,EditFixedValues;
}