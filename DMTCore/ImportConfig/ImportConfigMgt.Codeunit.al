codeunit 91002 DMTImportConfigMgt
{
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
                        ImportConfigLine_NEW."Target Table Relation" := TargetRecRef.FieldIndex(i).Relation;
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
        NoErrorFoundLbl: Label 'No errors were found for retry', Comment = 'de-DE=Es wurden keine Fehler zur erneuten Verbeitung gefunden';
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
        DMTSetup: Record DMTSetup;
        MigrationLib: Codeunit DMTMigrationLib;
        SourceFieldNamesFromBuffer, TargetFieldNames : Dictionary of [Integer, Text];
        ExistingFieldMappings: Dictionary of [Text, Text];
        FoundAtIndex: Integer;
        SourceFieldID, TargetFieldID : Integer;
        NewFieldName, SourceFieldName, TargetFieldName : Text;
    begin
        // Load Target Field Names
        DMTSetup.GetRecordOnce();
        if DMTSetup.MigrationProfil = DMTSetup.MigrationProfil::"From NAV" then
            TargetFieldNames := CreateTargetFieldNamesDict(ImportConfigHeader, false)  // Names
        else
            TargetFieldNames := CreateTargetFieldNamesDict(ImportConfigHeader, true);  // Captions
        if TargetFieldNames.Count = 0 then
            exit;

        //Load Source Field Names
        SourceFieldNamesFromBuffer := CreateSourceFieldNamesDict(ImportConfigHeader);
        // if SourceFieldNames.Count = 0 then
        //     exit;

        //Load Existing Mappings
        ImportConfigLine.Reset();
        ImportConfigLine.SetAutoCalcFields("Target Field Caption");
        ImportConfigLine.SetFilter("Source Field Caption", '<>''''');
        ImportConfigLine.SetFilter("Target Field Caption", '<>''''');
        if ImportConfigLine.FindSet(false) then
            repeat
                ExistingFieldMappings.Set(ImportConfigLine."Source Field Caption", ImportConfigLine."Target Field Caption");
            until ImportConfigLine.Next() = 0;

        //Match Fields by Name
        foreach SourceFieldID in SourceFieldNamesFromBuffer.Keys do begin
            SourceFieldName := SourceFieldNamesFromBuffer.Get(SourceFieldID);
            SourceFieldName := SourceFieldName.TrimEnd(' '); // BC Felder haben keine Leerzeichen am Ende, für Matching entfernen
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
                ImportConfigLine."Source Field Caption" := CopyStr(SourceFieldName, 1, MaxStrLen(ImportConfigLine."Source Field Caption"));
                ImportConfigLine.Modify();
            end;
        end;
        DMTSetup.InsertWhenEmpty();
        DMTSetup.GetRecordOnce();
        // Match Fields by existing Mappings
        if DMTSetup."Use exist. mappings" then
            foreach SourceFieldID in SourceFieldNamesFromBuffer.Keys do begin
                // if fieldmapping contains sourcefieldname
                SourceFieldName := SourceFieldNamesFromBuffer.Get(SourceFieldID);
                FoundAtIndex := ExistingFieldMappings.Keys.IndexOf(SourceFieldName);
                if FoundAtIndex <> 0 then begin
                    // if target field name from mapping exists in import configuration
                    TargetFieldName := ExistingFieldMappings.Values.Get(FoundAtIndex);
                    if TargetFieldNames.Values.Contains(TargetFieldName) then begin
                        FoundAtIndex := TargetFieldNames.Values.IndexOf(TargetFieldName);
                        TargetFieldID := TargetFieldNames.Keys.Get(FoundAtIndex);
                        ImportConfigLine.Get(ImportConfigHeader.ID, TargetFieldID);
                        if ImportConfigLine."Source Field No." = 0 then begin
                            ImportConfigLine.Validate("Source Field No.", SourceFieldID); // Validate to update processing action
                            // ImportConfigLine."Source Field Caption" := CopyStr(, 1, MaxStrLen(ImportConfigLine."Source Field Caption"));
                            ImportConfigLine.Modify();
                        end;
                    end;
                end;
            end;
    end;

    local procedure CreateSourceFieldNamesDict(importConfigHeader: Record DMTImportConfigHeader) SourceFieldNames: Dictionary of [Integer, Text]
    var
        dataLayout: Record DMTDataLayout;
        genBuffTable: Record DMTGenBuffTable;
        dataLayoutLine: Record DMTDataLayoutLine;
        Field: Record Field;
        SourceFieldNames2: Dictionary of [Integer, Text];
        FieldID: Integer;
        NoHeadlineInfoFoundInDataLayoutErr: Label 'You have to setup the column names in datalayout "%1"',
                                  Comment = 'de-DE=Sie müssen die Spaltentitel im Datenlayout "%1" einrichten.';
    begin
        dataLayout := importConfigHeader.GetDataLayout();
        case true of
            // seperate buffer table -> read field names
            importConfigHeader."Use Separate Buffer Table":
                begin
                    Field.SetRange(TableNo, importConfigHeader."Buffer Table ID");
                    Field.SetRange(Enabled, true);
                    Field.SetRange(Class, Field.Class::Normal);
                    Field.FindSet();
                    repeat
                        SourceFieldNames.Add(Field."No.", Field.FieldName);
                    until Field.Next() = 0;
                end;
            // use genBuffer, file has heading line  -> read heading line from buffer
            dataLayout."Has Heading Row":
                begin
                    genBuffTable.GetColCaptionForImportedFile(importConfigHeader, SourceFieldNames2);
                    foreach FieldID in SourceFieldNames2.Keys do begin
                        SourceFieldNames.Add(FieldID, SourceFieldNames2.Get(FieldID));
                    end;
                end;
            // use genBuffer, file without heading line  -> read data layout line
            not dataLayout."Has Heading Row":
                begin
                    dataLayoutLine.SetRange("Data Layout ID", dataLayout.ID);
                    if not dataLayoutLine.FindSet(false) then begin
                        Error(NoHeadlineInfoFoundInDataLayoutErr, dataLayout.ID);
                    end else
                        repeat
                            dataLayoutLine.TestField(ColumnName);
                            SourceFieldNames.Add(dataLayoutLine."Column No.", dataLayoutLine.ColumnName);
                        until dataLayoutLine.Next() = 0;
                end;
        end;
    end;

    local procedure CreateTargetFieldNamesDict(ImportConfigHeader: Record DMTImportConfigHeader; UseCaptionInstead: Boolean) TargetFieldNames: Dictionary of [Integer, Text]
    var
        ImportConfigLine: Record DMTImportConfigLine;
        overwrite, HasAssignments : Boolean;
    begin
        overwrite := ConfirmOverwriteExistingAssignments(ImportConfigHeader, HasAssignments);
        if HasAssignments and not overwrite then
            ImportConfigLine.SetFilter("Source Field No.", '<>%1', 0);
        TargetFieldNames := CreateTargetFieldNamesDict(ImportConfigLine, UseCaptionInstead);
    end;

    procedure CreateTargetFieldNamesDict(var ImportConfigLine: Record DMTImportConfigLine; UseCaptionInstead: Boolean) TargetFieldNames: Dictionary of [Integer, Text]
    var
        Field: Record Field;
    begin
        if not ImportConfigLine.FindSet() then
            exit;

        repeat
            Field.Get(ImportConfigLine."Target Table ID", ImportConfigLine."Target Field No.");
            if UseCaptionInstead then
                TargetFieldNames.Add(Field."No.", Field."Field Caption")
            else
                TargetFieldNames.Add(Field."No.", Field.FieldName);
        until ImportConfigLine.Next() = 0;
    end;

    local procedure ConfirmOverwriteExistingAssignments(ImportConfigHeader: Record DMTImportConfigHeader; var HasAssignments: boolean) Result: Boolean
    var
        ImportConfigLine: Record DMTImportConfigLine;
        OverwriteExistingAssignmentsQst: Label 'Overwrite existing field assignments?', Comment = 'de-DE=Vorhandene Zuordnung überschreiben?';
    begin
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Source Field No.", '<>%1', 0);
        HasAssignments := not ImportConfigLine.IsEmpty;
        if HasAssignments then
            Result := Confirm(OverwriteExistingAssignmentsQst);
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