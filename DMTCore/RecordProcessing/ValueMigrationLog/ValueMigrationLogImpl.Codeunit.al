codeunit 91026 ValueMigrationLogImpl implements IValueMigrationLog
{
    procedure Activate()
    begin
        isActiveGlobal := true;
    end;

    procedure IsActive(): Boolean
    begin
        exit(isActiveGlobal);
    end;

    procedure setBeforeState(targetRefBeforeChange: RecordRef)
    var
    begin
        targetRefBeforeChangeGlobal := targetRefBeforeChange;
    end;

    procedure setAfterState(targetRefAfterChange: RecordRef)
    begin
        targetRefAfterChangeGlobal := targetRefAfterChange;
    end;

    procedure analyseStatesForAction(recOperationType: enum DMTRecOperationType; fieldNo: Integer)
    var
        fRef: FieldRef;
        changesDict: Dictionary of [Integer, Text];
        fieldIndex: Integer;
    begin
        // nothing changed
        if Format(targetRefBeforeChangeGlobal) = Format(targetRefAfterChangeGlobal) then
            exit;
        for fieldIndex := 1 to targetRefBeforeChangeGlobal.FieldCount do begin
            if targetRefBeforeChangeGlobal.FieldIndex(fieldIndex).Value <> targetRefAfterChangeGlobal.FieldIndex(fieldIndex).Value then begin
                fRef := targetRefBeforeChangeGlobal.FieldIndex(fieldIndex);
                changesDict.Add(fRef.Number, Format(fRef.Value, 0, 9));
            end;
            //     fRef := targetRefBeforeChange.FieldIndex(fieldIndex);
            //     beforefieldValuesDict.Add(fRef.Name, Format(fRef.Value, 0, 9));
            ToDos: 
            - Geänderte Felder zusammen mit der Aktion auflisten.
            - Die Anzahl der Änderungen in der ImportKonfiguration anzeigen(Anz.Änderungen, filterbar)
            - Beim Klick auf die Anzahl der Änderungen, die Änderungen in der Reihenfolge anzeigen
        end;
    end;

    procedure showChangesInOrder(forFieldNo: Integer)
    begin

    end;

    var
        isActiveGlobal: Boolean;
        targetRefBeforeChangeGlobal, targetRefAfterChangeGlobal : RecordRef
}