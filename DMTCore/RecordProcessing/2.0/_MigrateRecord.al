codeunit 91008 DMTMigrateRecord
{
    trigger OnRun()
    begin
        if UseTriggerLog then
            InitTriggerLog();

        case RunMode of
            RunMode::ProcessKeyFields:
                ProcessKeyFields();
            RunMode::ProcessNonKeyFields:
                ProcessNonKeyFields();
            RunMode::InsertRecord:
                begin
                    if IsTriggerLogInterfaceInitialized then
                        ChangeRecordWithPerm.SetTriggerLog(ITriggerLogGlobal);
                    ChangeRecordWithPerm.InsertOrOverwriteRecFromTmp(TmpTargetRef, CurrTargetRecIDText, ImportConfigHeaderGlobal."Use OnInsert Trigger");
                end;
            RunMode::ModifyRecord:
                begin
                    if IsTriggerLogInterfaceInitialized then
                        ChangeRecordWithPerm.SetTriggerLog(ITriggerLogGlobal);
                    ChangeRecordWithPerm.ModifyRecFromTmp(TmpTargetRef, ImportConfigHeaderGlobal."Use OnInsert Trigger");
                end;
            else
                Error('RunMode not handled %1', RunMode);
        end;
    end;

    internal procedure Init(bufferRef: RecordRef; importSettings: Codeunit DMTImportSettings; iReplacementHandlerNew: Interface IReplacementHandler)
    begin
        Clear(CurrTargetRecIDText); // only once, not for every field
        ImportConfigHeaderGlobal := importSettings.ImportConfigHeader();
        EvaluateOptionValueAsNumberGlobal := importSettings.EvaluateOptionValueAsNumber();
        SourceRefGlobal := bufferRef;
        importSettings.GetImportConfigLine(TempImportConfigLine);
        TmpTargetRef.Open(ImportConfigHeaderGlobal."Target Table ID", true, CompanyName);
        // Initialized target record for validate if not empty option
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        // Logs
        IReplacementHandler := iReplacementHandlerNew;
        iReplacementHandler.InitProcess(bufferRef);  // collect replacements for record
        UseTriggerLog := importSettings.UseTriggerLog();
        // Reset stored errors
        Clear(ErrorLogDict);
    end;

    local procedure ProcessKeyFields()
    begin
        TempImportConfigLine.SetRange("Is Key Field(Target)", true);
        TempImportConfigLine.SetFilter("Processing Action", '<>%1', TempImportConfigLine."Processing Action"::Ignore);
        TempImportConfigLine.SetCurrentKey("Validation Order");
        if not TempImportConfigLine.FindSet() then
            Error('ImportConfigLine for Key Fields is invalid');
        repeat
            if not ProcessedFields.Contains(TempImportConfigLine.RecordId) then begin
                CurrFieldToProcess := TempImportConfigLine.RecordId;
                if not IsKnownAutoincrementField(TempImportConfigLine) then
                    AssignField(Enum::DMTFieldValidationType::AssignWithoutValidate);
                ProcessedFields.Add(TempImportConfigLine.RecordId);
            end;
        until TempImportConfigLine.Next() = 0;

        if TmpTargetRef.Insert(false) then; // provide a record to avoid errors in trigger code when calling Rec.Modify
        CurrTargetRecIDText := Format(TmpTargetRef.RecordId);
        TargetRecordExistsGlobal := FindExistingTargetRef(ExistingTargetRefGlobal, TmpTargetRef);
    end;

    procedure GetExistingTargetRef(var existingRef: RecordRef) TargetRefFound: Boolean
    begin
        TargetRefFound := TargetRecordExistsGlobal;
        existingRef := ExistingTargetRefGlobal.Duplicate();
    end;

    internal procedure TargetRecordExists(): Boolean
    begin
        exit(TargetRecordExistsGlobal);
    end;

    internal procedure SaveErrorLog(log: Codeunit DMTLog)
    var
        ImportConfigLineID: RecordId;
        ErrorItem: Dictionary of [Text, Text];
    begin
        foreach ImportConfigLineID in ErrorLogDict.Keys do begin
            ErrorItem := ErrorLogDict.Get(ImportConfigLineID);
            TempImportConfigLine.Get(ImportConfigLineID);
            Log.AddErrorByImportConfigLineEntry(SourceRefGlobal.RecordId, ImportConfigHeaderGlobal, TempImportConfigLine, ErrorItem);
        end;
    end;

    internal procedure SaveTriggerLog(Log: Codeunit DMTLog)
    begin
        if IsTriggerLogInterfaceInitialized then
            ITriggerLogGlobal.SaveTriggerLog(Log, ImportConfigHeaderGlobal, SourceRefGlobal);
    end;

    internal procedure SetRunMode_ProcessKeyFields()
    begin
        RunMode := RunMode::ProcessKeyFields;
    end;

    internal procedure SetRunMode_ProcessNonKeyFields()
    begin
        RunMode := RunMode::ProcessNonKeyFields;
    end;

    internal procedure SetRunMode_InsertRecord()
    begin
        RunMode := RunMode::InsertRecord;
    end;

    internal procedure SetRunMode_ModifyRecord()
    begin
        RunMode := RunMode::ModifyRecord
    end;

    internal procedure CollectLastError()
    var
        ErrorItem: Dictionary of [Text, Text];
    begin
        if GetLastErrorText() = '' then
            exit;
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        ErrorItem.Add('ErrorValue', CurrValueToAssignText);
        ErrorItem.Add('ErrorTargetRecID', CurrTargetRecIDText);
        ErrorLogDict.Add(CurrFieldToProcess, ErrorItem);
        ProcessedFields.Add(CurrFieldToProcess);
        // Check if this error should block the insert oder modify
        if RunMode = RunMode::ProcessNonKeyFields then
            if not ErrorsOccuredThatShouldNotBeIngored then begin
                TempImportConfigLine.Get(CurrFieldToProcess);
                if not TempImportConfigLine."Ignore Validation Error" then
                    ErrorsOccuredThatShouldNotBeIngored := true;
            end;

        ClearLastError();
    end;

    internal procedure UpdateDMTImportFields()
    begin
        ImportConfigHeaderGlobal.BufferTableMgt().SetDMTImportFields(SourceRefGlobal, CurrTargetRecIDText);
    end;

    procedure HasErrorsThatShouldNotBeIngored(): Boolean
    begin
        exit(ErrorsOccuredThatShouldNotBeIngored);
    end;

    local procedure IsKnownAutoincrementField(var importConfigLine: Record DMTImportConfigLine temporary) IsAutoincrement: Boolean
    var
        RecordLink: Record "Record Link";
        ReservationEntry: Record "Reservation Entry";
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        ActivityLog: Record "Activity Log";
    begin
        IsAutoincrement := false;
        case true of
            (importConfigLine."Target Table ID" = RecordLink.RecordID.TableNo) and (importConfigLine."Target Field No." = RecordLink.FieldNo("Link ID")):
                exit(true);
            (importConfigLine."Target Table ID" = ReservationEntry.RecordID.TableNo) and (importConfigLine."Target Field No." = ReservationEntry.FieldNo("Entry No.")):
                exit(true);
            (importConfigLine."Target Table ID" = ChangeLogEntry.RecordID.TableNo) and (importConfigLine."Target Field No." = ChangeLogEntry.FieldNo("Entry No.")):
                exit(true);
            (importConfigLine."Target Table ID" = JobQueueLogEntry.RecordID.TableNo) and (importConfigLine."Target Field No." = JobQueueLogEntry.FieldNo("Entry No.")):
                exit(true);
            (importConfigLine."Target Table ID" = ActivityLog.RecordID.TableNo) and (importConfigLine."Target Field No." = ActivityLog.FieldNo(ID)):
                exit(true);
            else
                exit(false);
        end;

    end;

    local procedure AssignField(ValidateSetting: Enum DMTFieldValidationType)
    var
        ValueToAssignField, TargetField : FieldRef;
    begin
        // Blob handling
        TargetField := TmpTargetRef.Field(TempImportConfigLine."Target Field No.");
        if TargetField.Type in [FieldType::Blob, FieldType::Media] then
            if HandleBase64ToBlobTransferfromGenBuffTable(TargetField, TempImportConfigLine, SourceRefGlobal) then
                exit;
        // Create source field with the correct field type
        // =================================================
        if IReplacementHandler.HasReplacementsForTargetField(TempImportConfigLine."Target Field No.") then begin
            //use value from replacement
            ValueToAssignField := IReplacementHandler.GetReplacementValue(TempImportConfigLine."Target Field No.");
        end else begin
            // use value from buffer
            AssignValueToFieldRef(SourceRefGlobal, TempImportConfigLine, TmpTargetRef, ValueToAssignField);
        end;
        CurrValueToAssignText := Format(ValueToAssignField.Value); // Error Log Info

        // Assign value in fieldRef to target field
        // ========================================
        case ValidateSetting of
            ValidateSetting::AssignWithoutValidate:
                begin
                    TargetField.Value := ValueToAssignField.Value;
                    if IsTriggerLogInterfaceInitialized then
                        ITriggerLogGlobal.LogAssignment(ValueToAssignField, TargetField, TmpTargetRef);
                end;
            ValidateSetting::AlwaysValidate:
                begin
                    if IsTriggerLogInterfaceInitialized then
                        ITriggerLogGlobal.InitBeforeValidate(ValueToAssignField, TargetField, TmpTargetRef);
                    TargetField.Validate(ValueToAssignField.Value);
                    if IsTriggerLogInterfaceInitialized then
                        ITriggerLogGlobal.CheckAfterValidate(TmpTargetRef);
                end;
            ValidateSetting::ValidateOnlyIfNotEmpty:
                begin
                    if Format(ValueToAssignField.Value) <> Format(TargetRef_INIT.Field(TargetField.Number).Value) then begin
                        if IsTriggerLogInterfaceInitialized then
                            ITriggerLogGlobal.InitBeforeValidate(ValueToAssignField, TargetField, TmpTargetRef);
                        TargetField.Validate(ValueToAssignField.Value);
                        if IsTriggerLogInterfaceInitialized then
                            ITriggerLogGlobal.CheckAfterValidate(TmpTargetRef);
                    end;
                end;
        end;
    end;

    procedure AssignValueToFieldRef(SourceRecRef: RecordRef; ImportConfigLine: Record DMTImportConfigLine; TargetRecRef: RecordRef; var FieldWithTypeCorrectValueToValidate: FieldRef)
    var
        TargetRecRef2: RecordRef;
        FromField: FieldRef;
        ValidateFailedErr: Label 'The value %1 could not be entered into the field %2',
                 Comment = 'de-DE=Der Wert %1 konnte nicht in das Feld %2 eingetragen werden';
    begin
        if ImportConfigLine."Processing Action" <> ImportConfigLine."Processing Action"::FixedValue then begin
            FromField := SourceRecRef.Field(ImportConfigLine."Source Field No.");
            CurrValueToAssignText := Format(FromField.Value); // Error Log Info
        end else begin
            CurrValueToAssignText := ImportConfigLine."Fixed Value"; // Error Log Info
        end;

        TargetRecRef2 := TargetRecRef.Duplicate(); // create a duplicate to avoid filling the original target record
        FieldWithTypeCorrectValueToValidate := TargetRecRef2.Field(ImportConfigLine."Target Field No.");
        case true of
            // Create fieldRef from fixed value
            (ImportConfigLine."Processing Action" = ImportConfigLine."Processing Action"::FixedValue):
                RefHelper.AssignFixedValueToFieldRef(FieldWithTypeCorrectValueToValidate, ImportConfigLine."Fixed Value");
            // copy fieldRef from source field
            (TargetRecRef.Field(ImportConfigLine."Target Field No.").Type = FromField.Type):
                FieldWithTypeCorrectValueToValidate.Value := FromField.Value; // Same Type -> no conversion needed
            // evaluate text to target field
            (FromField.Type in [FieldType::Text, FieldType::Code]):
                if not RefHelper.EvaluateFieldRef(FieldWithTypeCorrectValueToValidate, Format(FromField.Value), EvaluateOptionValueAsNumberGlobal, true) then
                    // Kommt beim Wechsel von Puffertabelle zu generischer Tabelle vor
                    // Kommt vor wenn der alte Wert ein Code war und der neue Wert ein Option
                    Error(ValidateFailedErr, CurrValueToAssignText, TargetRecRef.Field(ImportConfigLine."Target Field No.").Caption);
            else
                Error('AssignValueToFieldRef - unhandled TODO %1', FromField.Type);
        end;
    end;

    local procedure HandleBase64ToBlobTransferfromGenBuffTable(var targetField: FieldRef; importConfigLine: Record DMTImportConfigLine; var sourceRef: RecordRef) OK: Boolean
    var
        blobStorage: Record DMTBlobStorage;
        genBuffTable: Record DMTGenBuffTable;
        field: Record Field;
        recordLink: Record "Record Link";
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        RecordLinkManagement: Codeunit "Record Link Management";
        TempBlob: Codeunit "Temp Blob";
        recRef: RecordRef;
        IStream: InStream;
        jObj: JsonObject;
        jToken: JsonToken;
        OStream: OutStream;
        fieldContent: Text;
        char177: Text[1];
    begin
        if sourceRef.Number <> genBuffTable.RecordId.TableNo then
            exit(false);
        OK := true;
        char177[1] := 177;
        if field.Get(importConfigLine."Target Table ID", importConfigLine."Target Field No.") then
            if not (field.Type in [field.Type::BLOB, field.Type::Media]) then
                exit(false);

        sourceRef.SetTable(genBuffTable);
        blobStorage.SetRange("Gen. Buffer Table Entry No.", genBuffTable."Entry No.");
        blobStorage.SetRange("Source Field No.", importConfigLine."Source Field No.");
        if blobStorage.IsEmpty() then
            exit(false);

        case true of
            // is record Link Note
            (targetField.Number = recordLink.fieldNo(Note)) and (targetField.Record().RecordId.TableNo = database::"Record Link"):
                begin
                    blobStorage.FindFirst();
                    blobStorage.CalcFields(Blob);
                    blobStorage.Blob.CreateInStream(IStream);
                    IStream.ReadText(fieldContent);
                    RecordLinkManagement.WriteNote(recordLink, fieldContent);
                    targetField.Value := recordLink.Note;
                    Clear(fieldContent);
                    fieldContent := RecordLinkManagement.ReadNote(recordLink);
                end;
            // is blob content
            (targetField.Type = FieldType::Blob):
                begin
                    blobStorage.FindFirst();
                    blobStorage.CalcFields(Blob);
                    blobStorage.Blob.CreateInStream(IStream);
                    IStream.ReadText(fieldContent);
                    if fieldContent.StartsWith('base64:') then begin
                        fieldContent := fieldContent.TrimStart('base64:');
                        fieldContent := DelChr(fieldContent, '<>', char177);
                    end;
                    TempBlob.CreateOutStream(OStream);
                    Base64Convert.FromBase64(fieldContent, OStream);
                    TempBlob.ToFieldRef(targetField);
                end;
            // is media content
            (targetField.Type = FieldType::Media):
                begin
                    blobStorage.FindFirst();
                    blobStorage.CalcFields(Blob);
                    blobStorage.Blob.CreateInStream(IStream);
                    IStream.ReadText(fieldContent);
                    if fieldContent.StartsWith('JSON:') then begin
                        fieldContent := fieldContent.TrimStart('JSON:');
                        fieldContent := DelChr(fieldContent, '<>', char177);
                        jObj.ReadFrom(fieldContent);
                        Clear(TenantMedia);
                        TenantMedia.ID := CreateGuid();
                        TenantMedia."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TenantMedia."Company Name"));
                        if jObj.Get(TenantMedia.FieldName("Mime Type"), jToken) then
                            TenantMedia."Mime Type" := CopyStr(jToken.AsValue().AsText(), 1, MaxStrLen(TenantMedia."Mime Type"));
                        if jObj.Get(TenantMedia.FieldName("File Name"), jToken) then
                            TenantMedia."File Name" := CopyStr(jToken.AsValue().AsText(), 1, MaxStrLen(TenantMedia."File Name"));
                        if jObj.Get(TenantMedia.FieldName(Content), jToken) then begin
                            fieldContent := jToken.AsValue().AsText();
                            TempBlob.CreateOutStream(OStream);
                            Base64Convert.FromBase64(fieldContent, OStream);
                            recRef.GetTable(TenantMedia);
                            TempBlob.ToRecordRef(recRef, TenantMedia.FieldNo(Content));
                            recRef.Insert();
                            targetField.Value(TenantMedia.ID);
                        end;
                    end;
                end;
        end;
    end;

    procedure InitTriggerLog() IsInitialized: Boolean
    begin
        if not IsTriggerLogInterfaceInitialized then
            IsTriggerLogInterfaceInitialized := DMTSetup.getDefaultTriggerLogImplementation(ITriggerLogGlobal);
        exit(IsTriggerLogInterfaceInitialized);
    end;

    local procedure FindExistingTargetRef(var _ExistingRef: RecordRef; var _TmpTargetRef: RecordRef) TargetRefFound: Boolean
    var
        RecordLinkExisting, RecordLinkNew : Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        ToNote, FromNote : Text;
    begin
        case true of
            _TmpTargetRef.RecordId.TableNo = Database::"Record Link":
                begin
                    _TmpTargetRef.SetTable(RecordLinkNew);
                    RecordLinkExisting.SetRange("Record ID", RecordLinkNew."Record ID");
                    RecordLinkExisting.SetRange(Company, CompanyName);
                    RecordLinkExisting.SetRange(Type, RecordLinkNew.Type::Note);
                    if not RecordLinkExisting.FindSet() then
                        exit(false);
                    repeat
                        RecordLinkExisting.CalcFields(Note);
                        FromNote := RecordLinkManagement.ReadNote(RecordLinkExisting);
                        ToNote := RecordLinkManagement.ReadNote(RecordLinkNew);
                        if FromNote = ToNote then begin
                            _ExistingRef.GetTable(RecordLinkExisting);
                            exit(true);
                        end;
                    until RecordLinkExisting.Next() = 0;
                end;
            else
                TargetRefFound := _ExistingRef.Get(_TmpTargetRef.RecordId);
        end;
    end;

    local procedure ProcessNonKeyFields()
    begin
        TempImportConfigLine.SetRange("Is Key Field(Target)", false);
        TempImportConfigLine.SetCurrentKey("Validation Order");
        if TempImportConfigLine.FindSet() then // if only Key Fields are mapped this is false
            repeat
                if not ProcessedFields.Contains(TempImportConfigLine.RecordId) then begin
                    CurrFieldToProcess := TempImportConfigLine.RecordId;
                    AssignField(TempImportConfigLine."Validation Type");
                    ProcessedFields.Add(TempImportConfigLine.RecordId);
                end;
            until TempImportConfigLine.Next() = 0;
    end;

    var
        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        DMTSetup: Record DMTSetup;
        RefHelper: Codeunit DMTRefHelper;
        ChangeRecordWithPerm: Codeunit DMTChangeRecordWithPerm;
        CurrFieldToProcess: RecordId;
        SourceRefGlobal, TargetRef_INIT, TmpTargetRef, ExistingTargetRefGlobal : RecordRef;
        ErrorsOccuredThatShouldNotBeIngored: Boolean;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        IReplacementHandler: Interface IReplacementHandler;
        ProcessedFields: List of [RecordId];
        RunMode: Option ProcessKeyFields,ProcessNonKeyFields,InsertRecord,ModifyRecord;
        CurrTargetRecIDText, CurrValueToAssignText : Text;
        UseTriggerLog, IsTriggerLogInterfaceInitialized : Boolean;
        TargetRecordExistsGlobal: Boolean;
        EvaluateOptionValueAsNumberGlobal: Boolean;
        ITriggerLogGlobal: Interface ITriggerLog;

}