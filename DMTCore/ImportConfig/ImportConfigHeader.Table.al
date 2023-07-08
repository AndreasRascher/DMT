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
        #region Import and Processing Options
        field(50; LastUsedUpdateFieldsSelection; Blob) { }
        field(51; LastUsedFilter; Blob) { }
        field(52; "Use OnInsert Trigger"; Boolean) { Caption = 'Use OnInsert Trigger', Comment = 'de-DE=OnInsert Trigger verwenden'; InitValue = true; }
        field(53; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'de-DE=Nur neue Datensätze importieren'; }
        field(54; "Data Layout Code"; Code[50]) { Caption = 'Data Layout Code', Comment = 'de-DE=Datenlayout Code'; TableRelation = DMTDataLayout; }
        #endregion Import and Processing Options
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }
}