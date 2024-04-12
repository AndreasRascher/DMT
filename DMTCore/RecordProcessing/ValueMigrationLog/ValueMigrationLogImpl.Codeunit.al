codeunit 91026 ValueMigrationLogImpl
{

    procedure setBeforeState(targetRefBeforeChange: RecordRef)
    var
    begin
        targetRefBeforeChangeGlobal := targetRefBeforeChange;
    end;

    procedure analyseStatesForAction(targetRefAfterChange: RecordRef; toValueNew: Text; recOperationType: enum DMTRecOperationType; validateFieldNo: Integer)
    var
        changedFields: Dictionary of [Integer/*FieldNo*/, List of [Text]/*1:FromValue 2:ToValue*/];
        fromValueToValueList: list of [Text];
        fieldNo: Integer;
        logChanges: Boolean;
    begin
        logChanges := false;
        findChangedFields(changedFields, targetRefBeforeChangeGlobal, targetRefAfterChange);
        if recOperationType = recOperationType::ValidateFieldValue then
            if (changedFields.Count = 1) and changedFields.Get(validateFieldNo, fromValueToValueList) then
                // if after validate the target field doesn't contains the assigned value
                    if toValueNew <> fromValueToValueList.Get(2) then
                    logChanges := true;
        exit;

        foreach fieldNo in changedFields.Keys do begin

        end;

        //     fRef := targetRefBeforeChange.FieldIndex(fieldIndex);
        //     beforefieldValuesDict.Add(fRef.Name, Format(fRef.Value, 0, 9));
        // ToDos: 
        // - Geänderte Felder zusammen mit der Aktion auflisten.
        // - Die Anzahl der Änderungen in der ImportKonfiguration anzeigen(Anz.Änderungen, filterbar)
        // - Beim Klick auf die Anzahl der Änderungen, die Änderungen in der Reihenfolge anzeigen
    end;

    local procedure findChangedFields(var changedFields: Dictionary of [Integer, List of [Text]]; recRefFrom: RecordRef; recRefTO: RecordRef) hasChangedFields: Boolean
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
                fromValueToValueList.AddRange(Format(fRefFrom.Value, 0, 9), Format(fRefTo.Value, 0, 9));
                changedFields.Add(fRefFrom.Number, fromValueToValueList);
            end;
        end;
        hasChangedFields := changedFields.Count > 0;
    end;

    var
        targetRefBeforeChangeGlobal: RecordRef;
}