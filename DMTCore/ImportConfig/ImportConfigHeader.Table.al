table 91003 DMTImportConfigHeader
{
    Caption = 'DMT Import Configuration Header', Comment = 'de-DE=Import Konfiguration Kopf';
    LookupPageId = DMTImportConfigList;
    DrillDownPageId = DMTImportConfigList;
    fields
    {
        field(1; ID; Integer) { Caption = 'ID', Locked = true; }
        field(3; "Current App Package ID Filter"; Guid) { Caption = 'Current Package ID Filter', Locked = true; FieldClass = FlowFilter; }
        field(4; "Other App Packages ID Filter"; Guid) { Caption = 'Other App Packages ID Filter', Locked = true; FieldClass = FlowFilter; }
        field(10; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', Comment = 'de-DE=Zieltabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Other App Packages ID Filter"));
            trigger OnValidate()
            var
                TableMetadata: Record "Table Metadata";
                migrationLib: Codeunit DMTMigrationLib;
            begin
                if TableMetadata.Get(Rec."Target Table ID") then
                    Rec."Target Table Caption" := TableMetadata.Caption;
                migrationLib.ApplyKnownProcessingRulesToNewImportConfigHeaderRec(Rec);
            end;
        }
        field(11; "Target Table Caption"; Text[250])
        {
            Caption = 'Target Table', Comment = 'de-DE=Zieltabelle';
            TableRelation = AllObjWithCaption."Object Caption" where("Object Type" = const(Table));
            ValidateTableRelation = false;
        }
        field(20; "No.of Records in Buffer Table"; Integer) { Caption = 'No.of Records in Buffer Table', Comment = 'de-DE=Anz. Datensätze in Puffertabelle'; Editable = false; }
        field(40; "Separate Buffer Table Objects"; Option)
        {
            Caption = 'Separate Buffer Table Objects', Comment = 'de-DE=Separate Puffertabelle verwenden';
            OptionMembers = None,"buffer table and XMLPort (Best performance)","Use existing buffer table & generate XMLPort only";
            OptionCaption = 'None,buffer table and XMLPort (Best performance),Use existing buffer table & generate XMLPort only',
            Comment = 'de-DE=Keine,Puffertabelle und XMLPort (Beste Performance),Existierende Puffertabelle verwenden & nur XMLPort generieren';
            trigger OnValidate()
            begin
                case Rec."Separate Buffer Table Objects" of
                    Rec."Separate Buffer Table Objects"::None:
                        begin
                            Clear(Rec."Import XMLPort ID");
                            Clear(Rec."Buffer Table ID");
                        end;
                    Rec."Separate Buffer Table Objects"::"Use existing buffer table & generate XMLPort only":
                        begin

                        end;
                    Rec."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)":
                        begin

                        end;
                end;
            end;
        }
        field(41; "Import XMLPort ID"; Integer)
        {
            Caption = 'Import XMLPortID', Comment = 'de-DE=XMLPort ID für Import';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLport), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(42; ImportXMLPortIDStyle; Text[15]) { Caption = 'ImportXMLPortIDStyle', Locked = true; Editable = false; }

        field(43; "Buffer Table ID"; Integer)
        {
            Caption = 'Buffertable ID', Comment = 'de-DE=Puffertabelle ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(44; BufferTableIDStyle; Text[15]) { Caption = 'BufferTableIDStyle', Locked = true; Editable = false; }
        #region Import and Processing Options
        field(50; LastUsedUpdateFieldsSelection; Blob) { Caption = 'LastUsedUpdateFieldsSelection', Locked = true; }
        field(51; LastUsedFilter; Blob) { Caption = 'LastUsedFilter', Locked = true; }
        field(52; "Use OnInsert Trigger"; Boolean) { Caption = 'Use OnInsert Trigger', Comment = 'de-DE=OnInsert Trigger verwenden'; InitValue = true; }
        field(53; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'de-DE=Nur neue Datensätze importieren'; }
        field(54; "Skip Records with User Changes"; Boolean) { Caption = 'Skip Records with User Changes', Comment = 'de-DE=Datensätze mit Nutzeränderung überspringen'; }
        field(55; "Log Trigger Changes"; Boolean) { Caption = 'Log Trigger Changes', Comment = 'de-DE=Trigger Änderungen protokollieren'; }
        field(56; "Ev. Nos. for Option fields as"; Option)
        {
            Caption = 'Evaluate numbers for option fields as', Comment = 'de-DE=Max. Anzahl zu verarbeiternder Datensatz :';
            OptionMembers = Position,Caption;
            OptionCaption = 'Position,Caption', Comment = 'de-DE=Position,Bezeichnung';
        }
        field(57; "Max No. of Records to Process"; Integer)
        {
            Caption = 'Max No. of Records to Process', Comment = 'de-DE=max. Anzahl der zu verarbeitenden Datensätze';
            BlankZero = true;
            MinValue = 0;
        }
        field(100; "Source File ID"; Integer) { Caption = 'Source File ID', Comment = 'de-DE=Quell-Datei ID'; TableRelation = DMTSourceFileStorage; }
        field(101; "Source File Name"; Text[250])
        {
            Caption = 'Source File Name', Comment = 'de-DE=Quelldatei';
            TableRelation = DMTSourceFileStorage.Name;
            ValidateTableRelation = false;
        }
        #endregion Import and Processing Options
        #region Processing Info
        field(110; ImportToTargetPercentage; Decimal) { Caption = 'Migrated %', Comment = 'de-DE=Migriert %'; Editable = false; AutoFormatExpression = '<precision, 1:1><standard format,0>%'; }
        field(111; ImportToTargetPercentageStyle; Text[15]) { Caption = 'ImportToTargetPercentageStyle', Locked = true; }
        #endregion Processing Info
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; ID, "Target Table Caption", "Target Table ID") { }
    }
    trigger OnInsert()
    begin
        // Rec.TestField("Source File ID");
        Rec.ID := GetNextID();
    end;

    trigger OnDelete()
    var
        ImportConfigLine: Record DMTImportConfigLine;
        LogEntry: Record DMTLogEntry;
    begin
        if Rec.FilterRelated(ImportConfigLine) then
            ImportConfigLine.DeleteAll(true);
        if Rec.FilterRelated(LogEntry) then
            LogEntry.DeleteAll();
        Rec.BufferTableMgt().DeleteAllBufferData();
    end;

    internal procedure GetNextID() NextID: Integer
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
    begin
        NextID := 1;
        if ImportConfigHeader.FindLast() then
            NextID += ImportConfigHeader.ID;
    end;

    internal procedure FilterRelated(var ImportConfigLine: Record DMTImportConfigLine) HasLinesInFilter: Boolean
    begin
        ImportConfigLine.SetRange("Imp.Conf.Header ID", Rec.ID);
        HasLinesInFilter := not ImportConfigLine.IsEmpty;
    end;

    internal procedure FilterRelated(var LogEntry: Record DMTLogEntry) HasLinesInFilter: Boolean
    begin
        LogEntry.SetRange("Owner RecordID", Rec.RecordId);
        LogEntry.SetRange("Entry Type", LogEntry."Entry Type"::Summary);
    end;

    internal procedure UpdateBufferRecordCount()
    begin
        Rec."No.of Records in Buffer Table" := Rec.BufferTableMgt().CountRecordsInBufferTable();
        Rec.Modify();
    end;

    internal procedure GetSourceFileName(): Text[250]
    var
        SourceFileStorage: Record DMTSourceFileStorage;
    begin
        SourceFileStorage.Get(Rec."Source File ID");
        SourceFileStorage.TestField(Name);
        exit(SourceFileStorage.Name);
    end;

    internal procedure SourceFileName_OnAfterLookup(Selected: RecordRef)
    var
        sourceFileStorage: Record DMTSourceFileStorage;
    begin
        Selected.SetTable(sourceFileStorage);
        Rec."Source File ID" := sourceFileStorage."File ID";
        Rec."Source File Name" := sourceFileStorage.Name;
    end;

    internal procedure SourceFileName_OnValidate()
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        TypeHelper: Codeunit "Type Helper";
        sourceFileID: Integer;
        SearchToken: Text;
        ContinueSearch: Boolean;
    begin
        // exit if assigned from dropdown
        if (Rec."Source File ID" <> 0) then
            if sourceFileStorage.Get(Rec."Source File ID") and (sourceFileStorage.Name = Rec."Source File Name") then
                exit;
        case true of
            // Case 1 - Empty
            (Rec."Source File Name" = ''):
                begin
                    Rec."Source File ID" := 0;
                    Rec."Source File Name" := '';
                end;
            // Case 2 - Table No.
            (Rec."Source File Name" <> '') and TypeHelper.IsNumeric(Rec."Source File Name"):
                begin
                    Evaluate(sourceFileID, Rec."Source File Name");
                    sourceFileStorage.Get(sourceFileID);
                    Rec."Source File ID" := sourceFileStorage."File ID";
                    Rec."Source File Name" := sourceFileStorage.Name;
                end;
            // Case 3 - Search Term
            (Rec."Source File Name" <> '') and not TypeHelper.IsNumeric(Rec."Source File Name"):
                begin
                    SearchToken := Rec."Source File Name";
                    // Search 1: exact match, not case sensitive   
                    SearchToken := ConvertStr(SearchToken, '()<>€', '?????');
                    if not SearchToken.StartsWith('@') then
                        SearchToken := '@' + SearchToken;
                    sourceFileStorage.SetFilter(Name, SearchToken);
                    ContinueSearch := not sourceFileStorage.FindFirst();
                    // Search 2: part of, not case sensitive   
                    if ContinueSearch then begin
                        if not SearchToken.EndsWith('*') then
                            SearchToken := SearchToken + '*';
                        sourceFileStorage.SetFilter(Name, SearchToken);
                        sourceFileStorage.FindFirst();
                    end;
                    Rec."Source File ID" := sourceFileStorage."File ID";
                    Rec."Source File Name" := sourceFileStorage.Name;
                end;
        end;
    end;

    internal procedure ShowTableContent(tableID: Integer) OK: Boolean
    var
        TableMeta: Record "Table Metadata";
    begin
        OK := TableMeta.Get(tableID);
        if OK then
            Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, tableID));
    end;

    internal procedure GetNoOfRecordsInTrgtTable(): Integer
    var
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
    begin
        if not TableMetadata.Get(Rec."Target Table ID") then exit(0);
        RecRef.Open(Rec."Target Table ID");
        exit(RecRef.Count);
    end;

    internal procedure GetDataLayout() dataLayout: Record DMTDataLayout
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        SourceFileMgt: Codeunit DMTSourceFileMgt;
        noSourceFileAssignedErr: Label 'The import configuration %1 has no source file assigned.', Comment = 'de-DE=Die Importkonfiguration %1 hat keine Quelldatei zugeordnet.';
    begin
        // throw error if no source file is assigned
        if rec."Source File ID" = 0 then
            Error(noSourceFileAssignedErr, Rec.ID);
        Rec.TestField("Source File ID");
        sourceFileStorage.Get(rec."Source File ID");
        SourceFileMgt.AssignDefaultDataLayout(sourceFileStorage);  // if setup has been set after importing source files
        sourceFileStorage.Modify();
        ThrowActionableErrorIfDataLayoutIsNotSet();
        sourceFileStorage.get(sourceFileStorage.RecordId);
        dataLayout.Get(sourceFileStorage."Data Layout ID");
    end;

    internal procedure GetSourceFileStorage() SourceFileStorage: Record DMTSourceFileStorage
    begin
        Rec.TestField(Rec."Source File ID");
        SourceFileStorage.Get(Rec."Source File ID");
    end;

    internal procedure ReadLastFieldUpdateSelection() LastFieldUpdateSelectionAsText: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(LastUsedUpdateFieldsSelection);
        if not Rec.LastUsedUpdateFieldsSelection.HasValue then exit('');
        Rec.LastUsedUpdateFieldsSelection.CreateInStream(IStr);
        IStr.ReadText(LastFieldUpdateSelectionAsText);
    end;

    internal procedure WriteLastFieldUpdateSelection(LastFieldUpdateSelectionAsText: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastUsedUpdateFieldsSelection);
        Rec.Modify();
        Rec.LastUsedUpdateFieldsSelection.CreateOutStream(OStr);
        OStr.WriteText(LastFieldUpdateSelectionAsText);
        Rec.Modify();
    end;

    internal procedure ReadLastUsedSourceTableView() TableView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(LastUsedFilter);
        if not Rec.LastUsedFilter.HasValue then exit('');
        Rec.LastUsedFilter.CreateInStream(IStr);
        IStr.ReadText(TableView);
    end;

    internal procedure WriteSourceTableView(TableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastUsedFilter);
        Rec.Modify();
        Rec.LastUsedFilter.CreateOutStream(OStr);
        OStr.WriteText(TableView);
        Rec.Modify();
    end;

    internal procedure TargetTableCaption_OnAfterLookup(var Selected: RecordRef)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        Selected.SetTable(AllObjWithCaption);
        Rec."Target Table Caption" := AllObjWithCaption."Object Caption";
        Rec."Target Table ID" := AllObjWithCaption."Object ID";
    end;

    internal procedure TargetTableCaption_OnValidate()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TypeHelper: Codeunit "Type Helper";
        ObjectID: Integer;
        SearchToken: Text;
        ContinueSearch: Boolean;
    begin
        // exit if assigned from dropdown
        if (Rec."Target Table ID" <> 0) then
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Target Table ID") then
                if (AllObjWithCaption."Object Caption" = Rec."Target Table Caption") then
                    exit;
        case true of
            // Case 1 - Empty
            (Rec."Target Table Caption" = ''):
                begin
                    Rec."Target Table ID" := 0;
                    Rec."Target Table Caption" := '';
                end;
            // Case 2 - Table No.
            (Rec."Target Table Caption" <> '') and TypeHelper.IsNumeric(Rec."Target Table Caption"):
                begin
                    Evaluate(ObjectID, Rec."Target Table Caption");
                    AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, ObjectID);
                    Rec."Target Table ID" := AllObjWithCaption."Object ID";
                    Rec."Target Table Caption" := AllObjWithCaption."Object Caption";
                end;
            // Case 3 - Search Term
            (Rec."Target Table Caption" <> '') and not TypeHelper.IsNumeric(Rec."Target Table Caption"):
                begin
                    SearchToken := Rec."Target Table Caption";
                    // Search 1: exact match, not case sensitive   
                    SearchToken := ConvertStr(SearchToken, '()<>€', '?????');
                    if not SearchToken.StartsWith('@') then
                        SearchToken := '@' + SearchToken;
                    AllObjWithCaption.SetFilter("Object Caption", SearchToken);
                    ContinueSearch := not AllObjWithCaption.FindFirst();
                    // Search 2: part of, not case sensitive   
                    if ContinueSearch then begin
                        if not SearchToken.EndsWith('*') then
                            SearchToken := SearchToken + '*';
                        AllObjWithCaption.SetFilter("Object Caption", SearchToken);
                        AllObjWithCaption.FindFirst();
                    end;
                    Rec."Target Table ID" := AllObjWithCaption."Object ID";
                    Rec."Target Table Caption" := AllObjWithCaption."Object Caption";
                end;
        end;
    end;

    internal procedure filterBy(var sourceFileStorage: Record DMTSourceFileStorage) HasLines: Boolean
    begin
        rec.SetRange("Source File ID", sourceFileStorage."File ID");
        HasLines := not Rec.IsEmpty;
    end;

    internal procedure BufferTableMgt() IBufferTableMgt: Interface IBufferTableMgt
    var
        genericBuffertTableMgtImpl: Codeunit DMTGenericBuffertTableMgtImpl;
        separateBufferTableMgtImpl: Codeunit DMTSeparateBufferTableMgtImpl;
    begin
        if Rec.UseGenericBufferTable() then
            IBufferTableMgt := genericBuffertTableMgtImpl
        else
            IBufferTableMgt := separateBufferTableMgtImpl;
        IBufferTableMgt.setImportConfigHeader(Rec);
    end;

    local procedure ThrowActionableErrorIfDataLayoutIsNotSet()
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        DataLayoutMissingErrInfo: ErrorInfo;
        AssignDataLayoutButtonCaptionLbl: Label 'Assign data layout', Comment = 'de-DE=Datenlayout zuweisen';
        SourceFileHasNoDataLayoutErr: Label 'You have to assign a datalayout to the %1 "%2"',
                                  Comment = 'de-DE=Sie müssen der %1 "%2" ein Datenlayout zuordnen';
    begin
        sourceFileStorage.Get(Rec."Source File ID");
        if sourceFileStorage."Data Layout ID" <> 0 then
            exit;
        DataLayoutMissingErrInfo.AddAction(AssignDataLayoutButtonCaptionLbl, Codeunit::DMTSourceFileMgt, 'ShowSourceFileStorageWithErrorInfo');//Method must be global and have an errorinfo parameter
        DataLayoutMissingErrInfo.Message := StrSubstNo(SourceFileHasNoDataLayoutErr, sourceFileStorage.TableCaption, sourceFileStorage.Name);// no error shown if missing
        DataLayoutMissingErrInfo.RecordId := sourceFileStorage.RecordId;
        Error(DataLayoutMissingErrInfo);
    end;

    procedure CopyToTemp(var TempImportConfigHeader: Record DMTImportConfigHeader temporary) LineCount: Integer
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        TempImportConfigHeader2: Record DMTImportConfigHeader temporary;
    begin
        ImportConfigHeader.Copy(Rec);
        if ImportConfigHeader.FindSet(false) then
            repeat
                LineCount += 1;
                TempImportConfigHeader2 := ImportConfigHeader;
                TempImportConfigHeader2.Insert(false);
            until ImportConfigHeader.Next() = 0;
        TempImportConfigHeader.Copy(TempImportConfigHeader2, true);
    end;

    procedure ImportFileToBuffer()
    var
        Log: Codeunit DMTLog;
        Start: DateTime;
        SourceFileImport: Interface ISourceFileImport;
    begin
        Start := CurrentDateTime;
        SourceFileImport := Rec.GetDataLayout().SourceFileFormat;
        SourceFileImport.ImportToBufferTable(Rec);
        Log.AddImportToBufferSummary(Rec, CurrentDateTime - Start);
    end;

    procedure UpdateIndicators()
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        Clear(Rec.BufferTableIDStyle);
        if not UseGenericBufferTable() then begin
            Rec.BufferTableIDStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            if (Rec."Buffer Table ID" <> 0) then
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Buffer Table ID") then
                    Rec.BufferTableIDStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;

        Clear(Rec.ImportXMLPortIDStyle);
        if Rec.UseSeparateXMLPort() then begin
            Rec.ImportXMLPortIDStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            if (Rec."Import XMLPort ID" <> 0) then
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::XMLport, Rec."Import XMLPort ID") then
                    Rec.ImportXMLPortIDStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;
    end;

    procedure UseGenericBufferTable(): Boolean
    begin
        exit(Rec."Separate Buffer Table Objects" = Rec."Separate Buffer Table Objects"::None);
    end;

    procedure UseSeparateXMLPort(): Boolean
    begin
        exit(Rec."Separate Buffer Table Objects" in [Rec."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)",
                                                     Rec."Separate Buffer Table Objects"::"Use existing buffer table & generate XMLPort only"]);
    end;
}