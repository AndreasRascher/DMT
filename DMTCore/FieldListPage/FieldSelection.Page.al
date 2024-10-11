// TODO:
// Sichten
// - Quellfelder mit Filter (Bei In Zieltabelle übertragen, im Verarbeitungsplan)
// - Zielfelder mit Vorgabewert ()
// - Ausgew. Felder verarbeiten (Zielfelder)
// Mehrfachauswahl via Action
// - Quellfelder
// - Zielfelder
page 91029 DMTFieldSelection
{
    Caption = 'Field Selection', Comment = 'de-DE=Felderauswahl';
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = DMTFieldSelectionBuffer;
    SourceTableTemporary = true;
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            repeater(SourceTableFilters)
            {
                Visible = (Usage = Usage::EditSourceTableFilters);
                field(EditSourceTableFilters_SourceField; Rec."Source Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source Field Caption"));
                        if Rec."Field No." <> 0 then
                            CurrPage.Update(true);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Source Field Caption"));
                    end;
                }
                field(EditSourceTableFilters_FilterExpression; Rec.FilterExpression) { }
            }
            repeater(TargetTableFilters)
            {
                Visible = (Usage = Usage::EditTargetTableFilters);
                field(EditTargetTableFilters_SourceField; Rec."Target Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target Field Caption"));
                        if Rec."Field No." <> 0 then
                            CurrPage.Update(true);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Target Field Caption"));
                    end;
                }
                field(EditTargetTableFilters_FilterExpression; Rec.FilterExpression) { }
            }
            repeater(SelectedFieldsToProcess)
            {
                Visible = (Usage = Usage::SelectFieldsToProcess);
                field(SelectFieldsToProcess_TargetField; Rec."Target Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target Field Caption"));
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Target Field Caption"));
                        FindAssignedSourceField(Rec);
                    end;
                }

            }
            repeater(DefaultValues)
            {
                Visible = (Usage = Usage::EditDefaultValues);
                field(EditDefaultValues_TargetField; Rec."Target Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target Field Caption"));
                        if Rec."Field No." <> 0 then
                            CurrPage.Update(true);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Target Field Caption"));
                    end;
                }
                field(FixedValue; Rec.DefaultValue) { }
            }
            repeater(TableFilters)
            {
                Visible = (Usage = Usage::EditTableFilters);
                field(TableFilters_TargetField; Rec."Target Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target Field Caption"));
                        if Rec."Field No." <> 0 then
                            CurrPage.Update(true);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Target Field Caption"));
                    end;
                }
                field(FilterExpression; Rec.FilterExpression) { }
            }
        }
    }

    procedure SetUsage_SetSelectFieldsToProcess(importConfigHeader: Record DMTImportConfigHeader)
    var
        pageCaptionTxt: Label 'Select fields to process.', Comment = 'de-DE=Wählen Sie Felder zur Verarbeitung aus.';
    begin
        Usage := Usage::SelectFieldsToProcess;
        CurrPage.Caption := pageCaptionTxt;
        Rec.FilterGroup(4);
        Rec.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        Rec.FilterGroup(0);
    end;

    procedure SetUsage_EditSourceTableFilters(importConfigHeader: Record DMTImportConfigHeader)
    var
        pageCaptionTxt: Label 'Edit filter for %1', Comment = 'de-DE=Filter bearbeiten für %1';
    begin
        Usage := Usage::EditSourceTableFilters;
        CurrPage.Caption := StrSubstNo(pageCaptionTxt, importConfigHeader."Source File Name");
        Rec.FilterGroup(4);
        Rec.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        Rec.FilterGroup(0);
    end;

    procedure SetUsage_EditDefaultValues(importConfigHeader: Record DMTImportConfigHeader)
    var
        pageCaptionTxt: Label 'Set default values for table %1', Comment = 'de-DE=Legen sie Fix-Werte für die Tabelle %1 fest';
    begin
        Usage := Usage::EditDefaultValues;
        CurrPage.Caption := StrSubstNo(pageCaptionTxt, importConfigHeader."Target Table Caption");
        Rec.FilterGroup(4);
        Rec.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        Rec.FilterGroup(0);
    end;

    procedure SetUsage_EditTargetTableFilters(importConfigHeader: Record DMTImportConfigHeader)
    var
        pageCaptionTxt: Label 'Edit filter for %1', Comment = 'de-DE=Filter bearbeiten für %1';
    begin
        Usage := Usage::EditTargetTableFilters;
        CurrPage.Caption := StrSubstNo(pageCaptionTxt, importConfigHeader."Target Table Caption");
        Rec.FilterGroup(4);
        Rec.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        Rec.FilterGroup(0);
    end;

    procedure SetUsage_EditTableFilters(recRef: RecordRef)
    var
        pageCaptionTxt: Label 'Edit filter for %1', Comment = 'de-DE=Filter bearbeiten für %1';
    begin
        Usage := Usage::EditTableFilters;
        CurrPage.Caption := StrSubstNo(pageCaptionTxt, recRef.Caption);
        Rec.FilterGroup(4);
        Rec.SetRange("Table No.", recRef.Number);
        Rec.FilterGroup(0);
    end;


    internal procedure EditSourceTableFilters(var BufferRef: RecordRef; importConfigHeader: Record DMTImportConfigHeader): Boolean
    var
        fieldSelection: Page DMTFieldSelection;
        runAction: Action;
        fieldFilters: Dictionary of [Integer/*Field-ID*/, Text/*Filter*/];
    begin
        fieldSelection.SetUsage_EditSourceTableFilters(importConfigHeader);
        fieldSelection.loadFieldFilters(fieldFilters, BufferRef);
        fieldSelection.addKeyFieldsToPage(importConfigHeader);
        fieldSelection.addFieldWithFiltersToPage(importConfigHeader, fieldFilters);
        runAction := fieldSelection.RunModal();
        if runAction = Action::OK then begin
            fieldSelection.SaveFieldsFilter(BufferRef);
            exit(true);
        end;
    end;

    internal procedure EditTargetTableFilters(var TargetRef: RecordRef; importConfigHeader: Record DMTImportConfigHeader): Boolean
    var
        fieldSelection: Page DMTFieldSelection;
        runAction: Action;
        fieldFilters: Dictionary of [Integer/*Field-ID*/, Text/*Filter*/];
    begin
        fieldSelection.SetUsage_EditTargetTableFilters(importConfigHeader);
        fieldSelection.loadFieldFilters(fieldFilters, TargetRef);
        fieldSelection.addKeyFieldsToPage(importConfigHeader);
        fieldSelection.addFieldWithFiltersToPage(importConfigHeader, fieldFilters);
        runAction := fieldSelection.RunModal();
        if runAction = Action::OK then begin
            fieldSelection.SaveFieldsFilter(TargetRef);
            exit(true);
        end;
    end;

    internal procedure EditDefaultValues(var TargetRef: RecordRef; ImportConfigHeader: Record DMTImportConfigHeader): Boolean
    var
        fieldSelection: Page DMTFieldSelection;
        runAction: Action;
        fieldFilters: Dictionary of [Integer/*Field-ID*/, Text/*Filter*/];
    begin
        fieldSelection.SetUsage_EditDefaultValues(importConfigHeader);
        fieldSelection.loadFieldFilters(fieldFilters, TargetRef);
        fieldSelection.addFieldWithFiltersToPage(importConfigHeader, fieldFilters);
        runAction := fieldSelection.RunModal();
        if runAction = Action::OK then begin
            fieldSelection.SaveFieldsFilter(TargetRef);
            exit(true);
        end;
    end;

    internal procedure EditTableFilters(SourceRef: RecordRef): Boolean
    var
        fieldSelection: Page DMTFieldSelection;
        runAction: Action;
        fieldFilters: Dictionary of [Integer/*Field-ID*/, Text/*Filter*/];
    begin
        fieldSelection.SetUsage_EditTableFilters(SourceRef);
        fieldSelection.addKeyFieldsToPage(SourceRef);
        fieldSelection.loadFieldFilters(fieldFilters, SourceRef);
        fieldSelection.addFieldWithFiltersToPage(SourceRef, fieldFilters);

        runAction := fieldSelection.RunModal();
        if runAction = Action::OK then begin
            fieldSelection.SaveFieldsFilter(SourceRef);
            exit(true);
        end;
    end;

    internal procedure SelectFieldsToProcess(var updateFieldsFilter: Text; importConfigHeader: Record DMTImportConfigHeader): Boolean
    var
        fieldSelection: Page DMTFieldSelection;
        runAction: Action;
    begin
        fieldSelection.SetUsage_SetSelectFieldsToProcess(importConfigHeader);
        fieldSelection.loadSelectedFields(importConfigHeader, updateFieldsFilter);
        runAction := fieldSelection.RunModal();
        if runAction = Action::OK then begin
            updateFieldsFilter := fieldSelection.createSelectedTargetFieldIDsFilter();
            exit(true);
        end;
    end;

    internal procedure SaveFieldsFilter(var BufferRef: RecordRef)
    var
        bufferRefWithNewView: RecordRef;
        debug: Text;
    begin
        // create a copy of bufferRef and reset it
        bufferRefWithNewView := BufferRef.Duplicate();
        bufferRefWithNewView.Reset();
        if Rec.FindSet(false) then
            repeat
                case Usage of
                    usage::EditSourceTableFilters, usage::EditTargetTableFilters,
                    Usage::EditTableFilters:
                        bufferRefWithNewView.Field(Rec."Field No.").SetFilter(Rec.FilterExpression);
                    usage::EditDefaultValues:
                        bufferRefWithNewView.Field(Rec."Field No.").SetFilter(Rec.DefaultValue);
                    else
                        Error('unhandled usage %1', Usage);
                end;
            until Rec.Next() = 0;
        // setting the new view keeps other filtergroups filter
        BufferRef.SetView(bufferRefWithNewView.GetView());
        debug := BufferRef.GetFilters();
        BufferRef.FilterGroup(2);
        debug := BufferRef.GetFilters();
        BufferRef.FilterGroup(0);
    end;

    internal procedure loadSelectedFields(importConfigHeader: Record dmtimportConfigHeader; updateTargetFieldsFilter: Text)
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        if updateTargetFieldsFilter = '' then
            exit;
        importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        importConfigLine.SetFilter("Target Field No.", updateTargetFieldsFilter);
        if importConfigLine.FindSet() then
            repeat
                Rec."Imp.Conf.Header ID" := importConfigLine."Imp.Conf.Header ID";
                Rec.Type := Rec.Type::Target;
                Rec."Field No." := importConfigLine."Target Field No.";
                importConfigLine.CalcFields("Target Field Caption");
                Rec."Target Field Caption" := importConfigLine."Target Field Caption";
                Rec."Source Field Caption" := importConfigLine."Source Field Caption";
                Rec.Insert();
            until importConfigLine.Next() = 0;
    end;

    internal procedure createSelectedTargetFieldIDsFilter() selectedTargetFieldIDsFilter: Text
    begin
        rec.SetRange("Type", rec.Type::Target);
        if Rec.FindSet(false) then
            repeat
                selectedTargetFieldIDsFilter += StrSubstNo('|%1', Rec."Field No.");
            until Rec.Next() = 0;
        selectedTargetFieldIDsFilter := selectedTargetFieldIDsFilter.TrimStart('|');
    end;

    local procedure FindAssignedSourceField(var tempFieldSelectionBuffer: Record DMTFieldSelectionBuffer temporary)
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        tempFieldSelectionBuffer.TestField("Imp.Conf.Header ID");
        importConfigLine.SetRange("Imp.Conf.Header ID", tempFieldSelectionBuffer."Imp.Conf.Header ID");
        importConfigLine.SetRange("Target Field No.", tempFieldSelectionBuffer."Field No.");
        if importConfigLine.FindFirst() then
            tempFieldSelectionBuffer."Source Field Caption" := importConfigLine."Source Field Caption";
    end;

    local procedure FindAssignedTargetField(var tempFieldSelectionBuffer: Record DMTFieldSelectionBuffer temporary)
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        tempFieldSelectionBuffer.TestField("Imp.Conf.Header ID");
        importConfigLine.SetRange("Imp.Conf.Header ID", tempFieldSelectionBuffer."Imp.Conf.Header ID");
        importConfigLine.SetRange(importConfigLine."Source Field No.", tempFieldSelectionBuffer."Field No.");
        if importConfigLine.FindFirst() then
            tempFieldSelectionBuffer."Target Field Caption" := importConfigLine."Target Field Caption";
    end;

    procedure loadFieldFilters(var fieldFilters: Dictionary of [Integer/*Field-ID*/, Text/*Filter*/]; var recordRef: RecordRef) hasFilters: Boolean
    var
        fieldIndex: Integer;
    begin
        Clear(fieldFilters);
        if recordRef.GetFilters = '' then
            exit(false);
        for fieldIndex := 1 to recordRef.FieldCount do
            if recordRef.FieldIndex(fieldIndex).GetFilter <> '' then begin
                fieldFilters.Add(recordRef.FieldIndex(fieldIndex).Number, recordRef.FieldIndex(fieldIndex).GetFilter);
            end;
        hasFilters := fieldFilters.Count > 0;
    end;

    procedure addFieldWithFiltersToPage(var SourceRef: RecordRef; var fieldFilters: Dictionary of [Integer/*Field-ID*/, Text/*Filter*/])
    var
        fieldID: Integer;
    begin
        foreach fieldID in fieldFilters.Keys do begin
            if not Rec.Get(fieldID) then begin
                Rec."Field No." := fieldID;
                Rec.Insert();
            end;
            Rec."Table No." := SourceRef.Number;
            Rec.Type := Rec.Type::Target;
            Rec."Target Field Caption" := CopyStr(SourceRef.Field(fieldID).Caption, 1, MaxStrLen(Rec."Source Field Caption"));
            Rec.FilterExpression := CopyStr(fieldFilters.Get(fieldID), 1, MaxStrLen(Rec.FilterExpression));
            Rec.Modify();
        end;
    end;

    procedure addFieldWithFiltersToPage(importConfigHeader: Record DMTImportConfigHeader; fieldFilters: Dictionary of [Integer, Text])
    var
        importConfigLine: Record DMTImportConfigLine;
        fieldNo: Integer;
    begin
        importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        foreach fieldNo in fieldFilters.Keys do begin
            Rec."Imp.Conf.Header ID" := importConfigHeader."ID";
            case Usage of
                usage::EditSourceTableFilters:
                    begin
                        importConfigLine.SetRange("Source Field No.", fieldNo);
                        if importConfigLine.FindFirst() then begin
                            if not Rec.Get(fieldNo) then begin
                                Rec."Field No." := fieldNo;
                                Rec.Insert();
                            end;
                            Rec.Type := Rec.Type::Source;
                            Rec."Source Field Caption" := importConfigLine."Source Field Caption";
                            Rec.FilterExpression := CopyStr(fieldFilters.Get(fieldNo), 1, MaxStrLen(Rec.FilterExpression));
                            Rec.Modify();
                        end;
                    end;
                Usage::EditDefaultValues:
                    begin
                        importConfigLine.SetRange("Target Field No.", fieldNo);
                        if importConfigLine.FindFirst() then begin
                            if not Rec.Get(fieldNo) then begin
                                Rec."Field No." := fieldNo;
                                Rec.Insert();
                            end;
                            Rec.Type := Rec.Type::Target;
                            importConfigLine.CalcFields("Target Field Caption");
                            Rec."Target Field Caption" := importConfigLine."Target Field Caption";
                            Rec.DefaultValue := CopyStr(fieldFilters.Get(fieldNo), 1, MaxStrLen(Rec.DefaultValue));
                            Rec.Modify();
                        end;
                    end;
                else
                    Error('unhandled usage %1', Usage);
            end;
        end;
    end;

    procedure addKeyFieldsToPage(recRef: RecordRef) noOfFields: Integer
    var
        FieldRef: FieldRef;
        _KeyIndex: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for _KeyIndex := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(_KeyIndex);
            Rec."Table No." := recRef.Number;
            Rec.Type := Rec.Type::" ";
            Rec."Field No." := FieldRef.Number;
            Rec."Target Field Caption" := CopyStr(FieldRef.Caption, 1, MaxStrLen(Rec."Source Field Caption"));
            Rec.Insert();
        end;
        noOfFields := Rec.Count;
    end;

    procedure addKeyFieldsToPage(importConfigHeader: Record DMTImportConfigHeader) noOfFields: Integer
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        importConfigLine.SetRange("Is Key Field(Target)", true);
        if importConfigLine.FindSet() then
            repeat
                case Usage of
                    Usage::EditSourceTableFilters:
                        begin
                            Rec."Imp.Conf.Header ID" := importConfigLine."Imp.Conf.Header ID";
                            Rec.Type := Rec.Type::Source;
                            Rec."Field No." := importConfigLine."Source Field No.";
                            Rec."Source Field Caption" := importConfigLine."Source Field Caption";
                            Rec.Insert();
                        end;
                    Usage::EditTargetTableFilters:
                        begin
                            Rec."Imp.Conf.Header ID" := importConfigLine."Imp.Conf.Header ID";
                            Rec.Type := Rec.Type::Target;
                            Rec."Field No." := importConfigLine."Target Field No.";
                            importConfigLine.CalcFields("Target Field Caption");
                            Rec."Target Field Caption" := importConfigLine."Target Field Caption";
                            Rec.Insert();
                        end;
                    else
                        Error('unhandled usage %1', Usage);
                end;
            until importConfigLine.Next() = 0;
        noOfFields := Rec.Count;
    end;



    var
        Usage: Option " ",SelectFieldsToProcess,EditSourceTableFilters,EditTargetTableFilters,EditDefaultValues,EditTableFilters;


}