page 91018 DMTSelectMultipleFields
{
    Caption = 'Select multiple fields', Comment = 'de-DE=Mehrere Felder auswählen';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTImportConfigLine;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    SourceTableTemporary = true;
    LinksAllowed = false;
    DataCaptionExpression = SelectedFieldsCaption;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field(SelectedFieldsList; SelectedFieldsCaption) { ApplicationArea = All; Caption = 'Current Selection', Comment = 'de-DE=Aktuelle Auswahl'; Editable = false; }
            }
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

    trigger OnOpenPage()
    begin
        RefreshSelectedFieldsCaption();
    end;

    procedure GetTargetFieldIDListAsText() TargetFieldIDListAsText: Text
    var
        FieldIDList: List of [Integer];
        TargetFieldCaptionListAsText: Text;
    begin
        GetToFieldListInner(Rec, FieldIDList, TargetFieldCaptionListAsText, TargetFieldIDListAsText);
    end;

    procedure GetTargetFieldCaptionListAsText() TargetFieldCaptionListAsText: Text
    var
        FieldIDList: List of [Integer];
        TargetFieldIDListAsText: Text;
    begin
        GetToFieldListInner(Rec, FieldIDList, TargetFieldCaptionListAsText, TargetFieldIDListAsText);
    end;

    procedure GetTargetFieldIDList() FieldIDList: List of [Integer]
    var
        TargetFieldCaptionListAsText: Text;
        TargetFieldIDListAsText: Text;
    begin
        GetToFieldListInner(Rec, FieldIDList, TargetFieldCaptionListAsText, TargetFieldIDListAsText);
    end;

    procedure GetSelectedSourceFieldIDList() FieldIDList: List of [Integer];
    var
        TempImportConfigLine: Record DMTImportConfigLine temporary;
    begin
        TempImportConfigLine.Copy(Rec, true);
        TempImportConfigLine.Reset();
        TempImportConfigLine.SetRange(Selection, true);
        if TempImportConfigLine.FindSet() then
            repeat
                FieldIDList.Add(TempImportConfigLine."Source Field No.");
            until TempImportConfigLine.Next() = 0;
    end;

    local procedure GetToFieldListInner(var ImportConfigLine_REC: Record DMTImportConfigLine temporary; var FieldIDList: List of [Integer]; var TargetFieldCaptionListAsText: Text; var TargetFieldIDListAsText: Text)
    var
        TempImportConfigLine: Record DMTImportConfigLine temporary;
    begin
        Clear(FieldIDList);
        Clear(TargetFieldCaptionListAsText);
        Clear(TargetFieldIDListAsText);
        TempImportConfigLine.Copy(ImportConfigLine_REC, true);
        TempImportConfigLine.Reset();
        TempImportConfigLine.SetRange(Selection, true);
        if TempImportConfigLine.FindSet() then
            repeat
                FieldIDList.Add(TempImportConfigLine."Target Field No.");
                TargetFieldIDListAsText += StrSubstNo('%1|', TempImportConfigLine."Target Field No.");
                TempImportConfigLine.CalcFields("Target Field Caption");
                TargetFieldCaptionListAsText += StrSubstNo('%1|', TempImportConfigLine."Target Field Caption");
            until TempImportConfigLine.Next() = 0;
        TargetFieldIDListAsText := TargetFieldIDListAsText.TrimEnd('|');
        TargetFieldCaptionListAsText := TargetFieldCaptionListAsText.TrimEnd('|');
    end;

    procedure InitSelectTargetFields(ImportConfigHeader: Record DMTImportConfigHeader; SelectedTargetFieldIDFilter: Text) OK: Boolean
    begin
        ShowTargetFieldInfo := true;
        OK := true;
        if not LoadImportConfigLine(Rec, ImportConfigHeader.ID) then
            exit(false);
        if SelectedTargetFieldIDFilter <> '' then
            RestoreTargetSelection(SelectedTargetFieldIDFilter);
    end;

    procedure InitSelectTargetFields(ProcessingPlan: Record DMTProcessingPlan) OK: Boolean
    var
        TargetFieldFilter: Text;
    begin
        OK := true;
        ShowTargetFieldInfo := true;
        TargetFieldFilter := GetIncludeExcludeKeyFieldFilter(CurrImportConfigHeader."Target Table ID", false /*exclude*/);
        if not LoadImportConfigLine(Rec, ProcessingPlan.ID) then
            exit(false);

        Rec.SetFilter("Target Field No.", TargetFieldFilter);
        // restore last selection
        if ProcessingPlan.ReadUpdateFieldsFilter() <> '' then begin
            RestoreTargetSelection(ProcessingPlan.ReadUpdateFieldsFilter());
        end;
    end;

    procedure InitSelectSourceFields(ImportConfigHeader: Record DMTImportConfigHeader; SelectedSourceFieldIDFilter: Text) OK: Boolean
    begin
        OK := true;
        ShowSourceFieldInfo := true;
        if not LoadImportConfigLine(Rec, ImportConfigHeader.ID) then
            exit(false);
        RestoreSourceSelection(SelectedSourceFieldIDFilter);
    end;

    local procedure LoadImportConfigLine(var TempImportConfigLine: Record DMTImportConfigLine temporary; ImportConfigHeaderID: Integer) Success: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        ImportConfigLine: Record DMTImportConfigLine;
    begin
        if not ImportConfigHeader.Get(ImportConfigHeaderID) then
            exit(false);
        if ImportConfigHeader."Target Table ID" = 0 then
            exit(false);

        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        // ImportConfigLine.SetFilter("Source Field No.", '<>%1', 0);
        ImportConfigLine.SetRange("Is Key Field(Target)", false);
        if ImportConfigLine.FindSet() then
            repeat
                case true of
                    // Transfer Field Value 
                    (ImportConfigLine."Processing Action" = ImportConfigLine."Processing Action"::Transfer) and
                    (ImportConfigLine."Source Field No." <> 0):
                        ImportConfigLine.Mark(true);
                    // Transfer Fixed Value
                    (ImportConfigLine."Processing Action" = ImportConfigLine."Processing Action"::FixedValue) and
                    (ImportConfigLine."Fixed Value" <> ''):
                        ImportConfigLine.Mark(true);
                end;
            until ImportConfigLine.Next() = 0;
        ImportConfigLine.MarkedOnly(true);
        ImportConfigLine.CopyToTemp(TempImportConfigLine);
        Success := not TempImportConfigLine.IsEmpty();
    end;

    local procedure RestoreSourceSelection(SelectedFieldNoFilter: Text)
    begin
        if SelectedFieldNoFilter = '' then
            exit;
        Rec.Reset();
        Rec.SetFilter("Source Field No.", SelectedFieldNoFilter);
        if Rec.FindSet(false) then
            repeat
                Rec.Selection := true;
                Rec.Modify();
            until Rec.Next() = 0;
        Rec.Reset();
    end;

    local procedure RestoreTargetSelection(SelectedFieldNoFilter: Text)
    begin
        if SelectedFieldNoFilter = '' then
            exit;
        Rec.Reset();
        Rec.SetFilter("Target Field No.", SelectedFieldNoFilter);
        if Rec.FindSet(false) then
            repeat
                Rec.Selection := true;
                Rec.Modify();
            until Rec.Next() = 0;
        Rec.Reset();
    end;

    procedure RefreshSelectedFieldsCaption()
    begin
        SelectedFieldsCaption := GetTargetFieldCaptionListAsText();
    end;

    procedure GetIncludeExcludeKeyFieldFilter(TableNo: Integer; Include: Boolean) KeyFieldNoFilter: Text
    var
        RefHelper: Codeunit DMTRefHelper;
        RecRef: RecordRef;
        FieldID: Integer;
        KeyFieldIDsList: List of [Integer];
    begin
        if TableNo = 0 then exit('');
        RecRef.Open(TableNo, true);
        KeyFieldIDsList := RefHelper.GetListOfKeyFieldIDs(RecRef);
        foreach FieldID in KeyFieldIDsList do begin
            if Include then
                KeyFieldNoFilter += StrSubstNo('|%1', FieldID)
            else
                KeyFieldNoFilter += StrSubstNo('&<>%1', FieldID);
        end;
        if CopyStr(KeyFieldNoFilter, 1, 1) = '|' then
            KeyFieldNoFilter := CopyStr(KeyFieldNoFilter, 2);
        if CopyStr(KeyFieldNoFilter, 1, 3) = '&<>' then
            KeyFieldNoFilter := CopyStr(KeyFieldNoFilter, 2);
    end;

    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        SelectedFieldsCaption: Text;

        // [InDataSet]
        ShowSourceFieldInfo, ShowTargetFieldInfo : Boolean;
}