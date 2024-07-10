codeunit 50053 DMTRefHelper
{
    procedure GetListOfKeyFieldIDs(var RecRef: RecordRef) KeyFieldIDsList: List of [Integer];
    var
        FieldRef: FieldRef;
        _KeyIndex: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for _KeyIndex := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(_KeyIndex);
            KeyFieldIDsList.Add(FieldRef.Number);
        end;
    end;

    procedure CopyRecordRef(var RecRefSource: RecordRef; var RecRefTarget: RecordRef)
    var
        TempBlob: Codeunit "Temp Blob";
        FieldRefSource: FieldRef;
        FieldRefTarget: FieldRef;
        i: Integer;
    begin
        for i := 1 to RecRefSource.FieldCount do begin
            if RecRefTarget.FieldIndex(i).Class = FieldClass::Normal then begin
                FieldRefSource := RecRefSource.FieldIndex(i);
                if FieldRefSource.Type in [FieldType::Blob] then begin
                    TempBlob.FromFieldRef(FieldRefSource);
                    if not TempBlob.HasValue() then  // keep unsaved blob content
                        FieldRefSource.CalcField();
                end;
                FieldRefTarget := RecRefTarget.FieldIndex(i);
                FieldRefTarget.Value := FieldRefSource.Value;
            end;
        end;
    end;

    internal procedure IsTableEmpty(BufferTableID: Integer): Boolean
    var
        recRef: RecordRef;
    begin
        recRef.Open(BufferTableID);
        exit(recRef.IsEmpty);
    end;

    procedure EvaluateFieldRef(var FieldRef_TO: FieldRef; FromText: Text; EvaluateOptionValueAsNumber: Boolean; ThrowError: Boolean): Boolean
    var
        TempBlob: Record "Tenant Media" temporary;
        tempDummyVendor: Record Vendor temporary;
        _DateFormula: DateFormula;
        _RecordID: RecordId;
        _BigInteger: BigInteger;
        _Boolean: Boolean;
        _Date: Date;
        _DateTime: DateTime;
        _Decimal: Decimal;
        _Integer: Integer;
        _Guid: Guid;
        NoOfOptions: Integer;
        OptionIndex: Integer;
        InvalidValueForTypeErr: Label '"%1" is not a valid %2 value.', Comment = 'de-DE="%1" ist kein gültiger %2 Wert';
        _OutStream: OutStream;
        _InStream: InStream;
        OptionElement: Text;
        _Time: Time;
    begin
        if FromText = '' then
            case UpperCase(Format(FieldRef_TO.Type)) of
                'BIGINTEGER', 'INTEGER', 'DECIMAL':
                    begin
                        FromText := '0';
                        exit(true);
                    end;
            end;
        case UpperCase(Format(FieldRef_TO.Type)) of
            'INTEGER':
                begin
                    case true of
                        Evaluate(_Integer, FromText, 9):
                            begin
                                FieldRef_TO.Value := _Integer;
                                exit(true);
                            end;
                        else
                            if ThrowError then
                                Evaluate(_Integer, FromText, 9)
                    end;
                end;
            'BIGINTEGER':
                if Evaluate(_BigInteger, FromText, 9) then begin
                    FieldRef_TO.Value := _BigInteger;
                    exit(true);
                end else
                    if ThrowError then
                        Evaluate(_BigInteger, FromText, 9);
            'TEXT', 'TABLEFILTER':
                begin
                    FieldRef_TO.Value := CopyStr(FromText, 1, FieldRef_TO.Length);
                    exit(true);
                end;
            'CODE':
                begin
                    FieldRef_TO.Value := UpperCase(CopyStr(FromText, 1, FieldRef_TO.Length));
                    exit(true);
                end;
            'DECIMAL':
                if Evaluate(_Decimal, FromText, 9) then begin
                    FieldRef_TO.Value := _Decimal;
                    exit(true);
                end else
                    if ThrowError then
                        Evaluate(_Decimal, FromText, 9);
            'BOOLEAN':
                case true of
                    Evaluate(_Boolean, FromText, 9):
                        begin
                            FieldRef_TO.Value := _Boolean;
                            exit(true);
                        end;
                    // Needed for Evaluate from Fixed Value Test (true,false,ja,nein), xml-format only accepts 0 or 1   
                    Evaluate(_Boolean, FromText):
                        begin
                            FieldRef_TO.Value := _Boolean;
                            exit(true);
                        end
                    else
                        if ThrowError then
                            Evaluate(_Boolean, FromText, 9);
                end;

            'RECORDID':
                if Evaluate(_RecordID, FromText) then begin
                    FieldRef_TO.Value := _RecordID;
                    exit(true);
                end else
                    if ThrowError then
                        Error(InvalidValueForTypeErr, FromText, FieldRef_TO.Type);
            'OPTION':
                if EvaluateOptionValueAsNumber then begin
                    //Optionswert wird als Zahl übergeben
                    if Evaluate(_Integer, FromText) then begin
                        FieldRef_TO.Value := _Integer;
                        exit(true);
                    end else
                        if ThrowError then
                            Evaluate(_RecordID, FromText);
                end else begin
                    //Optionswert wird als Text übergeben
                    NoOfOptions := StrLen(FieldRef_TO.OptionCaption) - StrLen(DelChr(FieldRef_TO.OptionCaption, '=', ',')); // zero based
                    for OptionIndex := 0 to NoOfOptions do begin
                        OptionElement := SelectStr(OptionIndex + 1, FieldRef_TO.OptionCaption);
                        if OptionElement.ToLower() = FromText.ToLower() then begin
                            FieldRef_TO.Value := OptionIndex;
                            exit(true);
                        end;
                    end;
                end;
            'DATE':
                begin
                    //ApplicationMgt.MakeDateText(FromText);
                    if Evaluate(_Date, FromText, 9) then begin
                        FieldRef_TO.Value := _Date;
                        exit(true);
                    end else
                        if ThrowError then
                            Evaluate(_Date, FromText, 9);
                end;

            'DATETIME':
                begin
                    //ApplicationMgt.MakeDateTimeText(FromText);
                    if Evaluate(_DateTime, FromText, 9) then begin
                        FieldRef_TO.Value := _DateTime;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_DateTime, FromText, 9);
                end;
            'TIME':
                begin
                    if Evaluate(_Time, FromText, 9) then begin
                        FieldRef_TO.Value := _Time;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_Time, FromText, 9);
                end;
            'BLOB':
                begin
                    TempBlob.DeleteAll();
                    TempBlob.Content.CreateOutStream(_OutStream);
                    _OutStream.WriteText(FromText);
                    TempBlob.Insert();
                    FieldRef_TO.Value(TempBlob.Content);
                    exit(true);
                end;
            'DATEFORMULA':
                begin
                    if Evaluate(_DateFormula, FromText, 9) then begin
                        FieldRef_TO.Value := _DateFormula;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_DateFormula, FromText, 9);
                end;
            'GUID':
                begin
                    if FromText = '' then begin
                        Clear(_Guid);
                        FieldRef_TO.Value := _Guid;
                        exit(true);
                    end;
                    if Evaluate(_Guid, FromText, 9) then begin
                        FieldRef_TO.Value := _Guid;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_Guid, FromText, 9);
                end;
            'MEDIA':
                begin
                    if FromText = '' then begin
                        Clear(_Guid);
                        FieldRef_TO.Value(_Guid);
                        exit(true);
                    end;
                    TempBlob.DeleteAll();
                    TempBlob.Content.CreateOutStream(_OutStream);
                    _OutStream.WriteText(FromText);
                    TempBlob.Insert();
                    TempBlob.CalcFields(Content);
                    TempBlob.Content.CreateInStream(_InStream);
                    _Guid := tempDummyVendor.Image.ImportStream(_InStream, '');
                    FieldRef_TO.Value(_Guid);
                    exit(true);
                end;
            else
                Message('Funktion "EvaluateFieldRef" - nicht behandelter Datentyp %1', Format(FieldRef_TO.Type));
        end;  // end_CASE
    end;

    internal procedure AssignFixedValueToFieldRef(var ToFieldRef: FieldRef; FixedValue: Text)
    var
        RefHelper: Codeunit DMTRefHelper;
    begin
        if not RefHelper.EvaluateFieldRef(ToFieldRef, FixedValue, false, false) then
            Error('Invalid Fixed Value %1', FixedValue);
    end;

}