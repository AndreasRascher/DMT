codeunit 90027 DMTDataTableHelper
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
                Row.Add(formatFieldRef(recRef.FieldIndex(fieldIndex)));
        end;
    end;

    procedure formatFieldRef(field: FieldRef) result: Text;
    var
        BooleanValue: Boolean;
    begin
        case field.Type of
            fieldtype::Boolean:
                begin
                    BooleanValue := field.Value;
                    if BooleanValue then
                        exit('1');
                    exit('0');
                end;
            else
                result := Format(field.Value, 0, 9);
        end;
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

    internal procedure WriteDataTableToExcelBuffer(var ExcelBufferFilled: Record "Excel Buffer" temporary)
    var
        tempExcelBuffer: Record "Excel Buffer" temporary;
        currColNo, currRowNo : Integer;
        line: list of [Text];
    begin
        //TODO Sample Data in Excel
        // No.	Name	Payment Terms Code	Payment Terms Id
        // 111111	Test	1M(8T)	{00000000-0000-0000-0000-000000000000}

        // iterate through the data table and write the content to excel buffer file
        for currRowNo := 1 to CurrDataTable.Count do begin
            line := CurrDataTable.Get(currRowNo);
            for currColNo := 1 to line.Count do begin
                tempExcelBuffer.Init();
                tempExcelBuffer.Validate("Row No.", currRowNo);
                tempExcelBuffer.Validate("Column No.", currColNo);
                tempExcelBuffer.Validate("Cell Value as Text", line.Get(currColNo));
                tempExcelBuffer.Insert();
            end;
        end;
        ExcelBufferFilled.Copy(tempExcelBuffer, true);
    end;

    internal procedure setDataTableField(rowIndex: Integer; colIndex: Integer; content: Text)
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

    internal procedure SetLine(rowIndex: Integer; content1: Text; content2: Text; content3: Text)
    var
        line: List of [Text];
    begin
        line.AddRange(content1, content2, content3);
        SetLine(rowIndex, line);
    end;

    internal procedure SetLine(rowIndex: Integer; Line: List of [Text])
    var
        cellValue: Text;
        colIndex: Integer;
    begin
        for colIndex := 1 to Line.Count do begin
            cellValue := Line.Get(colIndex);
            setDataTableField(rowIndex, colIndex, cellValue);
        end;
    end;

    var
        CurrDataTable: List of [List of [Text]];
}