// Test:
//  Optionswerte evaluieren
//  - Hilfstabelle mit Option Feld "1","2","3"
//  - Fehlermeldung muss kommen z.B. für 0 als Nummer

codeunit 90030 EvaluationAndTransactionTest
{
    Description = 'Test fieldref evaluation and error handling on insert and delete';
    Subtype = Test;

    [Test]
    procedure GivenValuesToEvaluate_WhenConvertingToOption_ThenAssignCorrectValueOrThrowCorrectError()
    var
        testTable: Record "TestTable";
        refHelper: Codeunit DMTRefHelper;
        recRef: RecordRef;
        fRef: FieldRef;
        valueToEvaluate: Text;
        evaluateOptionValueAsNumber: Boolean;
    begin
        recRef.GetTable(testTable);
        fRef := recRef.Field(testTable.FieldNo(OptionEvalutionTest));
        // [GIVEN] Value To Evaluate - Option Caption
        valueToEvaluate := '1';
        evaluateOptionValueAsNumber := false;
        // [WHEN] When Converting To Option by Caption 
        if refHelper.EvaluateFieldRef(fRef, valueToEvaluate, false, true) then begin
            // [THEN] Then result should be "1"
            recRef.SetTable(testTable);
            if not (testTable.OptionEvalutionTest = testTable.OptionEvalutionTest::"1") then
                Error('Option value not set correctly');
        end else begin
            Error('Evaluation failed');
        end;

        // [GIVEN] Value To Evaluate - Option Index
        valueToEvaluate := '1';
        evaluateOptionValueAsNumber := true;
        // [WHEN] When converting to option by index
        if refHelper.EvaluateFieldRef(fRef, '1', true, true) then begin
            // [THEN] Then result should be "2" (Index 1)
            recRef.SetTable(testTable);
            if testTable.OptionEvalutionTest <> 1 then
                Error('Option value not set correctly');
        end else begin
            Error('Evaluation failed');
        end;
    end;

    [Test]
    procedure GivenValuesToEvaluate_WhenConvertingToEnum_ThenAssignCorrectValueOrThrowCorrectError()
    var
        testTable: Record "TestTable";
        refHelper: Codeunit DMTRefHelper;
        recRef: RecordRef;
        fRef: FieldRef;
        valueToEvaluate: Text;
        evaluateOptionValueAsNumber: Boolean;
    begin
        recRef.GetTable(testTable);
        fRef := recRef.Field(testTable.FieldNo(EnumEvalutionTest));
        // [GIVEN] Value To Evaluate - Option Caption
        valueToEvaluate := 'PM';
        evaluateOptionValueAsNumber := false;
        // [WHEN] When Converting To Option by Caption 
        if refHelper.EvaluateFieldRef(fRef, valueToEvaluate, false, true) then begin
            recRef.SetTable(testTable);
            if not (testTable.EnumEvalutionTest = testTable.EnumEvalutionTest::PM) then
                Error('Option value not set correctly');
        end else begin
            Error('Evaluation failed');
        end;

        // [GIVEN] Value To Evaluate - Option Index
        valueToEvaluate := '1';
        evaluateOptionValueAsNumber := true;
        // [WHEN] When converting to option by index
        if refHelper.EvaluateFieldRef(fRef, '1', true, true) then begin
            // [THEN] Then result should be "2" (Index 1)
            recRef.SetTable(testTable);
            if testTable.EnumEvalutionTest <> 1 then
                Error('Option value not set correctly');
        end else begin
            Error('Evaluation failed');
        end;
    end;

    procedure GetOptionNo(Value: Text; FieldRef: FieldRef): Integer
    var
        FieldRefValueVar: Variant;
        FieldRefValueInt: Integer;
    begin
        if (Value = '') and (FieldRef.GetEnumValueName(1) = ' ') then
            exit(0);

        FieldRefValueVar := FieldRef.Value();
        FieldRefValueInt := -1;
        if Evaluate(FieldRef, Value) then begin
            FieldRefValueInt := FieldRef.Value();
            FieldRef.Value(FieldRefValueVar);
        end;

        exit(FieldRefValueInt);
    end;
}