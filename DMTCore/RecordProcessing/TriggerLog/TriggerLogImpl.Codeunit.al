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
        fieldNo: Integer;
        logChanges: Boolean;
        varsToCompareNotInitializedErr: Label 'The variables to compare are not initialized.', Comment = 'de-DE=Die Variablen zum Vergleichen sind nicht initialisiert.';
    begin
        logChanges := false;
        if not AreVarsToCompareInitialized then
            Error(varsToCompareNotInitializedErr);

        findChangedFields(changedFields, targetRefBeforeChangeGlobal, TmpTargetRef);
        // if after validate the target field doesn't contains the assigned value
        if (changedFields.Count = 1) and changedFields.Get(TargetFieldGlobal.Number, fromValueToValueList) then begin
            if formatField(SourceFieldGlobal) <> fromValueToValueList.Get(2) then
                logChanges := true;
        end;
        // if more than one field has changed
        if changedFields.Count > 1 then
            logChanges := true;

        // log all changes besides the one that is assigned to the target field
        if logChanges then begin
            foreach fieldNo in changedFields.Keys do begin
                changedFields.Get(fieldNo, fromValueToValueList);
                if fieldNo <> TargetFieldGlobal.Number then
                    addTableTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnValidate);
            end;
            addValidateTriggerLog(fieldNo, fromValueToValueList);
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
        fieldNo: Integer;
    begin
        if findChangedFields(changedFields, targetRefBeforeChangeGlobal, TargetRef) then begin
            foreach fieldNo in changedFields.Keys do begin
                changedFields.Get(fieldNo, fromValueToValueList);
                addTableTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnModify);
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
        fieldNo: Integer;
    begin
        if findChangedFields(changedFields, targetRefBeforeChangeGlobal, TargetRef) then begin
            foreach fieldNo in changedFields.Keys do begin
                changedFields.Get(fieldNo, fromValueToValueList);
                addTableTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnModify);
            end;
        end;
    end;

    internal procedure findChangedFields(var changedFields: Dictionary of [Integer, List of [Text]]; recRefFrom: RecordRef; recRefTO: RecordRef) hasChangedFields: Boolean
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
                    fromValueToValueList.AddRange(formatField(fRefFrom), formatField(fRefTo));
                    changedFields.Add(fRefFrom.Number, fromValueToValueList);
                end;
        end;
        hasChangedFields := changedFields.Count > 0;
    end;

    local procedure formatField(var SourceField: FieldRef) result: Text
    begin
        result := Format(SourceField.Value, 0, 9);
    end;

    local procedure addTableTriggerLogEntry(var fromValueToValueList: list of [Text]; triggerType: Enum DMTTriggerType)
    begin
        TempDMTTriggerChangesLogEntry.Init();
        TempDMTTriggerChangesLogEntry."Entry No." := TempDMTTriggerChangesLogEntry.GetNextEntryNo();
        TempDMTTriggerChangesLogEntry."Trigger" := triggerType;
        TempDMTTriggerChangesLogEntry."Changed Field Cap.(Trigger)" := CopyStr(TargetFieldGlobal.Caption, 1, MaxStrLen(TempDMTTriggerChangesLogEntry."Changed Field Cap.(Trigger)"));
        TempDMTTriggerChangesLogEntry."Changed Field No. (Trigger)" := TargetFieldGlobal.Number;
        TempDMTTriggerChangesLogEntry."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."Old Value (Trigger)"));
        TempDMTTriggerChangesLogEntry."Value Assigned" := '';
        TempDMTTriggerChangesLogEntry."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."New Value (Trigger)"));
        TempDMTTriggerChangesLogEntry.Insert();
    end;

    local procedure addValidateTriggerLog(fieldNo: Integer; fromValueToValueList: list of [Text])
    begin
        TempDMTTriggerChangesLogEntry.Init();
        TempDMTTriggerChangesLogEntry."Entry No." := TempDMTTriggerChangesLogEntry.GetNextEntryNo();
        TempDMTTriggerChangesLogEntry."Trigger" := TempDMTTriggerChangesLogEntry."Trigger"::OnValidate;
        TempDMTTriggerChangesLogEntry."Validate Field No." := TargetFieldGlobal.Number;
        TempDMTTriggerChangesLogEntry."Changed Field No. (Trigger)" := fieldNo;
        // TempDMTTriggerChangesLogEntry."Changed Field Cap.(Trigger)"
        TempDMTTriggerChangesLogEntry."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."Old Value (Trigger)"));
        TempDMTTriggerChangesLogEntry."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."New Value (Trigger)"));
        TempDMTTriggerChangesLogEntry.Insert();
    end;

    var
        TempDMTTriggerChangesLogEntry: Record DMTTriggerLogEntry temporary;
        targetRefBeforeChangeGlobal: RecordRef;
        SourceFieldGlobal: FieldRef;
        TargetFieldGlobal: FieldRef;
        AreVarsToCompareInitialized: Boolean;
        UseTriggerGlobal: Boolean;

    procedure DeleteExistingLogFor(BufferRef: RecordRef);
    var
        triggerLogEntry: Record DMTTriggerLogEntry;
    begin
        triggerLogEntry.SetRange("Source ID", BufferRef.RecordId);
        if not triggerLogEntry.IsEmpty then
            triggerLogEntry.DeleteAll();
    end;
}