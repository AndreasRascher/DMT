table 91003 DMTImportConfigHeader
{
    Caption = 'DMT Import Configuration Header', Comment = 'de-DE=Import Konfiguration Kopf';
    fields
    {
        field(1; ID; Integer) { Caption = 'ID', Locked = true; }
        field(3; "Current App Package ID Filter"; Guid) { Caption = 'Current Package ID Filter', locked = true; FieldClass = FlowFilter; }
        field(4; "Other App Packages ID Filter"; Guid) { Caption = 'Other App Packages ID Filter', locked = true; FieldClass = FlowFilter; }
        field(10; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'de-DE=Zieltabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Other App Packages ID Filter"));
        }
        field(11; "Target Table Caption"; Text[250])
        {
            Caption = 'Target Table Caption', comment = 'de-DE=Zieltabelle Bezeichnung';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
            Editable = false;
        }
        field(20; "No.of Records in Buffer Table"; Integer) { Caption = 'No.of Records in Buffer Table', comment = 'de-DE=Anz. Datensätze in Puffertabelle'; Editable = false; }
        field(40; "Use Separate Buffer Table"; Boolean)
        {
            Caption = 'Use Separate Buffer Table', Comment = 'de-DE=Separate Puffertabelle verwenden';
            trigger OnValidate()
            begin
                if not "Use Separate Buffer Table" then begin
                    Clear(Rec."Import XMLPort ID");
                    Clear(Rec."Buffer Table ID");
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
        field(42; "Buffer Table ID"; Integer)
        {
            Caption = 'Buffertable ID', Comment = 'de-DE=Puffertabelle ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        #region Import and Processing Options
        field(50; LastUsedUpdateFieldsSelection; Blob) { }
        field(51; LastUsedFilter; Blob) { }
        field(52; "Use OnInsert Trigger"; Boolean) { Caption = 'Use OnInsert Trigger', Comment = 'de-DE=OnInsert Trigger verwenden'; InitValue = true; }
        field(53; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'de-DE=Nur neue Datensätze importieren'; }
        field(54; "Data Layout ID"; Integer) { Caption = 'Data Layout Code', Comment = 'de-DE=Datenlayout Code'; TableRelation = DMTDataLayout; }
        field(55; "Source File Name"; Text[250])
        {
            Caption = 'Source File Name', Comment = 'de-DE=Quelldatei';
            FieldClass = FlowField;
            CalcFormula = lookup(DMTSourceFileStorage.Name where("File ID" = field("Source File ID")));
            Editable = false;
        }
        #endregion Import and Processing Options
        field(100; "Source File ID"; Integer) { Caption = 'Source File ID', Comment = 'de-DE=Quell-Datei ID'; TableRelation = DMTSourceFileStorage; }
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }

    trigger OnInsert()
    begin
        Rec.testfield("Data Layout ID");
        Rec.TestField("Source File ID");
        Rec.ID := GetNextID();
    end;

    procedure GetNextID() NextID: Integer
    var
        DataLayout: Record DMTDataLayout;
    begin
        NextID := 1;
        if DataLayout.FindLast() then
            NextID += DataLayout.ID;
    end;

    internal procedure FilterRelated(var ImportConfigLine: Record DMTImportConfigLine) HasLinesInFilter: Boolean
    begin
        ImportConfigLine.SetRange("Imp.Conf.Header ID", Rec.ID);
        HasLinesInFilter := not ImportConfigLine.IsEmpty;
    end;

    internal procedure ShowTableContent(TableID: Integer) OK: Boolean
    var
        TableMeta: Record "Table Metadata";
    begin
        OK := TableMeta.Get(TableID);
        if OK then
            Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, TableID));
    end;

    internal procedure GetSourceFileName(): Text[250]
    var
        SourceFileStorage: Record DMTSourceFileStorage;
    begin
        SourceFileStorage.Get(Rec."Source File ID");
        SourceFileStorage.TestField(Name);
        exit(SourceFileStorage.Name);
    end;

    internal procedure ShowBufferTable()
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        if not genBuffTable.FilterBy(Rec) then
            exit;
        genBuffTable.ShowBufferTable(Rec);
    end;

    procedure UpdateBufferRecordCount()
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        GenBuffTable.Reset();
        GenBuffTable.FilterBy(Rec);
        GenBuffTable.SetRange(IsCaptionLine, false); // don't count header line
        Rec."No.of Records in Buffer Table" := GenBuffTable.Count;
        Rec.Modify();
    end;

    procedure GetNoOfRecordsInTrgtTable(): Integer
    var
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
    begin
        if not TableMetadata.get(Rec."Target Table ID") then exit(0);
        RecRef.Open(Rec."Target Table ID");
        exit(RecRef.Count);
    end;

    procedure InitBufferRef(var BufferRef: RecordRef)
    var
        GenBuffTable: Record DMTGenBuffTable;
        TableMetadata: Record "Table Metadata";
        BufferTableMissingErr: Label 'Buffer Table %1 not found', Comment = 'de-DE=Eine Puffertabelle mit der ID %1 wurde nicht gefunden.';
    begin
        if not Rec."Use Separate Buffer Table" then begin
            GenBuffTable.FilterGroup(2);
            GenBuffTable.SetRange(IsCaptionLine, false);
            GenBuffTable.FilterBy(Rec);
            GenBuffTable.FilterGroup(0);
            BufferRef.GetTable(GenBuffTable);
        end else begin
            if not TableMetadata.Get(Rec."Buffer Table ID") then
                Error(BufferTableMissingErr, Rec."Buffer Table ID");
            BufferRef.Open(Rec."Buffer Table ID");
        end;
    end;

    procedure LoadImportConfigLines(var TempImportConfigLine: Record DMTImportConfigLine temporary) OK: Boolean
    var
        ImportConfigLine: Record DMTImportConfigLine;
    begin
        Rec.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        if rec."Use Separate Buffer Table" then
            ImportConfigLine.SetFilter("Source Field No.", '<>0');
        ImportConfigLine.CopyToTemp(TempImportConfigLine);
        OK := TempImportConfigLine.FindFirst();
    end;

    procedure GetDataLayout() DataLayout: Record DMTDataLayout
    begin
        Rec.TestField(Rec."Data Layout ID");
        DataLayout.Get(Rec."Data Layout ID");
    end;

    procedure GetSourceFileStorage() SourceFileStorage: Record DMTSourceFileStorage
    begin
        Rec.TestField(Rec."Source File ID");
        SourceFileStorage.Get(Rec."Source File ID");
    end;

    procedure ReadLastFieldUpdateSelection() LastFieldUpdateSelectionAsText: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(LastUsedUpdateFieldsSelection);
        if not Rec.LastUsedUpdateFieldsSelection.HasValue then exit('');
        Rec.LastUsedUpdateFieldsSelection.CreateInStream(IStr);
        IStr.ReadText(LastFieldUpdateSelectionAsText);
    end;

    procedure WriteLastFieldUpdateSelection(LastFieldUpdateSelectionAsText: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastUsedUpdateFieldsSelection);
        Rec.Modify();
        Rec.LastUsedUpdateFieldsSelection.CreateOutStream(OStr);
        OStr.WriteText(LastFieldUpdateSelectionAsText);
        Rec.Modify();
    end;

    procedure ReadLastUsedSourceTableView() TableView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(LastUsedFilter);
        if not Rec.LastUsedFilter.HasValue then exit('');
        Rec.LastUsedFilter.CreateInStream(IStr);
        IStr.ReadText(TableView);
    end;

    procedure WriteSourceTableView(TableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastUsedFilter);
        Rec.Modify();
        Rec.LastUsedFilter.CreateOutStream(OStr);
        OStr.WriteText(TableView);
        Rec.Modify();
    end;



}