table 91004 DMTSourceFileStorage
{
    LookupPageId = DMTSourceFiles;
    Caption = 'DMT Source File', Comment = 'de-DE=DMT Quelldatei';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File ID"; Integer) { }
        field(10; "File Blob"; Blob) { }
        field(20; SourceFileFormat; Enum DMTSourceFileFormat) { Caption = 'Source File Format', Comment = 'de-DE=Dateiformat'; }
        field(21; "Data Layout ID"; Integer)
        {
            Caption = 'Data Layout ID', Comment = 'de-DE=Datenlayout ID';
            TableRelation = DMTDataLayout where(SourceFileFormat = field(SourceFileFormat));
            trigger OnValidate()
            var
                dataLayout: Record DMTDataLayout;
            begin
                dataLayout.Get("Data Layout ID");
                Rec."Data Layout Name" := dataLayout.Name;
            end;
        }
        field(22; "Data Layout Name"; Text[250])
        {
            Caption = 'Data Layout Name', Comment = 'de-DE=Datenlayout Name';
            TableRelation = DMTDataLayout.Name where(SourceFileFormat = field(SourceFileFormat));
            ValidateTableRelation = false;
        }
        field(100; Name; Text[99]) { Caption = 'Name', Comment = 'de-DE=Name'; Editable = false; }
        field(101; Extension; Text[10]) { Caption = 'Extension', Comment = 'de-DE=Dateiendung'; Editable = false; }
        field(102; Size; Integer)
        {
            Caption = 'Size(Byte)', Comment = 'de-DE=Größe(Byte)';
            Editable = false;
            trigger OnValidate()
            begin
                SizeInKB := Rec.Size / 1024;
            end;
        }
        field(103; SizeInKB; Decimal)
        {
            Caption = 'Size', Comment = 'de-DE=Größe';
            Editable = false;
            AutoFormatType = 10;
            AutoFormatExpression = '<precision, 1:1><standard format,0>KB';
        }
        field(104; UploadDateTime; DateTime) { Caption = 'Uploaded at', Comment = 'de-DE=Hochgeladen am'; Editable = false; }
    }
    keys
    {
        key(PK; "File ID") { Clustered = true; }
        key(SortByName; Name) { }
    }
    fieldgroups
    {
        fieldgroup(Brick; "Data Layout Name", Name, Size, Extension) { }
    }

    procedure GetFileAsTempBlob(var tempBlob: Codeunit "Temp Blob")
    begin
        Clear(tempBlob);
        tempBlob.FromRecord(Rec, Rec.FieldNo("File Blob"));
    end;

    internal procedure DataLayoutName_OnAfterLookup(Selected: RecordRef)
    var
        dataLayout: Record DMTDataLayout;
    begin
        Selected.SetTable(dataLayout);
        Rec."Data Layout ID" := dataLayout.ID;
        Rec."Data Layout Name" := dataLayout.Name;
    end;

    internal procedure DataLayoutName_OnValidate()
    var
        dataLayout: Record DMTDataLayout;
        TypeHelper: Codeunit "Type Helper";
        dataLayoutID: Integer;
        SearchToken: Text;
    begin
        // exit if assigned from dropdown
        if (Rec."Data Layout ID" <> 0) then
            if dataLayout.Get(Rec."Data Layout ID") and (dataLayout.Name = Rec."Data Layout Name") then
                exit;
        case true of
            // Case 1 - Empty
            (Rec."Data Layout Name" = ''):
                begin
                    Rec."Data Layout ID" := 0;
                    Rec."Data Layout Name" := '';
                end;
            // Case 2 - Layout No.
            (Rec."Data Layout Name" <> '') and TypeHelper.IsNumeric(Rec."Data Layout Name"):
                begin
                    Evaluate(dataLayoutID, Rec."Data Layout Name");
                    dataLayout.Get(dataLayoutID);
                    Rec."Data Layout ID" := dataLayout.ID;
                    Rec."Data Layout Name" := dataLayout.Name;
                end;
            // Case 3 - Search Term
            (Rec."Data Layout Name" <> '') and not TypeHelper.IsNumeric(Rec."Data Layout Name"):
                begin
                    // 1. search by name, case insensitive
                    SearchToken := Rec."Data Layout Name";
                    if not SearchToken.StartsWith('@') then
                        SearchToken := '@' + SearchToken;
                    dataLayout.SetFilter(Name, SearchToken);
                    if not dataLayout.FindFirst() then begin
                        // 2. search as part, case insensitive
                        if not SearchToken.EndsWith('*') then
                            SearchToken := SearchToken + '*';
                        dataLayout.SetFilter(Name, SearchToken);
                        dataLayout.FindFirst();
                    end;
                    Rec."Data Layout ID" := dataLayout.ID;
                    Rec."Data Layout Name" := dataLayout.Name;
                end;
        end;
    end;

    local procedure ConfirmDeleteIfSourceFileIsAssigned(Rec: Record DMTSourceFileStorage)
    var
        DMTImportConfigHeader: Record DMTImportConfigHeader;
        DeleteSourceFileQst: Label 'The source file %1 "%2" is currently assigned in import configurations. Continue?', Comment = 'de-DE=Die Quelldatei %1 "%2" ist Importkonfigurationen zugewiesen. Mit dem Löschen fortfahren?';
        ProcessCanceledErr: Label 'Process Canceled', Comment = 'de-DE=Vorgang abgebrochen';
    begin
        DMTImportConfigHeader.SetRange("Source File ID", rec."File ID");
        if not DMTImportConfigHeader.IsEmpty then
            if not Confirm(StrSubstNo(DeleteSourceFileQst, Rec."File ID", Rec.Name)) then begin
                Error(ProcessCanceledErr);
            end else begin
                // remove references
                DMTImportConfigHeader.Reset();
                DMTImportConfigHeader.SetRange("Source File ID", rec."File ID");
                DMTImportConfigHeader.ModifyAll("Source File ID", 0, false);
            end;
    end;

    trigger OnDelete()
    begin
        ConfirmDeleteIfSourceFileIsAssigned(Rec);
    end;
}