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
        varsToCompareNotInitializedErr: Label 'The variables to compare are not initialized.', Comment = 'de-DE=Die Variablen zum Vergleichen sind nicht initialisiert.';
    begin
        if not AreVarsToCompareInitialized then
            Error(varsToCompareNotInitializedErr);

        findChangedFields(changedFields, targetRefBeforeChangeGlobal, TmpTargetRef);

        // log all changes besides the one that is assigned to the target field
        foreach fieldNo in changedFields.Keys do begin
            changedFields.Get(fieldNo, fromValueToValueList);
            addValidateTriggerLog(fieldNo, fromValueToValueList, TmpTargetRef.RecordId);
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
                addTableTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnModify, TargetRef.RecordId);
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
                addTableTriggerLogEntry(fromValueToValueList, Enum::DMTTriggerType::OnInsert, TargetRef.RecordId);
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

    local procedure addTableTriggerLogEntry(var fromValueToValueList: list of [Text]; triggerType: Enum DMTTriggerType; targetID: RecordId)
    begin
        TempTriggerLogEntryGlobal.Init();
        TempTriggerLogEntryGlobal."Entry No." := TempTriggerLogEntryGlobal.GetNextEntryNo();
        TempTriggerLogEntryGlobal."Trigger" := triggerType;
        TempTriggerLogEntryGlobal."Changed Field Cap.(Trigger)" := CopyStr(TargetFieldGlobal.Caption, 1, MaxStrLen(TempTriggerLogEntryGlobal."Changed Field Cap.(Trigger)"));
        TempTriggerLogEntryGlobal."Changed Field No. (Trigger)" := TargetFieldGlobal.Number;
        TempTriggerLogEntryGlobal."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempTriggerLogEntryGlobal."Old Value (Trigger)"));
        TempTriggerLogEntryGlobal."Value Assigned" := '';
        TempTriggerLogEntryGlobal."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempTriggerLogEntryGlobal."New Value (Trigger)"));
        TempTriggerLogEntryGlobal."Target ID" := targetID;
        TempTriggerLogEntryGlobal.Insert();
    end;

    local procedure addValidateTriggerLog(fieldNo: Integer; fromValueToValueList: list of [Text]; targetID: RecordId)
    begin
        TempTriggerLogEntryGlobal.Init();
        TempTriggerLogEntryGlobal."Entry No." := TempTriggerLogEntryGlobal.GetNextEntryNo();
        TempTriggerLogEntryGlobal."Trigger" := TempTriggerLogEntryGlobal."Trigger"::OnValidate;
        TempTriggerLogEntryGlobal."Validate Field No." := TargetFieldGlobal.Number;
        TempTriggerLogEntryGlobal."Changed Field No. (Trigger)" := fieldNo;
        // TempDMTTriggerChangesLogEntry."Changed Field Cap.(Trigger)"
        TempTriggerLogEntryGlobal."Old Value (Trigger)" := CopyStr(fromValueToValueList.Get(1), 1, MaxStrLen(TempTriggerLogEntryGlobal."Old Value (Trigger)"));
        TempTriggerLogEntryGlobal."New Value (Trigger)" := CopyStr(fromValueToValueList.Get(2), 1, MaxStrLen(TempTriggerLogEntryGlobal."New Value (Trigger)"));
        TempTriggerLogEntryGlobal."Target ID" := targetID;
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

    procedure SaveTriggerLog(Log: Codeunit DMTLog; importConfigHeader: Record DMTImportConfigHeader)
    var
        triggerLogEntry: Record DMTTriggerLogEntry;
    begin
        if TempTriggerLogEntryGlobal.IsEmpty then
            exit;
        TempTriggerLogEntryGlobal.FindSet();
        repeat
            triggerLogEntry := TempTriggerLogEntryGlobal;
            triggerLogEntry."Owner RecordID" := importConfigHeader.RecordId;
            triggerLogEntry.SourceFileName := importConfigHeader."Source File Name";
            triggerLogEntry.Insert();
        until TempTriggerLogEntryGlobal.Next() = 0;

        Log.AddTriggerLogWarnings(TempTriggerLogEntryGlobal, importConfigHeader);
    end;

    var
        TempTriggerLogEntryGlobal: Record DMTTriggerLogEntry temporary;
        targetRefBeforeChangeGlobal: RecordRef;
        SourceFieldGlobal: FieldRef;
        TargetFieldGlobal: FieldRef;
        AreVarsToCompareInitialized: Boolean;
        UseTriggerGlobal: Boolean;
}