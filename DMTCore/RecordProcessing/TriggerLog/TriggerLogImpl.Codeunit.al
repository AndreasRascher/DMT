codeunit 91026 DMTTriggerLogImpl implements ITriggerLog
{

    internal procedure InitBeforeValidate(SourceField: FieldRef; TargetField: FieldRef; TmpTargetRef: RecordRef)
    begin
        targetRefBeforeChangeGlobal := TmpTargetRef;
        TargetFieldGlobal := TargetField;
        SourceFieldGlobal := SourceField;
        AreVarsToCompareInitialized := true;
    end;

    internal procedure CheckAfterValidate(TmpTargetRef: RecordRef)
    var
        changedFields: Dictionary of [Integer/*FieldNo*/, List of [Text]/*1:FromValue 2:ToValue*/];
        fromValueToValueList: list of [Text];
        logChanges: Boolean;
        varsToCompareNotInitializedErr: Label 'The variables to compare are not initialized.', Comment = 'de-DE=Die Variablen zum Vergleichen sind nicht initialisiert.';
    begin
        logChanges := false;
        if not AreVarsToCompareInitialized then
            Error(varsToCompareNotInitializedErr);

        findChangedFields(changedFields, targetRefBeforeChangeGlobal, TmpTargetRef);
        if (changedFields.Count = 1) and changedFields.Get(TargetFieldGlobal.Number, fromValueToValueList) then
            // if after validate the target field doesn't contains the assigned value
            if formatField(SourceFieldGlobal) <> fromValueToValueList.Get(2) then
                logChanges := true;
        exit;

        if logChanges then begin
            TempDMTTriggerChangesLogEntry.Init();
            TempDMTTriggerChangesLogEntry."Entry No." := TempDMTTriggerChangesLogEntry.GetNextEntryNo();
            TempDMTTriggerChangesLogEntry."Trigger" := TempDMTTriggerChangesLogEntry."Trigger"::OnValidate;
            TempDMTTriggerChangesLogEntry."Changed Field Cap.(Trigger)" := CopyStr(TargetFieldGlobal.Caption, 1, MaxStrLen(TempDMTTriggerChangesLogEntry."Changed Field Cap.(Trigger)"));
            TempDMTTriggerChangesLogEntry."Changed Field No. (Trigger)" := TargetFieldGlobal.Number;
            TempDMTTriggerChangesLogEntry."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."Old Value (Trigger)"));
            TempDMTTriggerChangesLogEntry."Value Assigned" := CopyStr(formatField(TargetFieldGlobal), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."Value Assigned"));
            TempDMTTriggerChangesLogEntry."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempDMTTriggerChangesLogEntry."New Value (Trigger)"));
            TempDMTTriggerChangesLogEntry.Insert();
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
                addTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnModify);
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
                addTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnModify);
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
            if recRefFrom.FieldIndex(fieldIndex).Value <> recRefTO.FieldIndex(fieldIndex).Value then begin
                fRefFrom := recRefFrom.FieldIndex(fieldIndex);
                fRefTo := recRefTO.FieldIndex(fieldIndex);
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

    local procedure addTriggerLogEntry(var fromValueToValueList: list of [Text]; triggerType: Enum DMTTriggerType)
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