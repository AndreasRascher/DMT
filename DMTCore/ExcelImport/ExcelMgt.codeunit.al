codeunit 91004 DMTExcelMgt
{

    internal procedure ImportFile()
    begin
        ReadExcelSheet();
    end;

    internal procedure GetHeaderLine() HeaderLine: Dictionary of [Text, Integer];
    begin
        HeaderLine := ReadHeaderLine(1, tempExcelBufferGlobal);
    end;

    internal procedure ReadExcelSheet()
    var
        TempBlob: Codeunit "Temp Blob";
        inStr: InStream;
        selectAnImportFileLbl: Label 'Select an import file';
        SheetName, FileName : Text;
    begin
        TempBlob.CreateInStream(inStr);
        if not UploadIntoStream(selectAnImportFileLbl, '', format(enum::DMTFileFilter::Excel), FileName, inStr) then
            exit;
        SheetName := tempExcelBufferGlobal.SelectSheetsNameStream(inStr);
        tempExcelBufferGlobal.OpenBookStream(inStr, SheetName);
        tempExcelBufferGlobal.ReadSheet();
    end;

    // local procedure ImportFileToBuffer()
    // var
    //     xl_LineNo: Integer;
    // begin
    //     LastExcelLineNo := GetLastRowNo_ExcelSheet(tempExcelBuffer_Leads);
    //     LastExcelColNo := GetLastColumnNo_ExcelSheet(tempExcelBuffer_Leads);
    //     for xl_LineNo := 2 to LastExcelLineNo do
    //         ImportLine(xl_LineNo);
    // end;

    local procedure ReadHeaderLine(xl_RowNo: Integer; var tempExcelBuff: Record "Excel Buffer" temporary) HeaderLine: Dictionary of [Text, Integer]
    var
        xl_ColNo: Integer;
        Caption: Text;
    begin
        for xl_ColNo := 1 to GetLastColumnNo_ExcelSheet(tempExcelBuff) do begin
            Caption := GetCellValueAsText(xl_RowNo, xl_ColNo, tempExcelBuff);
            if not HeaderLine.ContainsKey(Caption) then
                HeaderLine.Add(Caption, xl_ColNo)
            else
                Error('Die Spalte %1 ist mehrfach vorhanden.', Caption);
        end;
    end;

    procedure GetLastColumnNo_ExcelSheet(var tempExcelBuff: Record "Excel Buffer" temporary) LastColNo: Integer;
    begin
        tempExcelBuff.Reset();
        while tempExcelBuff.FindLast() do begin
            LastColNo := tempExcelBuff."Column No.";
            tempExcelBuff.SetFilter(tempExcelBuff."Column No.", '>%1', LastColNo);
        end;
    end;

    local procedure GetLastRowNo_ExcelSheet(var tempExcelBuff: Record "Excel Buffer" temporary) LastRowNo: Integer;
    begin
        if LastRowNo <> 0 then exit(LastRowNo);
        tempExcelBuff.Reset();
        tempExcelBuff.FindLast();
        LastRowNo := tempExcelBuff."Row No.";
        LastRowNo := LastRowNo;
    end;

    local procedure GetCellValueAsText(RowNo: Integer; ColumnNumberOrColumnLetters: Variant; var tempExcelBuff: Record "Excel Buffer" temporary): Text;
    var
        ColNo: Integer;
    begin
        case true of
            ColumnNumberOrColumnLetters.IsInteger:
                ColNo := ColumnNumberOrColumnLetters;
            ColumnNumberOrColumnLetters.IsText, ColumnNumberOrColumnLetters.IsCode:
                ColNo := ConvertExcelColumnIDToNumber(Format(ColumnNumberOrColumnLetters));
        end;
        if not tempExcelBuff.Get(RowNo, ColNo) then exit('');
        tempExcelBuff."Cell Value as Text" := tempExcelBuff."Cell Value as Text";
        exit(tempExcelBuff."Cell Value as Text");
    end;

    local procedure GetCellValueAsDecimal(RowNo: Integer; ColNo: Integer; var tempExcelBuff: Record "Excel Buffer" temporary) CellValue: Decimal;
    var
        CellText: Text;
    begin
        CellText := GetCellValueAsText(RowNo, ColNo, tempExcelBuff);
        if CellText = '' then exit(0);
        Evaluate(CellValue, CellText);
    end;

    local procedure GetCellValueAsInteger(RowNo: Integer; ColNo: Integer; var tempExcelBuff: Record "Excel Buffer" temporary) CellValue: Integer;
    var
        CellText: Text;
    begin
        CellText := GetCellValueAsText(RowNo, ColNo, tempExcelBuff);
        if CellText = '' then exit(0);
        Evaluate(CellValue, CellText);
    end;

    local procedure GetCellValueAsDate(RowNo: Integer; ColNo: Integer; var tempExcelBuff: Record "Excel Buffer" temporary) CellValue: Date;
    var
        CellText: Text;
    begin
        CellText := GetCellValueAsText(RowNo, ColNo, tempExcelBuff);
        if CellText = '' then exit(0D);
        Evaluate(CellValue, CellText);
    end;

    local procedure GetCellValueAsDateTime(RowNo: Integer; ColNo: Integer; var tempExcelBuff: Record "Excel Buffer" temporary) CellValue: DateTime;
    var
        CellText: Text;
    begin
        CellText := GetCellValueAsText(RowNo, ColNo, tempExcelBuff);
        if CellText = '' then exit(0DT);
        if not Evaluate(CellValue, CellText) then
            //Error('Der Wert "%1" kann nicht in Datum und Uhrzeit umgewandelt werden.', CellText);
            exit(0DT);
    end;

    local procedure ConvertExcelColumnIDToNumber(ColID: Text) ColumnNumber: Integer;
    var
        Letters: Text;
        Exponent: Integer;
        StringIndex: Integer;
        Position: Integer;
    begin
        Letters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        for StringIndex := StrLen(ColID) downto 1 do begin Position := StrPos(Letters, Format(ColID[StringIndex])); ColumnNumber += Power(26, Exponent) * Position; Exponent += 1; end;
    end;

    var
        tempExcelBufferGlobal: Record "Excel Buffer" temporary;

}