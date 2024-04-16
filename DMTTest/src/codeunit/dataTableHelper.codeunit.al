codeunit 90027 dataTableHelper
{
    internal procedure GetFieldCaptionsAsRow(recRef: RecordRef) Row: List of [Text]
    var
        fieldIndex: Integer;
    begin
        for fieldIndex := 1 to recRef.FieldCount do
            if shouldWriteField(recRef, fieldIndex) then
                Row.Add(recRef.FieldIndex(fieldIndex).Name);
    end;

    internal procedure GetFieldValuesAsRow(recRef: RecordRef) Row: List of [Text]
    var
        fieldIndex: Integer;
    begin
        for fieldIndex := 1 to recRef.FieldCount do begin
            if shouldWriteField(recRef, fieldIndex) then
                Row.Add(formatFieldRef(recRef.FieldIndex(fieldIndex).Value));
        end;
    end;

    procedure formatFieldRef(field: FieldRef) result: Text;
    begin
        result := Format(field.Value, 0, 9);
    end;

    internal procedure shouldWriteField(var recRef: RecordRef; fieldIndex: Integer) shouldWriteField: Boolean
    begin
        case true of
            //exclude blob and media fields
            (recRef.FieldIndex(fieldIndex).Type in [FieldType::Blob, FieldType::MediaSet]):
                exit(false);
            //exclude system fields
            recRef.FieldIndex(fieldIndex).Number in [recRef.SystemCreatedAtNo, recRef.SystemCreatedByNo, recRef.SystemIdNo, recRef.SystemModifiedAtNo, recRef.SystemModifiedByNo]:
                exit(false);
            else
                exit(true);
        end;
    end;

    internal procedure AddRecordWithCaptionsToDataTable(recVariant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(recVariant);
        AddRecordWithCaptionsToDataTable(RecRef);
    end;

    local procedure AddRecordWithCaptionsToDataTable(var recRef: RecordRef)
    begin
        if CurrDataTable.Count = 0 then begin
            CurrDataTable.Add(GetFieldCaptionsAsRow(recRef));
            CurrDataTable.Add(GetFieldValuesAsRow(recRef));
        end else
            CurrDataTable.Add(GetFieldValuesAsRow(recRef));
    end;

    internal procedure WriteDataTableToFileBlob(var TempBlob: Codeunit "Temp Blob")
    var
        BigText: BigText;
        iStr: InStream;
        colNo, lastColNo : Integer;
        line: list of [Text];
        oStr: OutStream;
        TAB: Text[1];
        CRLF: Text[2];
    begin
        TAB[1] := 9;
        CRLF[1] := 13;
        CRLF[2] := 10;
        clear(TempBlob);
        TempBlob.CreateOutStream(oStr);
        // iterate through the data table and write the content to the CSV file
        foreach line in CurrDataTable do begin
            lastColNo := line.Count;
            for colNo := 1 to line.Count do
                if colNo = lastColNo then
                    oStr.WriteText(line.Get(colNo))
                else
                    OStr.WriteText(line.Get(colNo) + TAB);
            oStr.WriteText(CRLF);
        end;
        TempBlob.CreateInStream(iStr);
        BigText.Read(iStr);
    end;

    internal procedure BuildDataTable(rowIndex: Integer; colIndex: Integer; content: Text)
    var
        row: List of [Text];

    begin
        // add rows until the requested row index is reached
        while CurrDataTable.Count < rowIndex do
            CurrDataTable.Add(row);
        CurrDataTable.Get(rowIndex, row);
        // add columns until the requested column index is reached
        while row.Count < colIndex do
            row.Add('');
        // set the new content
        CurrDataTable.Get(rowIndex).Set(colIndex, content);
    end;

    var
        CurrDataTable: List of [List of [Text]];
}