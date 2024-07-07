page 91017 DMTProcessingPlan
{
    Caption = 'DMT Processing Plan', Comment = 'de-DE=DMT Verarbeitungsplan';
    AdditionalSearchTerms = 'DMT Plan', Locked = true;
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTProcessingPlan;
    AutoSplitKey = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater("Repeater")
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;
                // Visible = ShowTreeView;
                field("Line Type"; Rec.Type) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ImportConfigHeaderID; Rec.ID) { ApplicationArea = All; StyleExpr = LineStyle; BlankZero = true; }
                field(Description; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ProcessingTime; Rec."Processing Duration") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StartTime; Rec.StartTime) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Source Table No."; Rec."Source Table No.") { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
            }
        }
        area(FactBoxes)
        {
            part(SourceTableFilter; DMTProcessInstructionFactBox)
            {
                Caption = 'Source Table Filter', Comment = 'de-DE=Quelldaten Filter';
                SubPageLink = PrPl_FBRunMode_Filter = const(SourceTableFilter), PrPl_LineNo_Filter = field("Line No.");
                UpdatePropagation = Both;
                Enabled = ShowSourceTableFilterPart;
            }
            part(FixedValues; DMTProcessInstructionFactBox)
            {
                Caption = 'Default Values', Comment = 'de-DE=Vorgabewerte';
                SubPageLink = PrPl_FBRunMode_Filter = const(FixedValueView), PrPl_LineNo_Filter = field("Line No.");
                UpdatePropagation = Both;
                Enabled = ShowFixedValuesPart;
            }
            part(UpdateSelectedFieldsOnly; DMTProcessInstructionFactBox)
            {
                Caption = 'Process selected fields only', Comment = 'de-DE=Ausgew. Felder verarbeiten';
                SubPageLink = PrPl_FBRunMode_Filter = const(UpdateSelectedFields), PrPl_LineNo_Filter = field("Line No.");
                UpdatePropagation = Both;
                Enabled = ShowProcessSelectedFieldsOnly;
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
                ShortcutKey = 'Ctrl+Delete'; //TODO ShortcutKey geht nicht, Ctrl+ ist richtig
                Image = Delete;
                trigger OnAction()
                begin
                    if Rec."Line No." <> 0 then // no error when empty
                        Rec.Delete();
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
                    XMLBackup: Codeunit DMTXMLBackup;
                    TablesToExport: List of [Integer];
                begin
                    TableMetadata.Get(Database::DMTProcessingPlan);
                    TablesToExport.Add(Database::DMTProcessingPlan);
                    XMLBackup.Export(TablesToExport, TableMetadata.Caption);
                end;
            }
            action(XMLImport)
            {
                Caption = 'Import Backup', Comment = 'de-DE=Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    ImportConfigHeader: Record DMTImportConfigHeader;
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Import();
                    // Update imported "Qty.Lines In Trgt. Table" with actual values
                    if ImportConfigHeader.FindSet() then
                        repeat
                            ImportConfigHeader.UpdateBufferRecordCount();
                        until ImportConfigHeader.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            actionref(StartRef; Start) { }
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
                // group(XMLBackupActions)
                // {
                // Caption = 'XML Backup2', Locked = true;
                // Image = XMLSetup;
                actionref(XMLExportRef; XMLExport) { }
                actionref(XMLImportRef; XMLImport) { }
                // }
            }
            group(LineActions)
            {
                ShowAs = Standard;
                Caption = 'Lines', Comment = 'de-DE=Zeilen';
                Image = AllLines;
                actionref(RenumberLinesActionRef; RenumberLinesAction) { }
                actionref(ResetLinesActionRef; ResetLinesAction) { }
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
            (Rec.Status = Rec.Status::Finished):
                LineStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ShowSupportedFactboxes();
        CurrPage.SourceTableFilter.Page.InitFactBoxAsSourceTableFilter(Rec);
        CurrPage.FixedValues.Page.InitFactBoxAsFixedValueView(Rec);
        CurrPage.UpdateSelectedFieldsOnly.Page.InitFactBoxAsUpdateSelectedFields(Rec);
    end;

    local procedure RunSelected(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        ProcessingPlan: Record DMTProcessingPlan;
        ProcessStorage: Codeunit DMTProcessStorage;
        Success: Boolean;
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
                        ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan);
                    end;
                DMTProcessingPlanType::"Run Codeunit":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ClearLastError();
                        ProcessStorage.Set(ProcessingPlan);
                        Success := Codeunit.Run(ProcessingPlan.ID);
                        if GetLastErrorText() <> '' then
                            Message(GetLastErrorText());
                    end;
                DMTProcessingPlanType::"Update Field":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan);
                    end;
                DMTProcessingPlanType::"Buffer + Target":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ImportConfigHeader.Get(ProcessingPlan.ID);
                        ImportConfigHeader.SetRecFilter();
                        ProcessingPlanMgt.ImportToBufferTable(ImportConfigHeader, false);
                        ProcessingPlanMgt.ImportWithProcessingPlanParams(ProcessingPlan);
                    end;
            end;
            ProcessingPlan."Processing Duration" := CurrentDateTime - ProcessingPlan.StartTime;
            ProcessingPlan.Status := ProcessingPlan.Status::Finished;
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
            Clear(ProcessingPlan.Status);
            Clear(ProcessingPlan.StartTime);
            Clear(ProcessingPlan."Processing Duration");
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
        ProcessingPlan: Record DMTProcessingPlan;
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
        if Line.FindLast() then
            LastLineNo := Line."Line No.";
        // find line before current rec
        LineBefore := Rec;
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

    var
        TempProcessingPlan_SELECTED: Record DMTProcessingPlan temporary;
        ProcessingPlanMgt: Codeunit DMTProcessingPlanMgt;
        // [InDataSet]
        ShowFixedValuesPart, ShowProcessSelectedFieldsOnly, ShowSourceTableFilterPart : Boolean;
        LineStyle: Text;
}