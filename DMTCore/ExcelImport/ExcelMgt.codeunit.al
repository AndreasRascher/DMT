codeunit 91005 DMTExcelMgt implements ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        SourceFileStorage: Record DMTSourceFileStorage;
        GenBuffTable: Record DMTGenBuffTable;
        IStr: InStream;
        xl_LineNo, LastExcelLineNo, LastExcelColNo : Integer;
    begin
        // Delete existing lines
        if GenBuffTable.FilterBy(ImportConfigHeader) then
            GenBuffTable.DeleteAll();
        // Read File Blob
        SourceFileStorage.get(ImportConfigHeader."Source File ID");
        SourceFileStorage.TestField(Name);
        SourceFileStorage.CalcFields("File Blob");
        SourceFileStorage."File Blob".CreateInStream(IStr);
        // Import Excel
        ImportFileFromStream(IStr);
        LastExcelLineNo := GetLastRowNo_ExcelSheet(tempExcelBufferGlobal);
        LastExcelColNo := GetLastColumnNo_ExcelSheet(tempExcelBufferGlobal);
        for xl_LineNo := 1 to LastExcelLineNo do
            ImportLine(xl_LineNo, LastExcelColNo, xl_LineNo = 1, SourceFileStorage.Name);

        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    local procedure ImportLine(xl_LineNo: Integer; LastExcelColNo: Integer; IsColumnCaptionLine: Boolean; ImportFromFileName: Text);
    var
        genBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
        NextEntryNo: Integer;
        CurrColIndex: Integer;
    begin
        NextEntryNo := genBuffTable.GetNextEntryNo();
        genBuffTable.Init();
        genBuffTable."Entry No." := NextEntryNo;
        genBuffTable.IsCaptionLine := IsColumnCaptionLine;
        for CurrColIndex := 1 to LastExcelColNo do begin
            RecRef.GetTable(GenBuffTable);
            RecRef.Field(1000 + CurrColIndex).Value := GetCellValueAsText(xl_LineNo, CurrColIndex, tempExcelBufferGlobal);
            RecRef.SetTable(GenBuffTable);
        end;
        genBuffTable."Import from Filename" := CopyStr(ImportFromFileName, 1, MaxStrLen(genBuffTable."Import from Filename"));
        genBuffTable."Column Count" := LastExcelColNo;
        genBuffTable.Insert();
    end;

    internal procedure GetHeaderLine() HeaderLine: Dictionary of [Text, Integer];
    begin
        HeaderLine := ReadHeaderLine(1, tempExcelBufferGlobal);
    end;

    internal procedure ImportFileFromStream(var inStr: InStream)
    var
        SheetName: Text;
    begin
        SheetName := tempExcelBufferGlobal.SelectSheetsNameStream(inStr);
        tempExcelBufferGlobal.OpenBookStream(inStr, SheetName);
        tempExcelBufferGlobal.ReadSheet();
    end;

    internal procedure LoadFileWithDialog()
    var
        TempBlob: Codeunit "Temp Blob";
        selectAnImportFileLbl: Label 'Select an import file';
        FileName: Text;
        inStr: InStream;
    begin
        TempBlob.CreateInStream(inStr);
        if not UploadIntoStream(selectAnImportFileLbl, '', format(enum::DMTFileFilter::Excel), FileName, inStr) then
            exit;
        ImportFileFromStream(inStr);
        SelectedFileName(FileName);
    end;

    internal procedure SelectedFileName(FileNameNew: Text)
    begin
        FileNameGlobal := FileNameNew;
    end;

    internal procedure SelectedFileName(): Text
    begin
        exit(FileNameGlobal);
    end;

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
        FileNameGlobal: Text;

}