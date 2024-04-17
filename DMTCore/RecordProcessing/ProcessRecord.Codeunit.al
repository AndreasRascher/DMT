codeunit 91008 DMTProcessRecord
{
    trigger OnRun()
    begin
        Start()
    end;

    procedure Start()
    begin
        initTriggerLog();
        Clear(CurrValueToAssignText);
        if RunMode = RunMode::FieldTransfer then begin
            case true of
                ImportConfigHeader."Target Table ID" = Database::"Record Link":
                    begin
                        ProcessNonKeyFields(); // Surrogate Table Structure -> no Key Fields
                                               // if ProcessedFields.Count < TargetKeyFieldIDs.Count then
                        ProcessKeyFields();
                    end;
                else begin
                    if ProcessedFields.Count < TargetKeyFieldIDs.Count then
                        ProcessKeyFields();
                    if (not SkipRecordGlobal) or UpdateFieldsInExistingRecordsOnly then
                        ProcessNonKeyFields();
                end;
            end;
        end;

        if RunMode = RunMode::InsertRecord then begin
            SaveRecord();
        end;

        if RunMode = RunMode::ModifyRecord then begin
            SaveRecord();
        end;
    end;

    local procedure AssignField(ValidateSetting: Enum DMTFieldValidationType)
    var
        FieldWithTypeCorrectValueToValidate, TargetField : FieldRef;
        SourceField: FieldRef;
    begin
        TargetField := TmpTargetRef.Field(TempImportConfigLine."Target Field No.");
        if HandleBase64ToBlobTransferfromGenBuffTable(TargetField, TempImportConfigLine, SourceRefGlobal) then
            exit;
        //hier: Prüfen warum der Blob nicht übertragen wird
        SourceField := SourceRefGlobal.Field(TempImportConfigLine."Source Field No.");
        if IReplacementHandler.HasReplacementsForTargetField(TargetField.Number) then begin
            //use value from replacement
            FieldWithTypeCorrectValueToValidate := IReplacementHandler.GetReplacementValue(TargetField.Number);
        end else begin
            //use values from buffer table field
            AssignValueToFieldRef(SourceRefGlobal, TempImportConfigLine, TmpTargetRef, FieldWithTypeCorrectValueToValidate);
        end;
        CurrValueToAssign := FieldWithTypeCorrectValueToValidate;
        CurrValueToAssign_IsInitialized := true;
        case ValidateSetting of
            ValidateSetting::AssignWithoutValidate:
                begin
                    TargetField.Value := FieldWithTypeCorrectValueToValidate.Value;
                end;
            ValidateSetting::ValidateOnlyIfNotEmpty:
                begin
                    if Format(SourceField.Value) <> Format(TargetRef_INIT.Field(TargetField.Number).Value) then begin
                        if IsTriggerLogInterfaceInitialized then
                            ITriggerLogGlobal.InitBeforeValidate(SourceField, TargetField, TmpTargetRef);
                        TargetField.Validate(FieldWithTypeCorrectValueToValidate.Value);
                        if IsTriggerLogInterfaceInitialized then
                            ITriggerLogGlobal.CheckAfterValidate(TmpTargetRef);
                    end;
                end;
            ValidateSetting::AlwaysValidate:
                begin
                    if IsTriggerLogInterfaceInitialized then
                        ITriggerLogGlobal.InitBeforeValidate(SourceField, TargetField, TmpTargetRef);
                    TargetField.Validate(FieldWithTypeCorrectValueToValidate.Value);
                    if IsTriggerLogInterfaceInitialized then
                        ITriggerLogGlobal.CheckAfterValidate(TmpTargetRef);
                end;
        end;
    end;

    procedure AssignValueToFieldRef(SourceRecRef: RecordRef; ImportConfigLine: Record DMTImportConfigLine; TargetRecRef: RecordRef; var FieldWithTypeCorrectValueToValidate: FieldRef)
    var
        TargetRecRef2: RecordRef;
        FromField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        if not HandleBase64ToBlobTransferfromGenBuffTable(FromField, ImportConfigLine, SourceRecRef) then
            FromField := SourceRecRef.Field(ImportConfigLine."Source Field No.");
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRecRef.Number);
        TargetRecRef2 := TargetRecRef.Duplicate(); // create a duplicate to avoid filling the original target record
        FieldWithTypeCorrectValueToValidate := TargetRecRef2.Field(ImportConfigLine."Target Field No.");
        CurrValueToAssignText := Format(FromField.Value); // Error Log Info
        case true of
            (ImportConfigLine."Processing Action" = ImportConfigLine."Processing Action"::FixedValue):
                RefHelper.AssignFixedValueToFieldRef(FieldWithTypeCorrectValueToValidate, ImportConfigLine."Fixed Value");
            (TargetRecRef.Field(ImportConfigLine."Target Field No.").Type = FromField.Type):
                FieldWithTypeCorrectValueToValidate.Value := FromField.Value; // Same Type -> no conversion needed
            (FromField.Type in [FieldType::Text, FieldType::Code]):
                if not RefHelper.EvaluateFieldRef(FieldWithTypeCorrectValueToValidate, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
                    Error('TODO');
            else
                Error('unhandled TODO %1', FromField.Type);
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
        OK := true;
        char177[1] := 177;
        if sourceRef.Number <> genBuffTable.RecordId.TableNo then
            exit(false);
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

    local procedure ProcessKeyFields()
    var
        ExistingRef: RecordRef;
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
        SkipRecordGlobal := false;
        TargetRecordExists := FindExistingTargetRef(ExistingRef, TmpTargetRef);
        case true of
            // Nur vorhandene Datensätze updaten. Felder aus exist. Datensatz kopieren.
            UpdateFieldsInExistingRecordsOnly:
                begin
                    if TargetRecordExists then
                        RefHelper.CopyRecordRef(ExistingRef, TmpTargetRef)
                    else
                        SkipRecordGlobal := true; // only update, do not insert record when updating records
                end;
            // Kein Insert neuer Datensätze
            ImportConfigHeader."Import Only New Records" and not UpdateFieldsInExistingRecordsOnly:
                begin
                    if TargetRecordExists then
                        SkipRecordGlobal := true;
                end;
            ImportConfigHeader."Import Only New Records":
                begin
                    if TargetRecordExists then
                        SkipRecordGlobal := true;
                end;
        end;
        CurrTargetRecIDText := Format(TmpTargetRef.RecordId);
    end;

    procedure InitFieldTransfer(_SourceRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings)
    begin
        Clear(CurrTargetRecIDText); // only once, not for every field
        ImportConfigHeader := DMTImportSettings.ImportConfigHeader();
        SourceRefGlobal := _SourceRef;
        UpdateFieldsInExistingRecordsOnly := DMTImportSettings.UpdateExistingRecordsOnly();
        DMTImportSettings.GetImportConfigLine(TempImportConfigLine);
        TmpTargetRef.Open(ImportConfigHeader."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := RefHelper.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        RunMode := RunMode::FieldTransfer;
        Clear(ErrorLogDict);
        DMTSetup.getDefaultReplacementImplementation(IReplacementHandler);
        IReplacementHandler.InitProcess(_SourceRef);
    end;

    procedure InitInsert()
    begin
        RunMode := RunMode::InsertRecord;
    end;

    procedure InitModify()
    begin
        Clear(CurrTargetRecIDText); // only once, not for every field
        RunMode := RunMode::ModifyRecord;
    end;

    procedure LogLastError()
    var
        ErrorItem: Dictionary of [Text, Text];
    begin
        if GetLastErrorText() = '' then
            exit;
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        // if CurrValueToAssign_IsInitialized then
        ErrorItem.Add('ErrorValue', CurrValueToAssignText);
        ErrorItem.Add('ErrorTargetRecID', CurrTargetRecIDText);
        // else
        // ErrorItem.Add('ErrorValue', '');
        ErrorLogDict.Add(CurrFieldToProcess, ErrorItem);
        ProcessedFields.Add(CurrFieldToProcess);
        // Check if this error should block the insert oder modify
        if RunMode = RunMode::FieldTransfer then
            if not ErrorsOccuredThatShouldNotBeIngored then begin
                TempImportConfigLine.Get(CurrFieldToProcess);
                if not TempImportConfigLine."Ignore Validation Error" then
                    ErrorsOccuredThatShouldNotBeIngored := true;
            end;

        ClearLastError();
    end;

    procedure InitTriggerLog() IsInitialized: Boolean
    begin
        if not IsTriggerLogInterfaceInitialized then
            IsTriggerLogInterfaceInitialized := DMTSetup.getDefaultTriggerLogImplementation(ITriggerLogGlobal);
        exit(IsTriggerLogInterfaceInitialized);
    end;

    local procedure SaveRecord() Success: Boolean
    begin
        Success := true;
        if ErrorsOccuredThatShouldNotBeIngored then
            exit(false);
        ClearLastError();
        case RunMode of
            RunMode::InsertRecord:
                begin
                    if SkipRecordGlobal then
                        exit(false);
                    Success := ChangeRecordWithPerm.InsertOrOverwriteRecFromTmp(TmpTargetRef, CurrTargetRecIDText, ImportConfigHeader."Use OnInsert Trigger", IsTriggerLogInterfaceInitialized, ITriggerLogGlobal);
                end;
            RunMode::ModifyRecord:
                begin
                    if SkipRecordGlobal then
                        exit(false);
                    Success := ChangeRecordWithPerm.ModifyRecFromTmp(TmpTargetRef, ImportConfigHeader."Use OnInsert Trigger", IsTriggerLogInterfaceInitialized, ITriggerLogGlobal);
                end;
        end;
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

    procedure SaveErrorLog(Log: Codeunit DMTLog) ErrorsExist: Boolean
    var
        ImportConfigLineID: RecordId;
        ErrorItem: Dictionary of [Text, Text];
    begin
        foreach ImportConfigLineID in ErrorLogDict.Keys do begin
            ErrorItem := ErrorLogDict.Get(ImportConfigLineID);
            TempImportConfigLine.Get(ImportConfigLineID);
            ErrorsExist := ErrorsExist or not TempImportConfigLine."Ignore Validation Error";
            Log.AddErrorByImportConfigLineEntry(SourceRefGlobal.RecordId, ImportConfigHeader, TempImportConfigLine, ErrorItem);
        end;
    end;
    //ToDo: if values have been changed via trigger, create log entry and write the changes in the trigger log to the database
    internal procedure SaveTriggerLog(Log: Codeunit DMTLog)
    begin
        if IsTriggerLogInterfaceInitialized then
            ITriggerLogGlobal.SaveTriggerLog(Log, ImportConfigHeader);
    end;

    procedure GetProcessingResultType() ResultType: Enum DMTProcessingResultType
    begin
        // Ausstiegsgrund						Datensatz		Zieldatensatz 
        // 								        verarbeiten     nicht vorhanden
        // - Neue neue DS / DS existiert bereits	x
        // - Fehler beim Werte übertragen			x			x
        // - Feldupdate 										x

        // Zeilen verarbeiten
        // - DS Verarbeitet,
        //   - = DS Importiert + DS Ignoriert + DS mit Fehler
        // Felder verarbeiten
        // - DS Verarbeitet
        //   - = DS aktualisiert + DS Ignoriert + DS mit Fehler
        case true of
            (RunMode in [RunMode::FieldTransfer, RunMode::ModifyRecord, RunMode::InsertRecord]) and ErrorsOccuredThatShouldNotBeIngored:
                exit(ResultType::Error);
            (RunMode in [RunMode::ModifyRecord, RunMode::InsertRecord]) and SkipRecordGlobal:
                exit(ResultType::Ignored);
            (RunMode in [RunMode::FieldTransfer, RunMode::ModifyRecord, RunMode::InsertRecord]) and
            not ErrorsOccuredThatShouldNotBeIngored and not SkipRecordGlobal:
                exit(ResultType::ChangesApplied);
            else
                Error('unhandled case');
        end;
    end;

    internal procedure SaveTargetRefInfosInBuffertable()
    begin
        ImportConfigHeader.BufferTableMgt().SetDMTImportFields(SourceRefGlobal, CurrTargetRecIDText);
    end;



    var
        DMTSetup: Record "DMTSetup";
        ImportConfigHeader: Record DMTImportConfigHeader;
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        ChangeRecordWithPerm: Codeunit DMTChangeRecordWithPerm;
        RefHelper: Codeunit DMTRefHelper;
        CurrFieldToProcess: RecordId;
        SourceRefGlobal, TargetRef_INIT, TmpTargetRef : RecordRef;
        CurrValueToAssign: FieldRef;
        CurrValueToAssign_IsInitialized: Boolean;
        ErrorsOccuredThatShouldNotBeIngored, SkipRecordGlobal, TargetRecordExists : Boolean;
        UpdateFieldsInExistingRecordsOnly: Boolean;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        IReplacementHandler: Interface IReplacementHandler;
        IsTriggerLogInterfaceInitialized: Boolean;
        ITriggerLogGlobal: Interface ITriggerLog;
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];
        RunMode: Option FieldTransfer,InsertRecord,ModifyRecord;
        CurrTargetRecIDText, CurrValueToAssignText : Text;
}