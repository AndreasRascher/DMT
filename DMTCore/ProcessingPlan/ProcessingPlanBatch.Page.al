page 91017 DMTProcessingPlan
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'DMT Processing Plan', Comment = 'de-DE=DMT Verarbeitungsplan';
    AdditionalSearchTerms = 'DMT Plan', Locked = true;
    InsertAllowed = false;
    DeleteAllowed = true;
    PageType = Worksheet;
    SourceTable = DMTProcessingPlan;
    SaveValues = true;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = All;
                Caption = 'Batch Name', Comment = 'de-DE=Buch.-Blattname';

                trigger OnLookup(var Text: Text): Boolean
                var
                    processingPlanBatch: Record DMTProcessingPlanBatch;
                begin
                    processingPlanBatch.Name := CurrentJnlBatchName;
                    if Page.RunModal(0, processingPlanBatch) <> Action::LookupOK then
                        exit(false);

                    Text := processingPlanBatch.Name;
                    CurrPage.Update(false);
                    exit(true);
                end;

                trigger OnValidate()
                begin
                    ChangeJournalBatch();
                end;
            }
            repeater("Repeater")
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;
                // Visible = ShowTreeView;
                field("Line Type"; Rec.Type) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ImportConfigHeaderID; Rec.ID)
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    BlankZero = true;
                    trigger OnValidate()
                    begin
                        TargetTableID_HideValue := not Rec.TypeSupportsProcessSelectedFieldsOnly();
                    end;
                }
                field(Description; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ProcessingTime; Rec."Processing Duration") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StartTime; Rec.StartTime) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = LineStyle; }
                // field("Source Table No."; Rec."Source Table No.")
                // {
                //     ApplicationArea = All;
                //     StyleExpr = LineStyle;
                //     ToolTip = 'Defining the source table no. for which a filter as event is provided for rows of type Codeunit.',
                //     comment = 'de-DE=Gibt die Herkunftstabellennr. an für die bei Zeilen der Art Codeunit ein Filter als Event bereitgestellt werden soll.';
                // }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
                field("Target Table ID"; Rec."Target Table ID") { ApplicationArea = All; StyleExpr = LineStyle; Visible = false; HideValue = TargetTableID_HideValue; Lookup = false; DrillDown = false; }
                field("No. of Records In Trgt. Table"; CurrImportConfigHeader.GetNoOfRecordsInTrgtTable())
                {
                    Caption = 'Target', Comment = 'de-DE=DS im Ziel';
                    ToolTip = 'Number of records in the target table.', Comment = 'de-DE=Anzahl der Datensätze in der Zieltabelle.';
                    ApplicationArea = All;
                    Enabled = HasImportConfigHeader;
                    HideValue = not HasImportConfigHeader;
                    trigger OnDrillDown()
                    begin
                        CurrImportConfigHeader.ShowTableContent(CurrImportConfigHeader."Target Table ID");
                    end;
                }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table")
                {
                    Caption = 'Buffer', Comment = 'de-DE=DS im Puffer';
                    ToolTip = 'Number of records in the buffer table.', Comment = 'de-DE=Anzahl der Datensätze in der Puffertabelle.';
                    ApplicationArea = All;
                    Enabled = HasImportConfigHeader;
                    HideValue = not HasImportConfigHeader;
                    trigger OnDrillDown()
                    begin
                        CurrImportConfigHeader.BufferTableMgt().ShowBufferTable();
                    end;
                }
                field("Max No. of Records to Process"; Rec."Max No. of Records to Process")
                {
                    ToolTip = 'Stops processing after a specified number of records. Recommended for testing large data sets.',
                    Comment = 'de-DE=Stoppt die Verarbeitung nach einer bestimmten Anzahl von Datensätzen. Empfohlen für das Testen großer Datenmengen';
                    Style = StrongAccent;
                }
            }
        }
        area(FactBoxes)
        {
            part(SourceTableFilter; DMTProcessInstructionFactBox)
            {
                Caption = 'Source Table Filter', Comment = 'de-DE=Quelldaten Filter';
                SubPageLink = PrPl_FBRunMode_Filter = const(SourceTableFilter), PrPl_LineNo_Filter = field("Line No."), PrPl_JnlBatchName_Filter = field("Journal Batch Name");
                UpdatePropagation = Both;
                Enabled = ShowSourceTableFilterPart;
            }
            part(FixedValues; DMTProcessInstructionFactBox)
            {
                Caption = 'Default Values', Comment = 'de-DE=Vorgabewerte';
                SubPageLink = PrPl_FBRunMode_Filter = const(FixedValueView), PrPl_LineNo_Filter = field("Line No."), PrPl_JnlBatchName_Filter = field("Journal Batch Name");
                UpdatePropagation = Both;
                Enabled = ShowFixedValuesPart;
            }
            part(UpdateSelectedFieldsOnly; DMTProcessInstructionFactBox)
            {
                Caption = 'Process selected fields only', Comment = 'de-DE=Ausgew. Felder verarbeiten';
                SubPageLink = PrPl_FBRunMode_Filter = const(UpdateSelectedFields), PrPl_LineNo_Filter = field("Line No."), PrPl_JnlBatchName_Filter = field("Journal Batch Name");
                UpdatePropagation = Both;
                Enabled = ShowProcessSelectedFieldsOnly;
            }
            part(LogFactBox; DMTImportConfigFactBox)
            {
                Caption = 'Log', Comment = 'de-DE=Protokoll';
                SubPageLink = FBRunMode_Filter = const(Log), PrPl_LineNo_Filter = field("Line No."), PrPl_JnlBatchName_Filter = field("Journal Batch Name");
                Enabled = ShowLogFactboxPart;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                // Caption = 'Start', Comment = 'de-DE=Ausführen';
                Caption = ' ', Locked = true;
                ToolTip = 'Start', Comment = 'de-DE=Ausführen';
                ApplicationArea = All;
                Image = Start;

                trigger OnAction();
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    RunSelected(TempProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(NewLine)
            {
                Caption = 'New', Comment = 'de-DE=Neu';
                ShortcutKey = 'Alt+n';
                Image = "Invoicing-New";
                Scope = Repeater;
                trigger OnAction()
                var
                    Line: Record DMTProcessingPlan;
                    NewLineNo: Integer;
                begin
                    NewLineNo := findNextLineNoBelow();
                    if NewLineNo <> 0 then begin
                        Clear(Line);
                        Line."Journal Batch Name" := CurrentJnlBatchName;
                        Line."Line No." := NewLineNo;
                        if Rec."Line No." <> 0 then
                            case true of
                                (Rec.Type <> Rec.Type::Group) and (Rec.Indentation > 0):
                                    Line.Indentation := Rec.Indentation;
                                (Rec.Type = Rec.Type::Group):
                                    Line.Indentation := Rec.Indentation + 1;
                            end;
                        Line.Insert();
                        Rec.Get(Line.RecordId);
                    end;
                end;
            }
            action(DeleteLine)
            {
                // Caption = 'Delete', Comment = 'de-DE=Löschen';
                Caption = ' ', Locked = true;
                ToolTip = 'Delete', Comment = 'de-DE=Löschen';
                // ShortcutKey = 'Ctrl+Delete'; //TODO ShortcutKey geht nicht, Ctrl+ ist richtig
                Image = Delete;
                trigger OnAction()
                var
                    TempProcessingPlan_SELECTED: Record DMTProcessingPlan temporary;
                    processingPlan: Record DMTProcessingPlan;
                    doDeleteLines: Boolean;
                    DeleteSelectedLinesQst: Label 'Delete %1 selected lines?', Comment = 'de-DE=Wollen sie %1 Zeilen löschen?';
                begin
                    if GetSelection(TempProcessingPlan_SELECTED) then
                        if TempProcessingPlan_SELECTED.FindSet() then begin
                            // confirm if more than one line is selected
                            if TempProcessingPlan_SELECTED.Count > 1 then
                                doDeleteLines := Confirm(StrSubstNo(DeleteSelectedLinesQst, TempProcessingPlan_SELECTED.Count))
                            else
                                doDeleteLines := true;
                            // delete selected lines
                            if doDeleteLines then
                                repeat
                                    processingPlan.Get(TempProcessingPlan_SELECTED.RecordId);
                                    processingPlan.Delete();
                                until TempProcessingPlan_SELECTED.Next() = 0;
                        end;
                end;
            }
            action(IndentLeft)
            {
                // Caption = 'Indent Left', Comment = 'de-DE=Links einrücken';
                Caption = ' ', Locked = true;
                ToolTip = 'Indent Left', Comment = 'de-DE=Links einrücken';
                ApplicationArea = All;
                Image = DecreaseIndent;

                trigger OnAction()
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    IndentLines(TempProcessingPlan_SELECTED, -1);
                    CurrPage.Update(false);
                end;
            }
            action(IndentRight)
            {
                // Caption = 'Indent Right', Comment = 'de-DE=Rechts einrücken';
                Caption = ' ', Locked = true;
                ToolTip = 'Indent Right', Comment = 'de-DE=Rechts einrücken';
                ApplicationArea = All;
                Image = Indent;

                trigger OnAction()
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    IndentLines(TempProcessingPlan_SELECTED, +1);
                    CurrPage.Update(false);
                end;
            }
            action(CloneCurrLine)
            {
                // Caption = 'Indent Right', Comment = 'de-DE=Rechts einrücken';
                Caption = ' ', Locked = true;
                ToolTip = 'Clone Line', Comment = 'de-DE=Zeile klonen';
                ApplicationArea = All;
                Image = Copy;

                trigger OnAction()
                var
                    Line: Record DMTProcessingPlan;
                    NewLineNo: Integer;
                begin
                    NewLineNo := findNextLineNoBelow();
                    if NewLineNo <> 0 then begin
                        Clear(Line);
                        Rec.CalcFields("Source Table Filter", "Update Fields Filter", "Default Field Values");
                        Line := Rec;
                        Line."Line No." := NewLineNo;
                        Line.Insert();
                    end;
                end;
            }
            action(ResetLinesAction)
            {
                Caption = 'Reset Lines', Comment = 'de-DE=Status und Zeiten zurücksetzen';
                ApplicationArea = All;
                Image = Restore;

                trigger OnAction()
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    ResetLines(TempProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(RenumberLinesAction)
            {
                Caption = 'Renumber Lines', Comment = 'de-DE=Zeilen neu nummerieren';
                ApplicationArea = All;
                Image = NumberGroup;
                trigger OnAction()
                begin
                    RenumberLines()
                end;
            }
            action(XMLExport)
            {
                Caption = 'Create Backup', Comment = 'de-DE=Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;

                trigger OnAction()
                var
                    TableMetadata: Record "Table Metadata";
                    processingPlan: Record DMTProcessingPlan;
                    processingPlanBatch: Record DMTProcessingPlanBatch;
                    XMLBackup: Codeunit DMTXMLBackup;
                    RecordsToExport: List of [RecordId];
                begin
                    TableMetadata.Get(Database::DMTProcessingPlan);
                    // Export Batch
                    processingPlanBatch.Get(CurrentJnlBatchName);
                    RecordsToExport.Add(processingPlanBatch.RecordId);
                    // Export Batch Lines
                    processingPlan.SetRange("Journal Batch Name", CurrentJnlBatchName);
                    if processingPlan.FindSet(false) then
                        repeat
                            RecordsToExport.Add(processingPlan.RecordId);
                        until processingPlan.Next() = 0;
                    XMLBackup.ExportSelectedRecordIDs(RecordsToExport, TableMetadata.Caption + '_' + CurrentJnlBatchName + '_');
                end;
            }
            action(XMLImport)
            {
                Caption = 'Import Backup', Comment = 'de-DE=Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Import();
                end;
            }
            action(RetryBufferRecordsWithError)
            {
                Caption = ' ', Locked = true;
                ToolTip = 'Retry Records With Error', Comment = 'de-DE=Fehler erneut verarbeiten';
                ApplicationArea = All;
                Image = Redo;
                Enabled = RetryBufferRecordsWithError_Enabled;
                Visible = RetryBufferRecordsWithError_Enabled;
                trigger OnAction()
                var
                    migrateRecordSet: Codeunit DMTMigrateRecordSet;
                begin
                    if Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Buffer + Target"] then
                        migrateRecordSet.RetryErrors(Rec);
                end;
            }
            action(CopySelectedLinesToBatch)
            {
                Caption = 'Copy to Batch', Comment = 'de-DE=In Buch.-Blatt kopieren';
                ApplicationArea = All;
                Image = CopyWorksheet;

                trigger OnAction()
                var
                    processingPlanBatch: Record DMTProcessingPlanBatch;
                    processingPlan: Record DMTProcessingPlan;
                    TempProcessingPlan_SELECTED: Record DMTProcessingPlan temporary;
                begin
                    if not GetSelection(TempProcessingPlan_SELECTED) then
                        exit;
                    processingPlanBatch.SetFilter(Name, '<>%1', CurrentJnlBatchName);
                    if Page.RunModal(0, processingPlanBatch) <> Action::LookupOK then
                        exit;
                    if processingPlanBatch.Name = CurrentJnlBatchName then
                        exit;
                    TempProcessingPlan_SELECTED.FindSet();
                    repeat
                        processingPlan.Get(TempProcessingPlan_SELECTED.RecordId);
                        processingPlan."Journal Batch Name" := processingPlanBatch.Name;
                        processingPlan."Line No." := processingPlan.getNextLineNo();
                        clearProcessingInfo(processingPlan);
                        processingPlan.Insert();
                        processingPlan.CopyLinks(TempProcessingPlan_SELECTED);
                    until TempProcessingPlan_SELECTED.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            actionref(StartRef; Start) { }
            actionref(RetryBufferRecordsWithErrorRef; RetryBufferRecordsWithError) { }
            actionref(NewLineRef; NewLine) { }
            actionref(DeleteLineRef; DeleteLine) { }
            actionref(IndentLeftRef; IndentLeft) { }
            actionref(IndentRightRef; IndentRight) { }
            actionref(CloneCurrLineRef; CloneCurrLine) { }
            group(Backup)
            {
                ShowAs = Standard;
                Caption = 'Backup', Locked = true;
                Image = XMLSetup;
                actionref(XMLExportRef; XMLExport) { }
                actionref(XMLImportRef; XMLImport) { }
            }
            group(LineActions)
            {
                ShowAs = Standard;
                Caption = 'Lines', Comment = 'de-DE=Zeilen';
                Image = AllLines;
                actionref(RenumberLinesActionRef; RenumberLinesAction) { }
                actionref(ResetLinesActionRef; ResetLinesAction) { }
                actionref(CopySelectedLinesToBatchRef; CopySelectedLinesToBatch) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.InitFlowFilters();
        LineStyle := '';
        case true of
            (Rec.Type = Rec.Type::Group):
                LineStyle := Format(Enum::DMTFieldStyle::Bold);
            (Rec.Status = Rec.Status::"In Progress"):
                LineStyle := Format(Enum::DMTFieldStyle::Yellow);
            (Rec.Status = Rec.Status::Error):
                LineStyle := Format(Enum::DMTFieldStyle::"Red + Italic");
            (Rec.Status = Rec.Status::Finished):
                LineStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;
        TargetTableID_HideValue := not Rec.TypeSupportsProcessSelectedFieldsOnly();

        Clear(CurrImportConfigHeader);
        HasImportConfigHeader := Rec.findImportConfigHeader(CurrImportConfigHeader);
    end;

    trigger OnAfterGetCurrRecord()
    var
        importConfigHeader: Record DMTImportConfigHeader;
    begin
        ShowSupportedFactboxes();
        CurrPage.SourceTableFilter.Page.InitFactBoxAsSourceTableFilter(Rec);
        CurrPage.FixedValues.Page.InitFactBoxAsFixedValueView(Rec);
        CurrPage.UpdateSelectedFieldsOnly.Page.InitFactBoxAsUpdateSelectedFields(Rec);
        if Rec.findImportConfigHeader(importConfigHeader) then begin
            CurrPage.LogFactBox.Page.ShowAsLogAndUpdateOnAfterGetCurrRecord(importConfigHeader);
            CurrPage.LogFactBox.Page.Update(false);
        end;
        TargetTableID_HideValue := not Rec.TypeSupportsProcessSelectedFieldsOnly();
        RetryBufferRecordsWithError_Enabled := (Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Buffer + Target"]) and (Rec.Status = Rec.Status::Error);
    end;

    local procedure RunSelected(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        ProcessingPlan: Record DMTProcessingPlan;
        ProcessStorage: Codeunit DMTProcessStorage;
        CodunitRunSuccessful: Boolean;
        HasErrors: Boolean;
    begin
        ProcessingPlan_SELECTED.SetFilter(Type, '<>%1&<>%2', ProcessingPlan_SELECTED.Type::Group, ProcessingPlan_SELECTED.Type::" ");
        if not ProcessingPlan_SELECTED.FindSet() then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.TestField(ID);
            case ProcessingPlan.Type of
                DMTProcessingPlanType::" ", DMTProcessingPlanType::"Group":
                    ;
                DMTProcessingPlanType::"Import To Buffer":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ImportConfigHeader.Get(ProcessingPlan.ID);
                        ImportConfigHeader.SetRecFilter();
                        ProcessingPlanMgt.ImportToBufferTable(ImportConfigHeader, false);
                    end;
                DMTProcessingPlanType::"Import To Target":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        if not ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan) then
                            HasErrors := true;
                    end;
                DMTProcessingPlanType::"Run Codeunit":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ClearLastError();
                        ProcessStorage.Set(ProcessingPlan);
                        CodunitRunSuccessful := Codeunit.Run(ProcessingPlan.ID);
                        if GetLastErrorText() <> '' then
                            Message(GetLastErrorText());
                    end;
                DMTProcessingPlanType::"Update Field":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        if ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan) then
                            HasErrors := true;
                    end;
                DMTProcessingPlanType::"Buffer + Target":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ImportConfigHeader.Get(ProcessingPlan.ID);
                        ImportConfigHeader.SetRecFilter();
                        if not ProcessingPlanMgt.ImportToBufferTable(ImportConfigHeader, false) then
                            HasErrors := true;
                        if not ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan) then
                            HasErrors := true;
                    end;
                DMTProcessingPlanType::"Enter default values in target table":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        if not ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan) then
                            HasErrors := true;
                    end;
                else
                    Error('Unhandled ProcessingPlan Type %1', ProcessingPlan.Type);
            end;
            ProcessingPlan."Processing Duration" := CurrentDateTime - ProcessingPlan.StartTime;
            ProcessingPlan.Status := ProcessingPlan.Status::Finished;
            if HasErrors or ((ProcessingPlan.Type = DMTProcessingPlanType::"Run Codeunit") and not CodunitRunSuccessful) then
                ProcessingPlan.Status := ProcessingPlan.Status::Error;
            ProcessingPlan.Modify();
            Commit();
            ProcessStorage.Unbind();
        until ProcessingPlan_SELECTED.Next() = 0;
    end;

    local procedure ResetLines(var ProcessingPlan_SELECTED_NEW: Record DMTProcessingPlan temporary)
    var
        ProcessingPlan: Record DMTProcessingPlan;
    begin
        if not ProcessingPlan_SELECTED_NEW.FindSet() then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED_NEW.RecordId);
            clearProcessingInfo(ProcessingPlan);
            ProcessingPlan.Modify();
            Commit();
        until ProcessingPlan_SELECTED_NEW.Next() = 0;
    end;

    local procedure SetStatusToStartAndCommit(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        ProcessingPlan.StartTime := CurrentDateTime;
        ProcessingPlan.Status := ProcessingPlan.Status::"In Progress";
        ProcessingPlan.Modify();
        Commit();
    end;

    local procedure RenumberLines()
    var
        ProcessingPlan: Record DMTProcessingPlan;
        LineNoMapping: Dictionary of [Integer, Integer];
        OldLineNo, NewLineNo : Integer;
    begin
        if not ProcessingPlan.FindSet() then exit;
        //Create Mapping
        repeat
            NewLineNo += 10000;
            LineNoMapping.Add(ProcessingPlan."Line No.", NewLineNo);
        until ProcessingPlan.Next() = 0;
        //Rename Lines
        while LineNoMapping.Count > 0 do begin
            foreach OldLineNo in LineNoMapping.Keys do begin
                // Remove from mapping if same line no
                NewLineNo := LineNoMapping.Get(OldLineNo);
                if OldLineNo = NewLineNo then
                    LineNoMapping.Remove(OldLineNo);
                // Rename Line to free line no, Remove From Mapping
                if not LineNoMapping.Keys.Contains(NewLineNo) then begin
                    ProcessingPlan.Get(OldLineNo);
                    ProcessingPlan.Rename(NewLineNo);
                    LineNoMapping.Remove(OldLineNo);
                end;
            end;
        end;
    end;

    procedure GetSelection(var TempProcessingPlan_SelectedNew: Record DMTProcessingPlan temporary) HasLines: Boolean
    var
        ProcessingPlan, ProcessingPlan_GroupElements : Record DMTProcessingPlan;
        Debug: Integer;
    begin
        Clear(TempProcessingPlan_SelectedNew);
        if TempProcessingPlan_SelectedNew.IsTemporary then
            TempProcessingPlan_SelectedNew.DeleteAll();

        ProcessingPlan.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(ProcessingPlan);
        Debug := ProcessingPlan.Count;
        ProcessingPlan.CopyToTemp(TempProcessingPlan_SelectedNew);
        HasLines := TempProcessingPlan_SelectedNew.FindFirst();
        // add lines if only group is selected
        if ProcessingPlan.Count = 1 then
            if ProcessingPlan.Type = ProcessingPlan.Type::Group then begin
                ProcessingPlan_GroupElements := ProcessingPlan;
                while ProcessingPlan_GroupElements.Next() <> 0 do begin
                    // not indented lines
                    if ProcessingPlan.Indentation = ProcessingPlan_GroupElements.Indentation then
                        break;
                    // next group line
                    if ProcessingPlan_GroupElements.Type = ProcessingPlan.Type::Group then
                        break;
                    // insert group elements
                    if not TempProcessingPlan_SelectedNew.Get(ProcessingPlan_GroupElements.RecordId) then begin
                        TempProcessingPlan_SelectedNew := ProcessingPlan_GroupElements;
                        TempProcessingPlan_SelectedNew.Insert(false);
                    end;
                end;
            end;
    end;

    internal procedure IndentLines(var TempProcessingPlan: Record DMTProcessingPlan temporary; Direction: Integer)
    var
        ProcessingPlan: Record DMTProcessingPlan;
    begin
        if not TempProcessingPlan.FindSet() then exit;
        repeat
            ProcessingPlan.Get(TempProcessingPlan.RecordId);
            ProcessingPlan.Indentation += Direction;
            if ProcessingPlan.Indentation < 0 then
                ProcessingPlan.Indentation := 0;
            ProcessingPlan.Modify()
        until TempProcessingPlan.Next() = 0;
    end;

    local procedure ShowSupportedFactboxes()
    begin
        ShowSourceTableFilterPart := Rec.TypeSupportsSourceTableFilter();
        ShowFixedValuesPart := Rec.TypeSupportsFixedValues();
        ShowProcessSelectedFieldsOnly := Rec.TypeSupportsProcessSelectedFieldsOnly();
        ShowLogFactboxPart := Rec.TypeSupportsLog();
    end;

    local procedure findNextLineNoBelow() NewLineNo: Integer
    var
        Line: Record DMTProcessingPlan;
        LineBefore: Record DMTProcessingPlan;
        NextLineNo: Integer;
        LastLineNo: Integer;
    begin
        // find last line no
        Clear(Line);
        Line.SetRange("Journal Batch Name", CurrentJnlBatchName);
        if Line.FindLast() then
            LastLineNo := Line."Line No.";
        // find line before current rec
        LineBefore := Rec;
        LineBefore.SetRange("Journal Batch Name", CurrentJnlBatchName);
        if LineBefore.Next(-1) <> -1 then
            Clear(LineBefore);

        // find line no after current rec
        Line := Rec;
        if Line.Next(1) <> 1 then
            Clear(Line);
        NextLineNo := Line."Line No.";
        case true of
            // Rec is last line oder first line
            (Rec."Line No." = LastLineNo):
                NewLineNo := LastLineNo + 10000;
            // new line below current line
            (Rec."Line No." < LastLineNo) and (NextLineNo > Rec."Line No."):
                NewLineNo := (Rec."Line No." + NextLineNo) div 2;
        end;
    end;

    local procedure ChangeJournalBatch()
    begin
        GlobalProcessingPlanBatch.Get(CurrentJnlBatchName);

        CurrPage.SaveRecord();

        Rec.FilterGroup(2);
        Rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
        Rec.FilterGroup(0);

        CurrPage.Update(false);
    end;

    trigger OnOpenPage()
    begin
        SetCurrentBatchSuite();
        fillEmptyBatchName();
    end;

    local procedure SetCurrentBatchSuite()
    begin

        if not GlobalProcessingPlanBatch.Get(CurrentJnlBatchName) then
            if (CurrentJnlBatchName = '') and GlobalProcessingPlanBatch.FindFirst() then
                CurrentJnlBatchName := GlobalProcessingPlanBatch.Name
            else begin
                CreateBatchName(CurrentJnlBatchName);
                Commit();
                GlobalProcessingPlanBatch.Get(CurrentJnlBatchName);
            end;

        Rec.FilterGroup(2);
        Rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
        Rec.FilterGroup(0);

        if Rec.Find('-') then;
    end;

    local procedure fillEmptyBatchName()
    var
        processingPlan: Record DMTProcessingPlan;
        processingPlan2: Record DMTProcessingPlan;
        batchName: Code[20];
    begin
        batchName := 'Standard';
        processingPlan.Reset();
        processingPlan.SetRange("Journal Batch Name", '');
        if processingPlan.FindSet() then
            repeat
                processingPlan2 := processingPlan;
                processingPlan2.Rename(batchName, processingPlan2."Line No.");
            until processingPlan.Next() = 0;
    end;

    local procedure clearProcessingInfo(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        Clear(ProcessingPlan.Status);
        Clear(ProcessingPlan.StartTime);
        Clear(ProcessingPlan."Processing Duration");
    end;

    procedure CreateBatchName(var batchName: Code[20])
    var
        processingPlanBatch: Record DMTProcessingPlanBatch;
    begin
        if batchName = '' then
            batchName := 'Standard';

        processingPlanBatch.Name := CopyStr(batchName, 1, MaxStrLen(processingPlanBatch.Name));
        processingPlanBatch.Insert(true);
        fillEmptyBatchName();
    end;

    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        TempProcessingPlan_SELECTED: Record DMTProcessingPlan temporary;
        GlobalProcessingPlanBatch: Record DMTProcessingPlanBatch;
        ProcessingPlanMgt: Codeunit DMTProcessingPlanMgt;
        HasImportConfigHeader: Boolean;
        RetryBufferRecordsWithError_Enabled: Boolean;
        ShowFixedValuesPart, ShowLogFactboxPart, ShowProcessSelectedFieldsOnly, ShowSourceTableFilterPart, TargetTableID_HideValue : Boolean;
        CurrentJnlBatchName: Code[20];
        LineStyle: Text;
}