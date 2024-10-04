codeunit 91026 DMTTriggerLogImpl implements ITriggerLog
{

    internal procedure InitBeforeValidate(SourceField: FieldRef; TargetField: FieldRef; TmpTargetRef: RecordRef)
    begin
        targetRefBeforeChangeGlobal := TmpTargetRef.Duplicate();
        TargetFieldGlobal := TargetField;
        SourceFieldGlobal := SourceField;
        AreVarsToCompareInitialized := true;
    end;

    internal procedure CheckAfterValidate(TmpTargetRef: RecordRef)
    var
        changedFields: Dictionary of [Integer/*FieldNo*/, List of [Text]/*1:FromValue 2:ToValue*/];
        fromValueToValueList: list of [Text];
        changedFieldNo: Integer;
        varsToCompareNotInitializedErr: Label 'The variables to compare are not initialized.', Comment = 'de-DE=Die Variablen zum Vergleichen sind nicht initialisiert.';
    begin
        if not AreVarsToCompareInitialized then
            Error(varsToCompareNotInitializedErr);

        findChangedFields(changedFields, targetRefBeforeChangeGlobal, TmpTargetRef);

        // log all changes besides the one that is assigned to the target field
        // 1. add the actual validated field
        if changedFields.Get(TargetFieldGlobal.Number, fromValueToValueList) then begin
            addValidateTriggerLog(TargetFieldGlobal.Number, TargetFieldGlobal.Number, fromValueToValueList, SourceFieldGlobal, TmpTargetRef.RecordId);
            changedFields.Remove(TargetFieldGlobal.Number);
        end;
        // 2. add all other changes
        foreach changedFieldNo in changedFields.Keys do begin
            changedFields.Get(changedFieldNo, fromValueToValueList);
            addValidateTriggerLog(TargetFieldGlobal.Number, changedFieldNo, fromValueToValueList, SourceFieldGlobal, TmpTargetRef.RecordId);
        end;
    end;

    internal procedure InitBeforeModify(TargetRef: RecordRef; UseTrigger: Boolean)
    begin
        UseTriggerGlobal := UseTrigger;
        targetRefBeforeChangeGlobal := TargetRef;
        AreVarsToCompareInitialized := true;
    end;

    internal procedure CheckAfterOnModiy(TargetRef: RecordRef)
    var
        changedFields: Dictionary of [Integer/*FieldNo*/, List of [Text]/*1:FromValue 2:ToValue*/];
        fromValueToValueList: list of [Text];
        changedFieldNo: Integer;
    begin
        if findChangedFields(changedFields, targetRefBeforeChangeGlobal, TargetRef) then begin
            foreach changedFieldNo in changedFields.Keys do begin
                changedFields.Get(changedFieldNo, fromValueToValueList);
                addTableTriggerLogEntry(changedFieldNo, fromValueToValueList, Enum::DMTTriggerType::OnModify, TargetRef.RecordId);
            end;
        end;
    end;

    internal procedure InitBeforeInsert(TargetRef: RecordRef; UseTrigger: Boolean)
    begin
        UseTriggerGlobal := UseTrigger;
        targetRefBeforeChangeGlobal := TargetRef;
        AreVarsToCompareInitialized := true;
    end;

    internal procedure CheckAfterOnInsert(TargetRef: RecordRef)
    var
        changedFields: Dictionary of [Integer/*FieldNo*/, List of [Text]/*1:FromValue 2:ToValue*/];
        fromValueToValueList: list of [Text];
        changedFieldNo: Integer;
    begin
        //ToDo: FiBu Einrichtung erzeugt zu viele Zeilen
        if findChangedFields(changedFields, targetRefBeforeChangeGlobal, TargetRef) then begin
            foreach changedFieldNo in changedFields.Keys do begin
                changedFields.Get(changedFieldNo, fromValueToValueList);
                addTableTriggerLogEntry(changedFieldNo, fromValueToValueList, Enum::DMTTriggerType::OnInsert, TargetRef.RecordId);
            end;
        end;
    end;

    internal procedure findChangedFields(var changedFields: Dictionary of [Integer, List of [Text/*1:Value from 2:Value to*/]]; recRefFrom: RecordRef; recRefTO: RecordRef) hasChangedFields: Boolean
    var
        fRefFrom, fRefTo : FieldRef;
        fromValueToValueList: list of [Text];
        fieldIndex: Integer;
    begin
        Clear(changedFields);
        for fieldIndex := 1 to recRefFrom.FieldCount do begin
            // ignore system fields
            if not (recRefTO.FieldIndex(fieldIndex).Number in [recRefTO.SystemCreatedAtNo, recRefTO.SystemCreatedByNo,
                                                               recRefTO.SystemModifiedByNo, recRefTO.SystemModifiedAtNo,
                                                               recRefTO.SystemIdNo]) then
                if recRefFrom.FieldIndex(fieldIndex).Value <> recRefTO.FieldIndex(fieldIndex).Value then begin
                    fRefFrom := recRefFrom.FieldIndex(fieldIndex);
                    fRefTo := recRefTO.FieldIndex(fieldIndex);
                    Clear(fromValueToValueList);
                    fromValueToValueList.AddRange(formatField250(fRefFrom), formatField250(fRefTo));
                    changedFields.Add(fRefFrom.Number, fromValueToValueList);
                end;
        end;
        hasChangedFields := changedFields.Count > 0;
    end;

    local procedure formatField250(var SourceField: FieldRef) result: Text[250]
    begin
        result := CopyStr(Format(SourceField.Value, 0, 9), 1, 250);
    end;

    local procedure addTableTriggerLogEntry(changedFieldNo: Integer; var fromValueToValueList: list of [Text]; triggerType: Enum DMTTriggerType; targetID: RecordId)
    begin
        TempTriggerLogEntryGlobal.Init();
        TempTriggerLogEntryGlobal."Entry No." := TempTriggerLogEntryGlobal.GetNextEntryNo();
        TempTriggerLogEntryGlobal."Trigger" := triggerType;
        TempTriggerLogEntryGlobal."Target ID" := targetID;

        TempTriggerLogEntryGlobal."Changed Field Cap.(Trigger)" := getField(targetID.TableNo, changedFieldNo)."Field Caption";
        TempTriggerLogEntryGlobal."Changed Field No. (Trigger)" := changedFieldNo;

        TempTriggerLogEntryGlobal."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempTriggerLogEntryGlobal."Old Value (Trigger)"));
        TempTriggerLogEntryGlobal."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempTriggerLogEntryGlobal."New Value (Trigger)"));
        TempTriggerLogEntryGlobal.Insert();
    end;

    local procedure addValidateTriggerLog(validateFieldNo: Integer; changedFieldNo: Integer; fromValueToValueList: list of [Text]; sourceField: FieldRef; targetID: RecordId)
    begin
        TempTriggerLogEntryGlobal.Init();
        TempTriggerLogEntryGlobal."Entry No." := TempTriggerLogEntryGlobal.GetNextEntryNo();
        TempTriggerLogEntryGlobal."Trigger" := TempTriggerLogEntryGlobal."Trigger"::OnValidate;
        TempTriggerLogEntryGlobal."Target ID" := targetID;

        TempTriggerLogEntryGlobal."Validate Field No." := validateFieldNo;
        TempTriggerLogEntryGlobal."Validate Caption" := getField(targetID.TableNo, validateFieldNo)."Field Caption";

        TempTriggerLogEntryGlobal."Changed Field No. (Trigger)" := changedFieldNo;
        TempTriggerLogEntryGlobal."Changed Field Cap.(Trigger)" := getField(targetID.TableNo, changedFieldNo)."Field Caption";

        TempTriggerLogEntryGlobal."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempTriggerLogEntryGlobal."Old Value (Trigger)"));
        TempTriggerLogEntryGlobal."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempTriggerLogEntryGlobal."New Value (Trigger)"));
        // we only know the value that is validated, not what happens in the trigger
        if validateFieldNo = changedFieldNo then
            TempTriggerLogEntryGlobal."Value Assigned" := CopyStr(formatField250(sourceField), 1, MaxStrLen(TempTriggerLogEntryGlobal."Value Assigned"));
        TempTriggerLogEntryGlobal.Insert();
    end;

    local procedure addAssignemtTriggerLog(sourceField: FieldRef; targetField: FieldRef; targetID: RecordId)
    begin
        TempTriggerLogEntryGlobal.Init();
        TempTriggerLogEntryGlobal."Entry No." := TempTriggerLogEntryGlobal.GetNextEntryNo();
        TempTriggerLogEntryGlobal."Trigger" := TempTriggerLogEntryGlobal."Trigger"::Assignment;
        TempTriggerLogEntryGlobal."Target ID" := targetID;

        TempTriggerLogEntryGlobal."Changed Field No. (Trigger)" := targetField.Number;
        TempTriggerLogEntryGlobal."Changed Field Cap.(Trigger)" := getField(targetID.TableNo, targetField.Number)."Field Caption";

        TempTriggerLogEntryGlobal."Old Value (Trigger)" := '';
        TempTriggerLogEntryGlobal."New Value (Trigger)" := formatField250(targetField);
        TempTriggerLogEntryGlobal."Value Assigned" := formatField250(sourceField);
        TempTriggerLogEntryGlobal.Insert();
    end;

    procedure DeleteExistingLogFor(BufferRef: RecordRef);
    var
        triggerLogEntry: Record DMTTriggerLogEntry;
    begin
        triggerLogEntry.SetRange("Source ID", BufferRef.RecordId);
        if not triggerLogEntry.IsEmpty then
            triggerLogEntry.DeleteAll();
    end;

    procedure SaveTriggerLog(Log: Codeunit DMTLog; importConfigHeader: Record DMTImportConfigHeader; SourceRef: RecordRef)
    var
        triggerLogEntry: Record DMTTriggerLogEntry;
        nextEntryNo: Integer;
    begin
        if TempTriggerLogEntryGlobal.IsEmpty then
            exit;
        //KeepOnlyFieldsChangedMoreThanOnce(); //Unklar, bei Name -> Suchname wird der Eintrag gelöscht
        if TempTriggerLogEntryGlobal.FindSet() then begin
            nextEntryNo := triggerLogEntry.GetNextEntryNo();
            repeat
                triggerLogEntry := TempTriggerLogEntryGlobal;
                triggerLogEntry."Entry No." := nextEntryNo;
                nextEntryNo += 1;
                //Filter information
                triggerLogEntry."Owner RecordID" := importConfigHeader.RecordId;
                triggerLogEntry.SourceFileName := importConfigHeader."Source File Name";
                triggerLogEntry."Source ID" := SourceRef.RecordId;

                triggerLogEntry.Insert();
            until TempTriggerLogEntryGlobal.Next() = 0;
        end;
        if not TempTriggerLogEntryGlobal.IsEmpty then
            Log.AddTriggerLogWarnings(TempTriggerLogEntryGlobal, importConfigHeader);
    end;

    procedure getField(tableNo: Integer; fieldNo: Integer) field: Record field;
    begin
        field.Get(tableNo, fieldNo);
    end;

    procedure LogAssignment(SourceField: FieldRef; TargetField: FieldRef; TmpTargetRef: RecordRef)
    begin
        addAssignemtTriggerLog(SourceField, TargetField, TmpTargetRef.RecordId);
    end;

    procedure KeepOnlyFieldsChangedMoreThanOnce() found: Boolean
    var
        fieldChangeCount: Dictionary of [Integer, Integer];
        fieldNo: Integer;
    begin
        if not TempTriggerLogEntryGlobal.FindSet() then
            exit(false);
        repeat
            if fieldChangeCount.ContainsKey(TempTriggerLogEntryGlobal."Changed Field No. (Trigger)") then
                fieldChangeCount.Set(TempTriggerLogEntryGlobal."Changed Field No. (Trigger)", fieldChangeCount.Get(TempTriggerLogEntryGlobal."Changed Field No. (Trigger)") + 1)
            else
                fieldChangeCount.Add(TempTriggerLogEntryGlobal."Changed Field No. (Trigger)", 1);
        until TempTriggerLogEntryGlobal.Next() = 0;

        foreach fieldNo in fieldChangeCount.Keys do begin
            if fieldChangeCount.Get(fieldNo) < 2 then begin
                TempTriggerLogEntryGlobal.SetRange("Changed Field No. (Trigger)", fieldNo);
                TempTriggerLogEntryGlobal.DeleteAll();
            end;
        end;
        TempTriggerLogEntryGlobal.Reset();
    end;

    var
        TempTriggerLogEntryGlobal: Record DMTTriggerLogEntry temporary;
        targetRefBeforeChangeGlobal: RecordRef;
        SourceFieldGlobal: FieldRef;
        TargetFieldGlobal: FieldRef;
        AreVarsToCompareInitialized: Boolean;
        UseTriggerGlobal: Boolean;

}