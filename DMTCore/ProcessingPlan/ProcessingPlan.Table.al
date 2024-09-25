table 91009 DMTProcessingPlan
{
    DataClassification = ToBeClassified;
    Caption = 'DMTProcessingPlan', Locked = true;
    LookupPageId = DMTProcessingPlan;

    fields
    {
        field(1; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennr.'; }
        field(10; Type; Enum DMTProcessingPlanType)
        {
            Caption = 'Type', Comment = 'de-DE=Art';

            trigger OnValidate()
            begin
                if xRec.Type = xRec.Type::" " then
                    if Rec.Type = Rec.Type::Group then begin
                        Clear(Description);
                        Clear(ID);
                    end;
            end;
        }
        field(11; ID; Integer)
        {
            Caption = 'ID', Locked = true;
            TableRelation =
            if (Type = const("Run Codeunit")) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit))
            else
            DMTImportConfigHeader.ID;
            trigger OnValidate()
            var
                CodeUnitMetadata: Record "CodeUnit Metadata";
                DMTImportConfigHeader: Record DMTImportConfigHeader;
            begin
                case true of
                    (xRec.ID <> 0) and (Rec.ID = 0):
                        Description := '';
                    (Rec.ID <> 0) and (Type in [Type::"Import To Buffer", Type::"Import To Target", Type::"Update Field", Type::"Buffer + Target"]):
                        begin
                            DMTImportConfigHeader.Get(Rec.ID);
                            Description := DMTImportConfigHeader.GetSourceFileStorage().Name;
                            "Source Table No." := 0;
                        end;
                    (Rec.ID <> 0) and (Type in [Type::"Run Codeunit"]):
                        begin
                            CodeUnitMetadata.Get(Rec.ID);
                            Description := CodeUnitMetadata.Name;
                        end;
                end;
                CalcFields("No.of Records in Buffer Table", "No.of Records in Buffer Table");
            end;
        }
        field(12; Description; Text[250]) { Caption = 'Description', Comment = 'de-DE=Beschreibung'; }
        field(30; "Source Table No."; Integer)
        {
            Caption = 'Source Table No. (Codeunit)', Comment = 'de-DE=Herkunftstabellennr. (Codeunit)';
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(31; "Current App Package ID Filter"; Guid) { Caption = 'Current Package ID Filter', Locked = true; FieldClass = FlowFilter; }
        field(32; "Source Table Filter"; Blob) { Caption = 'Source Table Filter Blob', Locked = true; }
        field(33; "Update Fields Filter"; Blob) { Caption = 'Update Fields Filter', Locked = true; }
        field(34; "Default Field Values"; Blob) { Caption = 'Default Field Values', Locked = true; }
        field(40; Status; Option) { Caption = 'Status', Locked = true; OptionMembers = " ","In Progress",Finished,Error; OptionCaption = ' ,In Progress,Finished,Error', comment = 'de-DE= ,in Arbeit,Abgeschlossen,Fehler'; Editable = false; }
        field(41; StartTime; DateTime) { Caption = 'Start Time', Comment = 'de-DE=Startzeit'; Editable = false; }
        field(42; "Processing Duration"; Duration) { Caption = 'Processing Duration', Comment = 'de-DE=Verarbeitungszeit'; Editable = false; }
        field(50; Indentation; Integer) { Caption = 'Indentation', Comment = 'de-DE=Einrückung'; Editable = false; }
        field(57; "Max No. of Records to Process"; Integer)
        {
            Caption = 'Max No. of Records to Process', Comment = 'de-DE=max. Anzahl der zu verarbeitenden Datensätze';
            BlankZero = true;
            MinValue = 0;
        }
        field(60; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', Comment = 'de-DE=Zieltabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            FieldClass = FlowField;
            CalcFormula = lookup(DMTImportConfigHeader."Target Table ID" where(ID = field(ID)));
            Editable = false;
            BlankZero = true;
        }
        field(61; "No.of Records in Buffer Table"; Integer)
        {
            Caption = 'No.of Records in Buffer Table', Comment = 'de-DE=Anz. Datensätze in Puffertabelle';
            FieldClass = FlowField;
            CalcFormula = lookup(DMTImportConfigHeader."No.of Records in Buffer Table" where(ID = field(ID)));
            Editable = false;
            BlankZero = true;
        }
        field(70; "Journal Batch Name"; Code[20])
        {
            Caption = 'Journal Batch Name', Comment = 'de-DE=Buch.-Blattname';
            TableRelation = DMTProcessingPlanBatch.Name;
        }

    }

    keys
    {
        key(PK; "Journal Batch Name", "Line No.") { Clustered = true; }
    }

    procedure EditSourceTableFilter()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        FPBuilder: Codeunit DMTFPBuilder;
        BufferRef: RecordRef;
        CurrView: Text;
    begin
        if Rec.Type = Rec.Type::"Run Codeunit" then begin
            Rec.TestField("Source Table No.");
            BufferRef.Open(Rec."Source Table No.");
            // ImportConfigHeader.BufferTableType := ImportConfigHeader.BufferTableType::"Seperate Buffer Table per CSV";
        end else begin
            ImportConfigHeader.Get(Rec.ID);
            ImportConfigHeader.BufferTableMgt().ThrowErrorIfBufferTableIsEmpty();
            ImportConfigHeader.BufferTableMgt().InitBufferRef(BufferRef, true);
        end;
        CurrView := ReadSourceTableView();
        if CurrView <> '' then
            BufferRef.SetView(CurrView);
        if FPBuilder.RunModal(BufferRef, ImportConfigHeader) then begin
            SaveSourceTableFilter(BufferRef.GetView(false));
        end;
    end;

    procedure EditDefaultValues()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        FPBuilder: Codeunit DMTFPBuilder;
        TargetRef: RecordRef;
        CurrView: Text;
    begin
        ImportConfigHeader.Get(Rec.ID);
        ImportConfigHeader.BufferTableMgt().ThrowErrorIfBufferTableIsEmpty();
        TargetRef.Open(ImportConfigHeader."Target Table ID");
        CurrView := ReadDefaultValuesView();
        if CurrView <> '' then
            TargetRef.SetView(CurrView);
        if FPBuilder.RunModal(TargetRef) then begin
            SaveDefaultValuesView(TargetRef.GetView());
        end;
    end;

    procedure ReadSourceTableView() SourceTableView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields("Source Table Filter");
        if not Rec."Source Table Filter".HasValue then exit('');
        Rec."Source Table Filter".CreateInStream(IStr);
        IStr.ReadText(SourceTableView);
    end;

    procedure ReadDefaultValuesView() DefaultValuesView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields("Default Field Values");
        if not Rec."Default Field Values".HasValue then exit('');
        Rec."Default Field Values".CreateInStream(IStr);
        IStr.ReadText(DefaultValuesView);
    end;

    procedure ReadUpdateFieldsFilter() FilterExpr: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields("Update Fields Filter");
        if not Rec."Update Fields Filter".HasValue then exit('');
        Rec."Update Fields Filter".CreateInStream(IStr);
        IStr.ReadText(FilterExpr);
    end;

    procedure SaveSourceTableFilter(SourceTableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Source Table Filter");
        Rec.Modify();
        if SourceTableView = '' then
            exit;
        Rec."Source Table Filter".CreateOutStream(OStr);
        OStr.WriteText(SourceTableView);
        Rec.Modify();
    end;

    procedure SaveDefaultValuesView(DefaultValuesView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Default Field Values");
        Rec.Modify();
        if DefaultValuesView = '' then
            exit;
        Rec."Default Field Values".CreateOutStream(OStr);
        OStr.WriteText(DefaultValuesView);
        Rec.Modify();
    end;

    procedure SaveUpdateFieldsFilter(UpdateFieldsFilter: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Update Fields Filter");
        Rec.Modify();
        if UpdateFieldsFilter = '' then
            exit;
        Rec."Update Fields Filter".CreateOutStream(OStr);
        OStr.WriteText(UpdateFieldsFilter);
        Rec.Modify();
    end;

    procedure CopyToTemp(var TempProcessingPlan: Record DMTProcessingPlan temporary) LineCount: Integer
    var
        ProcessingPlan: Record DMTProcessingPlan;
        TempProcessingPlan2: Record DMTProcessingPlan temporary;
    begin
        ProcessingPlan.Copy(Rec);
        if ProcessingPlan.FindSet(false) then
            repeat
                LineCount += 1;
                TempProcessingPlan2 := ProcessingPlan;
                TempProcessingPlan2.Insert(false);
            until ProcessingPlan.Next() = 0;
        TempProcessingPlan.Copy(TempProcessingPlan2, true);
    end;

    procedure CreateSourceTableRef(var SourceRef: RecordRef) Ok: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
    begin
        Clear(SourceRef);
        if Rec.ID = 0 then exit(false);
        case Rec.Type of
            Rec.Type::"Run Codeunit":
                begin
                    SourceRef.Open(Rec."Source Table No.", false);
                    exit(true);
                end;
            else begin
                if not ImportConfigHeader.Get(Rec.ID) then
                    exit(false);
                ImportConfigHeader.BufferTableMgt().InitBufferRef(SourceRef);
                exit(true)
            end;
        end;
    end;

    procedure ConvertSourceTableFilterToFieldLines(var TmpImportConfigLine: Record DMTImportConfigLine temporary; ImportConfigHeaderID: Integer)
    var
        genBuffTable: Record DMTGenBuffTable;
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
        RecRef: RecordRef;
        FieldIndexNo: Integer;
        CurrView: Text;
    begin
        if not (rec.Type in [rec.Type::"Buffer + Target", Rec.Type::"Import To Target", rec.Type::"Update Field"]) then
            exit;
        if (rec.Type = rec.Type::"Run Codeunit") and (rec."Target Table ID" = 0) then
            exit;
        if rec.ID = 0 then exit;
        if not hasValidSourceTable(ImportConfigHeaderID) then
            exit;
        if not Rec.CreateSourceTableRef(RecRef) then
            exit;
        if RecRef.Name = genBuffTable.TableName then begin
            RecRef.SetTable(genBuffTable);
            if not genBuffTable.HasCaptionLine(ImportConfigHeaderID) then begin
                TmpImportConfigLine.Copy(TempImportConfigLine2, true);
                exit;
            end;
            genBuffTable.InitFirstLineAsCaptions(genBuffTable); // init column caption single instance codeunit
            RecRef.GetTable(genBuffTable);
        end;
        CurrView := Rec.ReadSourceTableView();
        if CurrView <> '' then begin
            RecRef.SetView(CurrView);
            if RecRef.HasFilter then begin

                for FieldIndexNo := 1 to RecRef.FieldCount do begin
                    if RecRef.FieldIndex(FieldIndexNo).GetFilter <> '' then begin
                        TempImportConfigLine2."Imp.Conf.Header ID" := Rec.ID;
                        TempImportConfigLine2."Target Field No." := RecRef.FieldIndex(FieldIndexNo).Number;
                        TempImportConfigLine2."Source Field Caption" := CopyStr(RecRef.FieldIndex(FieldIndexNo).Caption, 1, MaxStrLen(TempImportConfigLine2."Source Field Caption"));
                        TempImportConfigLine2."Fixed Value" := CopyStr(RecRef.FieldIndex(FieldIndexNo).GetFilter, 1, MaxStrLen(TempImportConfigLine2."Fixed Value"));
                        TempImportConfigLine2.Insert();
                    end;
                end;
                TmpImportConfigLine.Copy(TempImportConfigLine2, true);
            end;
        end;

    end;

    procedure ConvertDefaultValuesViewToFieldLines(var TmpImportConfigLine: Record DMTImportConfigLine temporary) LineCount: Integer
    var
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
        ImportConfigHeader: Record DMTImportConfigHeader;
        ImportConfigLine: Record DMTImportConfigLine;
        RecRef: RecordRef;
        FieldIndexNo: Integer;
        CurrView: Text;
    begin
        if not ImportConfigHeader.Get(Rec.ID) then exit; // ID can be zero
        RecRef.Open(ImportConfigHeader."Target Table ID");
        CurrView := Rec.ReadDefaultValuesView();
        if CurrView <> '' then begin
            RecRef.SetView(CurrView);
            if RecRef.HasFilter then
                for FieldIndexNo := 1 to RecRef.FieldCount do begin
                    if RecRef.FieldIndex(FieldIndexNo).GetFilter <> '' then begin
                        ImportConfigLine.Get(Rec.ID, RecRef.FieldIndex(FieldIndexNo).Number);
                        TempImportConfigLine2 := ImportConfigLine;
                        TempImportConfigLine2."Processing Action" := TempImportConfigLine2."Processing Action"::FixedValue;
                        TempImportConfigLine2."Fixed Value" := CopyStr(RecRef.FieldIndex(FieldIndexNo).GetFilter, 1, MaxStrLen(TempImportConfigLine2."Fixed Value"));
                        cleanUpFixedValue(TempImportConfigLine2);
                        TempImportConfigLine2.Insert();
                    end;
                end;
            TmpImportConfigLine.Copy(TempImportConfigLine2, true);
            LineCount := TmpImportConfigLine.Count;
        end;
    end;

    local procedure cleanUpFixedValue(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    var
        fixedValueText: Text;
    begin
        // if filter value contains spaces, brackets or quotes then the filter value is enclosed in quotes
        fixedValueText := TempImportConfigLine."Fixed Value";
        if fixedValueText = '' then exit;
        if not (fixedValueText.EndsWith('''') and fixedValueText.StartsWith('''')) then
            exit;
        if StrLen(fixedValueText) = StrLen(DelChr(fixedValueText, '=', '() ')) then
            exit;
        fixedValueText := CopyStr(fixedValueText, 2, StrLen(fixedValueText) - 2);
        TempImportConfigLine."Fixed Value" := CopyStr(fixedValueText, 1, MaxStrLen(TempImportConfigLine."Fixed Value"));
    end;

    procedure ConvertUpdateFieldsListToFieldLines(var TmpImportConfigLine: Record DMTImportConfigLine temporary) LineCount: Integer
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        ImportConfigLine: Record DMTImportConfigLine;
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
        RecRef: RecordRef;
        FieldNoFilter: Text;
    begin
        if not ImportConfigHeader.Get(Rec.ID) then exit;
        if not hasValidSourceTable(ImportConfigHeader.ID) then
            exit;
        if not Rec.CreateSourceTableRef(RecRef) then exit;
        FieldNoFilter := Rec.ReadUpdateFieldsFilter();
        if FieldNoFilter <> '' then begin
            ImportConfigHeader.FilterRelated(ImportConfigLine);
            ImportConfigLine.SetFilter("Target Field No.", FieldNoFilter);
            if ImportConfigLine.FindSet(false) then
                repeat
                    TempImportConfigLine2 := ImportConfigLine;
                    TempImportConfigLine2.Insert();
                until ImportConfigLine.Next() = 0;
        end;

        TmpImportConfigLine.Copy(TempImportConfigLine2, true);
        LineCount := TmpImportConfigLine.Count;
    end;

    internal procedure InitFlowFilters()
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        mI: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mI);
        NAVAppInstalledApp.SetRange("App ID", mI.Id);
        NAVAppInstalledApp.FindFirst();
        Rec.FilterGroup(2);
        Rec.SetRange("Current App Package ID Filter", NAVAppInstalledApp."Package ID");
        Rec.FilterGroup(0);
    end;

    procedure TypeSupportsSourceTableFilter() IsSupported: Boolean
    begin
        IsSupported := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Run Codeunit", Rec.Type::"Buffer + Target"];
    end;

    procedure TypeSupportsProcessSelectedFieldsOnly() IsSupported: Boolean
    begin
        IsSupported := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target"];
    end;

    procedure TypeSupportsFixedValues() IsSupported: Boolean
    begin
        IsSupported := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target", Rec.Type::"Enter default values in target table"];
    end;

    internal procedure TypeSupportsLog() IsSupported: Boolean
    begin
        IsSupported := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target", Rec.Type::"Enter default values in target table"];
    end;

    internal procedure New()
    var
        processingPlan: Record DMTProcessingPlan;
    begin
        processingPlan."Line No." := Rec.getNextLineNo();
        Rec.Copy(processingPlan);
    end;

    internal procedure getIndentation() indentationFound: Integer
    var
        processingPlan: Record DMTProcessingPlan;
        tempProcessingPlan: Record DMTProcessingPlan temporary;
    begin
        if Rec.IsTemporary then begin

            tempProcessingPlan.Copy(Rec, true);
            if not tempProcessingPlan.get(Rec.RecordId) then
                exit(0);

            tempProcessingPlan.Reset();
            tempProcessingPlan.get(Rec.RecordId);
            if tempProcessingPlan.Next(-1) = -1 then begin
                if tempProcessingPlan.Type = tempProcessingPlan.Type::Group then begin
                    // Lines below group: indent + 1
                    indentationFound := tempProcessingPlan.Indentation + 1;
                end else begin
                    // other keep indentation from above
                    indentationFound := tempProcessingPlan.Indentation;
                end;
                exit(indentationFound);
            end;

        end else begin

            if not processingPlan.get(Rec.RecordId) then
                exit(0);

            processingPlan.Reset();
            processingPlan.get(Rec.RecordId);
            if processingPlan.Next(-1) = -1 then begin
                if processingPlan.Type = processingPlan.Type::Group then begin
                    // Lines below group: indent + 1
                    indentationFound := processingPlan.Indentation + 1;
                end else begin
                    // other keep indentation from above
                    indentationFound := processingPlan.Indentation;
                end;
                exit(indentationFound);
            end;

        end;
    end;

    procedure getNextLineNo() nextLineNo: Integer
    var
        processingPlan: Record DMTProcessingPlan;
        tempProcessingPlan: Record DMTProcessingPlan temporary;
    begin
        if Rec.IsTemporary then begin
            tempProcessingPlan.Copy(Rec, true);
            if tempProcessingPlan.FindLast() then;
            nextLineNo += tempProcessingPlan."Line No." + 10000;
        end else begin
            if processingPlan.FindLast() then;
            nextLineNo += processingPlan."Line No." + 10000;
        end;
    end;


    procedure findImportConfigHeader(var importConfigHeader: Record DMTImportConfigHeader) OK: Boolean
    begin
        Clear(importConfigHeader);
        if not (Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target", Rec.Type::"Enter default values in target table"]) then
            exit(false);
        OK := importConfigHeader.Get(Rec.ID);
    end;

    /// <summary>
    /// <p>uses the indentation of the parent group + 1</p>
    /// </summary>
    procedure setUseAutomaticIndentation(useAutomaticIndentationNEW: Boolean)
    begin
        UseAutomaticIndentation := useAutomaticIndentationNEW;
    end;

    procedure addGroupLine(DescriptionNew: Text[150]; indentationNew: Integer) processingPlan: Record DMTProcessingPlan;
    begin
        addLine(Enum::DMTProcessingPlanType::Group, 0, indentationNew, DescriptionNew);
    end;

    procedure addImportToBufferLine(importConfigHeaderID: Integer; descriptionNEW: Text[250])
    begin
        addLine(Enum::DMTProcessingPlanType::"Import To Buffer", importConfigHeaderID, Rec.getIndentation(), descriptionNEW);
    end;

    procedure addImportToTargetLine(importConfigHeaderID: Integer; descriptionNEW: Text[250])
    begin
        addLine(Enum::DMTProcessingPlanType::"Import To Target", importConfigHeaderID, Rec.getIndentation(), descriptionNEW);
    end;

    local procedure addLine(TypeNEW: Enum DMTProcessingPlanType; importConfigHeaderID: Integer;
                                         indentationNEW: Integer;
                                         descriptionNEW: Text[250])
    var
        processingPlan: Record DMTProcessingPlan;
    begin
        processingPlan.New();
        processingPlan.Type := TypeNEW;
        processingPlan.Validate(ID, importConfigHeaderID);
        if (indentationNEW = 0) and UseAutomaticIndentation then
            processingPlan.Indentation := Rec.getIndentation()
        else
            processingPlan.Indentation := indentationNEW;
        processingPlan.Description := descriptionNEW;
        processingPlan.Insert();
        Rec.Copy(processingPlan);
    end;

    local procedure hasValidSourceTable(ImportConfigHeaderID: Integer): Boolean
    var
        TableMetadata: Record "Table Metadata";
        importConfigHeader: Record DMTImportConfigHeader;
    begin
        if not importConfigHeader.Get(ImportConfigHeaderID) then
            exit(false);
        //* Generische Puffertabelle immer vorhanden -> Gültig
        if importConfigHeader.UseGenericBufferTable() then
            exit(true);
        //* Wenn seperate Puffertabelle verwendet wird, prüfen ob diese vorhanden ist
        if TableMetadata.Get(importConfigHeader."Buffer Table ID") then
            exit(true);
        exit(false);
    end;

    /// <summary>create a filter for the source table based on the filter for the target table</summary>
    /// <param name="filteredView">table view result</param>
    /// <param name="importConfigHeaderID">ID of the config. header containing the field mapping</param>
    /// <param name="filter">filter: Dictionary of [Text/*field name*/, Text/*filter expression|default value*/]</param>
    /// <returns>true - field filters found</returns>
    procedure createSourceTableFilterFromTargetFilter(var filteredView: Text; importConfigHeaderID: Integer; filter: Dictionary of [Text/*field name*/, Text/*filter expression|default value*/]) OK: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        fieldFilters: List of [Text];
        index: Integer;
    begin
        importConfigHeader.Get(importConfigHeaderID);
        importConfigHeader.TestField("Source File Name");

        for index := 1 to filter.Count do begin
            importConfigLine.SetRange("Source Field Caption", filter.Keys.Get(index));
            importConfigHeader.FilterRelated(importConfigLine);
            if importConfigLine.FindFirst() then begin
                fieldFilters.Add(StrSubstNo('Field%1=1(%2)', importConfigLine."Source Field No.", filter.Values.Get(index)));
            end;
        end;

        for index := 1 to fieldFilters.Count do begin
            filteredView += fieldFilters.Get(index);
            if index < fieldFilters.Count then
                filteredView += ',';
        end;
        filteredView := 'VERSION(1) SORTING(Field1) WHERE(' + filteredView + ')';
        OK := fieldFilters.Count > 0;
    end;


    procedure SaveSourceTableFilterCreatedFromTargetFilter(CreatedImportConfigHeaderID: Integer; filter: Dictionary of [Text/*field name*/, Text/*filter expression|default value*/])
    var
        filteredView: Text;
    begin
        createSourceTableFilterFromTargetFilter(filteredView, CreatedImportConfigHeaderID, filter);
        Rec.SaveSourceTableFilter(filteredView);
    end;


    var
        UseAutomaticIndentation: Boolean;
}