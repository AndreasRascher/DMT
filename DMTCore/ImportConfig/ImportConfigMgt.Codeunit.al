codeunit 91002 DMTImportConfigMgt
{
    procedure ImportNAVSchemaFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FieldImport: XmlPort "DMT NAVFieldBufferImport";
        InStr: InStream;
        ImportFinishedMsg: Label 'Import finished', comment = 'de-DE=Import abgeschlossen';
        FileName: Text;
    begin
        TempBlob.CreateInStream(InStr);
        if not UploadIntoStream('Select a Schema.csv file', '', Format(Enum::DMTFileFilter::CSV), FileName, InStr) then begin
            exit;
        end;
        FieldImport.SetSource(InStr);
        FieldImport.Import();

        migrateNAVSchemaToDataLayout();

        Message(ImportFinishedMsg);
    end;

    local procedure migrateNAVSchemaToDataLayout()
    var
        dataLayout: Record DMTDataLayout;
        dataLayoutLine: Record DMTDataLayoutLine;
        NAVFieldBuffer: Record "DMT NAVFieldBuffer";
        TableIDs: List of [Integer];
        TableID: Integer;
    begin
        if NAVFieldBuffer.IsEmpty then exit;
        while NAVFieldBuffer.Findfirst() do begin
            TableIDs.Add(NAVFieldBuffer.TableNo);
            NAVFieldBuffer.SetFilter(TableNo, StrSubstNo('>%1', NAVFieldBuffer.TableNo));
        end;
        foreach TableID in TableIDs do begin
            // delete old
            dataLayout.Reset();
            dataLayout.SetRange(NAVTableID, TableID);
            if dataLayout.FindFirst() then
                dataLayout.DeleteAll(true);
            // load fields
            NAVFieldBuffer.Reset();
            NAVFieldBuffer.FindSet(false);
            NAVFieldBuffer.SetRange(TableNo, TableID);
            NAVFieldBuffer.FindSet();
            // add header
            Clear(dataLayout);
            dataLayout.Name := NAVFieldBuffer.TableName;
            dataLayout.SourceFileFormat := dataLayout.SourceFileFormat::"NAV CSV Export";
            dataLayout.NAVTableID := NAVFieldBuffer.TableNo;
            dataLayout.NAVNoOfRecords := NAVFieldBuffer."No. of Records";
            dataLayout.NAVPrimaryKey := NAVFieldBuffer."Primary Key";
            dataLayout.NAVTableCaption := NAVFieldBuffer."Table Caption";
            dataLayout.Insert(true);
            repeat
                Clear(dataLayoutLine);

                dataLayoutLine."Data Layout ID" := dataLayout.ID;
                dataLayoutLine."Column No." := NAVFieldBuffer."No.";
                dataLayoutLine.ColumnName := NAVFieldBuffer.FieldName;
                dataLayoutLine.NAVFieldCaption := NAVFieldBuffer."Field Caption";
                dataLayoutLine."NAV Primary Key" := NAVFieldBuffer."Primary Key";
                dataLayoutLine."NAV Table Caption" := NAVFieldBuffer."Table Caption";
                dataLayoutLine.NAVClass := NAVFieldBuffer.Class;
                dataLayoutLine.NAVDataType := NAVFieldBuffer.Type;
                dataLayoutLine.NAVEnabled := NAVFieldBuffer.Enabled;
                dataLayoutLine.NAVLen := NAVFieldBuffer.Len;

                dataLayoutLine.Insert(true);
            until NAVFieldBuffer.Next() = 0;
        end;
    end;

    internal procedure PageAction_InitImportConfigLine(ImportConfigHeaderID: Integer): Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        ImportConfigLine, ImportConfigLine_NEW : Record DMTImportConfigLine;
        TargetRecRef: RecordRef;
        i: Integer;
        KeyFieldIDsList: List of [Integer];
    begin
        ImportConfigHeader.Get(ImportConfigHeaderID);
        ImportConfigHeader.TestField("Target Table ID");
        if ImportConfigHeader."Target Table ID" = 0 then
            exit(false);
        TargetRecRef.Open(ImportConfigHeader."Target Table ID");
        KeyFieldIDsList := GetListOfKeyFieldIDs(TargetRecRef);
        for i := 1 to TargetRecRef.FieldCount do begin
            if TargetRecRef.FieldIndex(i).Active then
                if (TargetRecRef.FieldIndex(i).Class = TargetRecRef.FieldIndex(i).Class::Normal) then begin
                    ImportConfigHeader.FilterRelated(ImportConfigLine);
                    ImportConfigLine.SetRange("Target Field No.", TargetRecRef.FieldIndex(i).Number);
                    if ImportConfigLine.IsEmpty then begin
                        ImportConfigLine_NEW."Imp.Conf.Header ID" := ImportConfigHeaderID;
                        ImportConfigLine_NEW."Target Field No." := TargetRecRef.FieldIndex(i).Number;
                        ImportConfigLine_NEW."Target Table ID" := ImportConfigHeader."Target Table ID";
                        ImportConfigLine_NEW."Processing Action" := ImportConfigLine_NEW."Processing Action"::Ignore; //default for fields without action
                        ImportConfigLine_NEW."Validation Order" := i * 10000;
                        ImportConfigLine_NEW."Is Key Field(Target)" := KeyFieldIDsList.Contains(ImportConfigLine_NEW."Target Field No.");
                        ImportConfigLine_NEW.Insert(true);
                    end;
                end;
        end;
    end;

    internal procedure PageAction_ImportConfigLine_SetValidateField(var TempImportConfigLine_Selected: Record DMTImportConfigLine temporary; NewValue: Enum DMTFieldValidationType)
    var
        ImportConfigLine: Record DMTImportConfigLine;
        NoOfRecords: Integer;
    begin
        NoOfRecords := TempImportConfigLine_Selected.Count;
        if not TempImportConfigLine_Selected.FindFirst() then exit;
        TempImportConfigLine_Selected.FindSet();
        repeat
            ImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
            if ImportConfigLine."Validation Type" <> NewValue then begin
                ImportConfigLine."Validation Type" := NewValue;
                ImportConfigLine.Modify()
            end;
        until TempImportConfigLine_Selected.Next() = 0;
    end;

    internal procedure PageAction_MoveSelectedLines(var TempImportConfigLine_Selected: Record DMTImportConfigLine temporary; Direction: Option Up,Down,Top,Bottom)
    var
        ImportConfigLine: Record DMTImportConfigLine;
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        i: Integer;
        RefPos: Integer;
    begin
        ImportConfigLine.SetRange("Target Table ID", TempImportConfigLine_Selected."Target Table ID");
        ImportConfigLine.SetCurrentKey("Validation Order");
        ImportConfigLine.CopyToTemp(TempImportConfigLine);

        TempImportConfigLine.SetCurrentKey("Validation Order");
        case Direction of
            Direction::Bottom:
                begin
                    TempImportConfigLine.FindLast();
                    RefPos := TempImportConfigLine."Validation Order";
                    TempImportConfigLine_Selected.FindSet();
                    repeat
                        i += 1;
                        TempImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
                        TempImportConfigLine."Validation Order" := RefPos + i * 10000;
                        TempImportConfigLine.Modify();
                    until TempImportConfigLine_Selected.Next() = 0;
                end;
            Direction::Top:
                begin
                    TempImportConfigLine.FindFirst();
                    RefPos := TempImportConfigLine."Validation Order";
                    TempImportConfigLine_Selected.Find('+');
                    repeat
                        i += 1;
                        TempImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
                        TempImportConfigLine."Validation Order" := RefPos - i * 10000;
                        TempImportConfigLine.Modify();
                    until TempImportConfigLine_Selected.Next(-1) = 0;
                end;
            Direction::Up:
                begin
                    TempImportConfigLine_Selected.FindSet();
                    repeat
                        TempImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
                        RefPos := TempImportConfigLine."Validation Order";
                        if TempImportConfigLine.Next(-1) <> 0 then begin
                            i := TempImportConfigLine."Validation Order";
                            TempImportConfigLine."Validation Order" := RefPos;
                            TempImportConfigLine.Modify();
                            TempImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
                            TempImportConfigLine."Validation Order" := i;
                            TempImportConfigLine.Modify();
                        end;
                    until TempImportConfigLine_Selected.Next() = 0;
                end;
            Direction::Down:
                begin
                    TempImportConfigLine_Selected.SetCurrentKey("Validation Order");
                    TempImportConfigLine_Selected.Ascending(false);
                    TempImportConfigLine_Selected.FindSet();
                    repeat
                        TempImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
                        RefPos := TempImportConfigLine."Validation Order";
                        if TempImportConfigLine.Next(1) <> 0 then begin
                            i := TempImportConfigLine."Validation Order";
                            TempImportConfigLine."Validation Order" := RefPos;
                            TempImportConfigLine.Modify();
                            TempImportConfigLine.Get(TempImportConfigLine_Selected.RecordId);
                            TempImportConfigLine."Validation Order" := i;
                            TempImportConfigLine.Modify();
                        end;
                    until TempImportConfigLine_Selected.Next() = 0;
                end;
        end;
        TempImportConfigLine.Reset();
        TempImportConfigLine.SetCurrentKey("Validation Order");
        TempImportConfigLine.FindSet();
        Clear(i);
        repeat
            i += 1;
            ImportConfigLine.Get(TempImportConfigLine.RecordId);
            ImportConfigLine."Validation Order" := i * 10000;
            ImportConfigLine.Modify(false);
        until TempImportConfigLine.Next() = 0;
    end;

    procedure PageAction_ProposeMatchingFields("Imp.Conf.Header ID": Integer)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
    begin
        ImportConfigHeader.Get("Imp.Conf.Header ID");
        AssignSourceToTargetFields(ImportConfigHeader);
        ProposeValidationRules(ImportConfigHeader);
    end;

    procedure PageAction_UpdateFields(var ImportConfigHeader: Record DMTImportConfigHeader)
    var
        Migrate: Codeunit DMTMigrate;
        SelectMultipleFields: Page DMTSelectMultipleFields;
        RunModalAction: Action;
    begin
        // Show only Non-Key Fields for selection
        SelectMultipleFields.Editable := true;
        if not SelectMultipleFields.InitSelectTargetFields(ImportConfigHeader, ImportConfigHeader.ReadLastFieldUpdateSelection()) then
            exit;
        RunModalAction := SelectMultipleFields.RunModal();
        if RunModalAction = Action::OK then begin
            ImportConfigHeader.WriteLastFieldUpdateSelection(SelectMultipleFields.GetTargetFieldIDListAsText());
            Migrate.SelectedFieldsFrom(ImportConfigHeader);
        end;
    end;

    procedure PageAction_RetryBufferRecordsWithError(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        Migrate: Codeunit DMTMigrate;
        LogQry: Query DMTLogQry;
        RecIdList: List of [RecordId];
        NoErrorFoundLbl: label 'No errors were found for retry', Comment = 'de-DE=Es wurden keine Fehler zur erneuten Verbeitung gefunden';
    begin
        LogQry.SetRange(LogQry.SourceFileName, ImportConfigHeader.GetSourceFileName());
        LogQry.Open();
        while LogQry.Read() do begin
            if Format(LogQry.SourceID) <> '' then
                RecIdList.Add(LogQry.SourceID);
        end;
        if RecIdList.Count > 0 then
            Migrate.RetryBufferRecordIDs(RecIdList, ImportConfigHeader)
        else
            Message(NoErrorFoundLbl);
    end;

    local procedure AssignSourceToTargetFields(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        ImportConfigLine: Record DMTImportConfigLine;
        MigrationLib: Codeunit DMTMigrationLib;
        SourceFieldNames, TargetFieldNames : Dictionary of [Integer, Text];
        FoundAtIndex: Integer;
        SourceFieldID, TargetFieldID : Integer;
        NewFieldName, SourceFieldName : Text;
    begin
        // Load Target Field Names
        TargetFieldNames := CreateTargetFieldNamesDict(ImportConfigHeader);
        if TargetFieldNames.Count = 0 then
            exit;

        //Load Source Field Names
        SourceFieldNames := CreateSourceFieldNamesDict(ImportConfigHeader);
        if SourceFieldNames.Count = 0 then
            exit;

        //Match Fields by Name
        foreach SourceFieldID in SourceFieldNames.Keys do begin
            SourceFieldName := SourceFieldNames.Get(SourceFieldID);
            FoundAtIndex := TargetFieldNames.Values.IndexOf(SourceFieldName);
            // TargetField.SetFilter(FieldName, ConvertStr(BuffTableCaption, '@()&', '????'));
            if FoundAtIndex = 0 then
                if MigrationLib.FindFieldNameInOldVersion(SourceFieldName, ImportConfigHeader."Target Table ID", NewFieldName) then
                    FoundAtIndex := TargetFieldNames.Values.IndexOf(NewFieldName);
            if FoundAtIndex <> 0 then begin
                TargetFieldID := TargetFieldNames.Keys.Get(FoundAtIndex);
                // SetSourceField
                ImportConfigLine.Get(ImportConfigHeader.ID, TargetFieldID);
                ImportConfigLine.Validate("Source Field No.", SourceFieldID); // Validate to update processing action
                ImportConfigLine."Source Field Caption" := CopyStr(TargetFieldNames.Get(TargetFieldID), 1, MaxStrLen(ImportConfigLine."Source Field Caption"));
                ImportConfigLine.Modify();
            end;
        end;
    end;

    local procedure CreateSourceFieldNamesDict(ImportConfigHeader: Record DMTImportConfigHeader) SourceFieldNames: Dictionary of [Integer, Text]
    var
        GenBuffTable: Record DMTGenBuffTable;
        Field: Record Field;
        SourceFieldNames2: Dictionary of [Integer, Text];
        FieldID: Integer;
    begin
        if ImportConfigHeader."Use Separate Buffer Table" then begin
            Field.SetRange(TableNo, ImportConfigHeader."Buffer Table ID");
            Field.SetRange(Enabled, true);
            Field.SetRange(Class, Field.Class::Normal);
            Field.FindSet();
            repeat
                SourceFieldNames.Add(Field."No.", Field.FieldName);
            until Field.Next() = 0;
        end else begin
            GenBuffTable.GetColCaptionForImportedFile(ImportConfigHeader, SourceFieldNames2);
            foreach FieldID in SourceFieldNames2.Keys do begin
                SourceFieldNames.Add(FieldID + 1000, SourceFieldNames2.Get(FieldID));
            end;
        end;
    end;

    local procedure CreateTargetFieldNamesDict(ImportConfigHeader: Record DMTImportConfigHeader) TargetFieldNames: Dictionary of [Integer, Text]
    var
        ImportConfigLine: Record DMTImportConfigLine;
        Field: Record Field;
        ReplaceExistingMatchesQst: Label 'All fields are already assigned. Overwrite existing assignment?', comment = 'de-DE=Alle Felder sind bereits zugewiesen. Bestehende Zuordnung überschreiben?';
    begin
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Source Field No.", '<>%1', 0);
        if ImportConfigLine.FindFirst() then begin
            if Confirm(ReplaceExistingMatchesQst) then begin
                ImportConfigLine.SetRange("Source Field No.");
            end;
        end else begin
            ImportConfigLine.SetRange("Source Field No."); // no fields assigned case
        end;
        if not ImportConfigLine.FindSet() then
            exit;
        repeat
            Field.Get(ImportConfigLine."Target Table ID", ImportConfigLine."Target Field No.");
            TargetFieldNames.Add(Field."No.", Field.FieldName);
        until ImportConfigLine.Next() = 0;
    end;


    local procedure ProposeValidationRules(ImportConfigHeader: Record DMTImportConfigHeader): Boolean
    var
        ImportConfigLine, ImportConfigLine2 : Record DMTImportConfigLine;
        MigrationLib: Codeunit DMTMigrationLib;
    begin
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetRange("Processing Action", ImportConfigLine."Processing Action"::Transfer);
        if ImportConfigLine.FindSet(true) then
            repeat
                ImportConfigLine2 := ImportConfigLine;
                MigrationLib.ApplyKnownValidationRules(ImportConfigLine);
                if Format(ImportConfigLine2) <> Format(ImportConfigLine) then
                    ImportConfigLine.Modify()
            until ImportConfigLine.Next() = 0;
    end;


    local procedure GetListOfKeyFieldIDs(var recRef: RecordRef) keyFieldIDsList: List of [Integer];
    var
        fieldRef: FieldRef;
        _keyIndex: Integer;
        keyRef: KeyRef;
    begin
        keyRef := recRef.KeyIndex(1);
        for _keyIndex := 1 to keyRef.FieldCount do begin
            fieldRef := keyRef.FieldIndex(_keyIndex);
            keyFieldIDsList.Add(fieldRef.Number);
        end;
    end;

}