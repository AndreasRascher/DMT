codeunit 91005 DMTExcelMgt implements ISourceFileImport
{
    Access = Internal;

    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        SourceFileStorage: Record DMTSourceFileStorage;
        genBuffTable: Record DMTGenBuffTable;
        TempBlob: Codeunit "Temp Blob";
        xl_LineNo, LastExcelLineNo, LastExcelColNo : Integer;
    begin
        // Delete existing lines
        if genBuffTable.FilterBy(ImportConfigHeader) then
            genBuffTable.DeleteAll();
        // Read File Blob
        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        SourceFileStorage.TestField(Name);
        TempBlob.FromRecord(SourceFileStorage, SourceFileStorage.FieldNo("File Blob"));
        InitFileStreamFromBlob(TempBlob, SourceFileStorage.Name);
        ReadSheet(ImportConfigHeader.GetDataLayout().XLSDefaultSheetName);

        LastExcelLineNo := GetLastSheetRowNo(tempExcelBufferGlobal);
        LastExcelColNo := GetLastSheetColumnNo(tempExcelBufferGlobal);
        for xl_LineNo := 1 to LastExcelLineNo do
            ImportLine(xl_LineNo, LastExcelColNo, xl_LineNo = 1, SourceFileStorage.Name);

        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    internal procedure InitFileStreamFromUpload()
    var
        tempBlob: Codeunit "Temp Blob";
        selectAnImportFileLbl: Label 'Select an import file', Comment = 'de-DE=Importdatei auswählen';
        FileName: Text;
    begin
        tempBlob.CreateInStream(excelFileStreamGlobal);
        if not UploadIntoStream(selectAnImportFileLbl, '', Format(Enum::DMTFileFilter::Excel), FileName, excelFileStreamGlobal) then
            exit;
        SetSelectedFileName(FileName);
        HasExcelFileStream := true;
    end;

    internal procedure InitFileStreamFromBlob(var TempBlob: Codeunit "Temp Blob"; FileName: text)
    begin
        TempBlob.CreateInStream(excelFileStreamGlobal);
        SetSelectedFileName(FileName);
        HasExcelFileStream := true;
    end;

    internal procedure ReadSheet(SheetName: Text)
    begin
        CheckHasExcelFileStream();
        if SheetName = '' then
            SheetName := SelectSheet();
        tempExcelBufferGlobal.OpenBookStream(excelFileStreamGlobal, SheetName);
        tempExcelBufferGlobal.ReadSheet();
        IsExcelBufferLoaded := true;
    end;

    procedure ReadHeaderLine(headingRowNo: Integer) HeaderLine: Dictionary of [Text, Integer]
    var
        xl_ColNo: Integer;
        Caption: Text;
    begin
        CheckExcelBufferIsLoaded();
        for xl_ColNo := 1 to GetLastSheetColumnNo(tempExcelBufferGlobal) do begin
            Caption := GetCellValueAsText(headingRowNo, xl_ColNo, tempExcelBufferGlobal);
            if not HeaderLine.ContainsKey(Caption) then
                HeaderLine.Add(Caption, xl_ColNo)
            else
                Error('Die Spalte %1 ist mehrfach vorhanden.', Caption);
        end;
    end;

    local procedure CheckHasExcelFileStream()
    var
        excelFilestreamNotLoadedErr: Label 'No excel file has not been loaded.', Comment = 'de-DE=Keine Exceldatei wurde geladen.';
    begin
        if not HasExcelFileStream then
            Error(excelFilestreamNotLoadedErr);
    end;

    local procedure CheckExcelBufferIsLoaded()
    var
        excelBufferIsNotLoadedErr: Label 'Excel buffer not initialized.', Comment = 'de-DE=Excel Buffer wurde nicht in geladen.';
    begin
        if not IsExcelBufferLoaded then
            Error(excelBufferIsNotLoadedErr);
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
            RecRef.GetTable(genBuffTable);
            RecRef.Field(1000 + CurrColIndex).Value := GetCellValueAsText(xl_LineNo, CurrColIndex, tempExcelBufferGlobal);
            RecRef.SetTable(genBuffTable);
        end;
        genBuffTable."Import from Filename" := CopyStr(ImportFromFileName, 1, MaxStrLen(genBuffTable."Import from Filename"));
        genBuffTable."Column Count" := LastExcelColNo;
        genBuffTable.Insert();
    end;

    internal procedure SelectSheet() SheetName: Text
    begin
        SheetName := tempExcelBufferGlobal.SelectSheetsNameStream(excelFileStreamGlobal);
    end;

    internal procedure SetSelectedFileName(FileNameNew: Text)
    begin
        FileNameGlobal := FileNameNew;
    end;

    internal procedure SelectedFileName(): Text
    begin
        exit(FileNameGlobal);
    end;

    procedure GetLastSheetColumnNo(var tempExcelBuff: Record "Excel Buffer" temporary) LastColNo: Integer;
    begin
        tempExcelBuff.Reset();
        while tempExcelBuff.FindLast() do begin
            LastColNo := tempExcelBuff."Column No.";
            tempExcelBuff.SetFilter(tempExcelBuff."Column No.", '>%1', LastColNo);
        end;
    end;

    local procedure GetLastSheetRowNo(var tempExcelBuff: Record "Excel Buffer" temporary) LastRowNo: Integer;
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
        for StringIndex := StrLen(ColID) downto 1 do begin
            Position := StrPos(Letters, Format(ColID[StringIndex]));
            ColumnNumber += Power(26, Exponent) * Position;
            Exponent += 1;
        end;
    end;

    var
        tempExcelBufferGlobal: Record "Excel Buffer" temporary;
        excelFileStreamGlobal: InStream;
        FileNameGlobal: Text;
        HasExcelFileStream, IsExcelBufferLoaded : Boolean;
}