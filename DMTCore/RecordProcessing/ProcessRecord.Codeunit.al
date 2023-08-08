codeunit 91008 DMTProcessRecord
{
    trigger OnRun()
    begin
        Start()
    end;

    procedure Start()
    begin
        Clear(CurrValueToAssignText);
        Clear(CurrTargetRecIDText);
        if RunMode = RunMode::FieldTransfer then begin
            if ProcessedFields.Count < TargetKeyFieldIDs.Count then
                ProcessKeyFields();
            if (not SkipRecord) or UpdateFieldsInExistingRecordsOnly then
                ProcessNonKeyFields();
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
        SourceField := SourceRef.Field(TempImportConfigLine."Source Field No.");
        TargetField := TmpTargetRef.Field(TempImportConfigLine."Target Field No.");
        AssignValueToFieldRef(SourceRef, TempImportConfigLine, TmpTargetRef, FieldWithTypeCorrectValueToValidate);

        if IReplacementHandler.HasReplacementsForTargetField(TargetField.Number) then begin
            FieldWithTypeCorrectValueToValidate := IReplacementHandler.GetReplacementValue(TargetField.Number);
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
                    if Format(SourceField.Value) <> Format(TargetRef_INIT.Field(TargetField.Number).Value) then
                        TargetField.Validate(FieldWithTypeCorrectValueToValidate.Value);
                end;
            ValidateSetting::AlwaysValidate:
                begin
                    TargetField.Validate(FieldWithTypeCorrectValueToValidate.Value);
                end;
        end;
    end;

    procedure AssignValueToFieldRef(SourceRecRef: RecordRef; ImportConfigLine: Record DMTImportConfigLine; TargetRecRef: RecordRef; var FieldWithTypeCorrectValueToValidate: FieldRef)
    var
        FromField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        FromField := SourceRecRef.Field(ImportConfigLine."Source Field No.");
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRecRef.Number);
        FieldWithTypeCorrectValueToValidate := TargetRecRef.Field(ImportConfigLine."Target Field No.");
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
                AssignField(Enum::DMTFieldValidationType::AssignWithoutValidate);
                ProcessedFields.Add(TempImportConfigLine.RecordId);
            end;
        until TempImportConfigLine.Next() = 0;
        SkipRecord := false;
        TargetRecordExists := ExistingRef.Get(TmpTargetRef.RecordId);
        case true of
            // Nur vorhandene Datensätze updaten. Felder aus exist. Datensatz kopieren.
            UpdateFieldsInExistingRecordsOnly:
                begin
                    if TargetRecordExists then
                        RefHelper.CopyRecordRef(ExistingRef, TmpTargetRef)
                    else
                        SkipRecord := true; // only update, do not insert record when updating records
                end;
            // Kein Insert neuer Datensätze
            ImportConfigHeader."Import Only New Records" and not UpdateFieldsInExistingRecordsOnly:
                begin
                    if TargetRecordExists then
                        SkipRecord := true;
                end;
            ImportConfigHeader."Import Only New Records":
                begin
                    if TargetRecordExists then
                        SkipRecord := true;
                end;
        end;
        CurrTargetRecIDText := Format(TmpTargetRef.RecordId);
    end;

    procedure InitFieldTransfer(_SourceRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings)
    var
        Replacement: Record DMTReplacement;
    begin
        ImportConfigHeader := DMTImportSettings.ImportConfigHeader();
        SourceRef := _SourceRef;
        UpdateFieldsInExistingRecordsOnly := DMTImportSettings.UpdateExistingRecordsOnly();
        DMTImportSettings.GetImportConfigLine(TempImportConfigLine);
        TmpTargetRef.Open(ImportConfigHeader."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := RefHelper.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        RunMode := RunMode::FieldTransfer;
        Clear(ErrorLogDict);
        Replacement.getDefaultImplementation(IReplacementHandler);
        IReplacementHandler.InitBatchProcess(ImportConfigHeader);
        IReplacementHandler.InitProcess(_SourceRef);
    end;

    procedure InitInsert()
    begin
        RunMode := RunMode::InsertRecord;
    end;

    procedure InitModify()
    begin
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

    local procedure SaveRecord() Success: Boolean
    begin
        Success := true;
        if ErrorsOccuredThatShouldNotBeIngored then
            exit(false);
        ClearLastError();
        case RunMode of
            RunMode::InsertRecord:
                begin
                    if SkipRecord then
                        exit(false);
                    Success := ChangeRecordWithPerm.InsertOrOverwriteRecFromTmp(TmpTargetRef, ImportConfigHeader."Use OnInsert Trigger");
                end;
            RunMode::ModifyRecord:
                begin
                    if SkipRecord then
                        exit(false);
                    Success := ChangeRecordWithPerm.ModifyRecFromTmp(TmpTargetRef, ImportConfigHeader."Use OnInsert Trigger");
                end;
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
            Log.AddErrorByImportConfigLineEntry(SourceRef.RecordId, ImportConfigHeader, TempImportConfigLine, ErrorItem);
        end;
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
            (RunMode in [RunMode::ModifyRecord, RunMode::InsertRecord]) and SkipRecord:
                exit(ResultType::Ignored);
            (RunMode in [RunMode::FieldTransfer, RunMode::ModifyRecord, RunMode::InsertRecord]) and
            not ErrorsOccuredThatShouldNotBeIngored and not SkipRecord:
                exit(ResultType::ChangesApplied);
            else
                Error('unhandled case');
        end;
    end;


    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        ChangeRecordWithPerm: Codeunit DMTChangeRecordWithPerm;
        RefHelper: Codeunit DMTRefHelper;
        CurrFieldToProcess: RecordId;
        SourceRef, TargetRef_INIT, TmpTargetRef : RecordRef;
        CurrValueToAssign: FieldRef;
        CurrValueToAssignText, CurrTargetRecIDText : Text;
        IReplacementHandler: Interface IReplacementHandler;
        CurrValueToAssign_IsInitialized: Boolean;
        SkipRecord, TargetRecordExists, ErrorsOccuredThatShouldNotBeIngored : Boolean;
        UpdateFieldsInExistingRecordsOnly: Boolean;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];
        RunMode: Option FieldTransfer,InsertRecord,ModifyRecord;
}