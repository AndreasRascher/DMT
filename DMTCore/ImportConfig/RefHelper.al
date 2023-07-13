codeunit 91007 DMTRefHelper
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
        FieldRefSource: FieldRef;
        FieldRefTarget: FieldRef;
        i: Integer;
    begin
        for i := 1 to RecRefSource.FieldCount do begin
            if RecRefTarget.FieldIndex(i).Class = FieldClass::Normal then begin
                FieldRefSource := RecRefSource.FieldIndex(i);
                if FieldRefSource.Type in [FieldType::Blob] then
                    FieldRefSource.CalcField();
                FieldRefTarget := RecRefTarget.FieldIndex(i);
                FieldRefTarget.Value := FieldRefSource.Value;
            end;
        end;
    end;

}