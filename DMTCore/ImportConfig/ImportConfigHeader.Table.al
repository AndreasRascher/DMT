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
        #endregion Import and Processing Options
        field(100; SourceFileID; Integer) { Caption = 'Source File ID', Comment = 'de-DE=Quell-Datei ID'; TableRelation = DMTSourceFileStorage; }
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }

    trigger OnInsert()
    begin
        Rec.testfield("Data Layout ID");
        Rec.TestField(SourceFileID);
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

    internal procedure FilterRelated(var ImportConfigLine: Record DMTImportConfigLine)
    begin
        ImportConfigLine.SetRange("Imp.Conf.Header ID", Rec.ID);
    end;
}