codeunit 91018 DMTExcelReader
{
    EventSubscriberInstance = Manual;
    trigger OnRun()
    var
        tempExcelBuffer: Record "Excel Buffer" temporary;
        IStr: InStream;
        ColumnList: List of [Integer];
    begin
        Progress_Open('Lese Zeile #############1#');

        TempBlobGlobal.CreateInStream(IStr);
        if TempBlobGlobal.Length() = 0 then Error('File Empty');
        SheetNameGlobal := tempExcelBuffer.SelectSheetsNameStream(IStr);
        tempExcelBuffer.OpenBookStream(IStr, SheetNameGlobal);
        tempExcelBuffer.ReadSheetContinous(SheetNameGlobal, true, ColumnList, RowListGlobal, 0);
        ProcessLastLine();

        Progress_Close();
    end;

    internal procedure SelectSheet(sourceFileStorage: Record DMTSourceFileStorage) SheetName: Text
    var
        tempExcelBuffer: Record "Excel Buffer" temporary;
        IStr: InStream;
    begin
        sourceFileStorage.GetFileAsTempBlob(TempBlobGlobal);
        TempBlobGlobal.CreateInStream(IStr);
        SheetName := tempExcelBuffer.SelectSheetsNameStream(IStr);
    end;

    internal procedure InitReadRows(sourceFileStorage: Record DMTSourceFileStorage; fromRowNo: integer; toRowNo: Integer)
    var
        rowNo: Integer;
    begin
        sourceFileStorage.GetFileAsTempBlob(TempBlobGlobal);
        for rowNo := fromRowNo to toRowNo do
            RowListGlobal.Add(rowNo);
        ReadModeGlobal := ReadModeGlobal::ReadOnly;
    end;

    internal procedure InitImportToGenBuffer(sourceFileStorage: Record DMTSourceFileStorage; headLineRowNo: Integer)
    begin
        sourceFileStorage.GetFileAsTempBlob(TempBlobGlobal);
        HeadLineRowNoGlobal := headLineRowNo;
        ImportFromFileNameGlobal := sourceFileStorage.Name;
        ReadModeGlobal := ReadModeGlobal::ImportToGenBuffer;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", OnBeforeParseCellValue, '', false, false)]
    local procedure OnBeforeParseCellValue(var ExcelBuffer: Record "Excel Buffer"; var Value: Text; var FormatString: Text; var IsHandled: Boolean);
    begin
        IsHandled := true;
        case ReadModeGlobal of
            ReadModeGlobal::ReadOnly:
                SaveCellValuesToDataTable(ExcelBuffer."Row No.", Value);
            ReadModeGlobal::ImportToGenBuffer:
                CollectLineAndInsertIntoToGenBufferTable(ExcelBuffer."Row No.", Value)
        end;

        ExcelBuffer.DeleteAll(false);
    end;

    local procedure SaveCellValuesToDataTable(lineNo: Integer; fieldContent: Text)
    begin
        if lineNo > CurrLineNoGlobal then begin
            //save last line
            if CurrLineNoGlobal > 0 then begin
                DataTable.Add(CurrentLineGlobal);
                Progress_Update(lineNo);
            end;
            //start new line
            CurrLineNoGlobal := lineNo;
            Clear(CurrentLineGlobal);
        end;

        CurrentLineGlobal.Add(fieldContent);

        // save first line with values info to find headline row no
        if FirstRowWithValuesGlobal = 0 then
            if fieldContent <> '' then
                FirstRowWithValuesGlobal := lineNo;
    end;

    local procedure CollectLineAndInsertIntoToGenBufferTable(rowNo: Integer; cellValue: Text)
    begin
        if rowNo > CurrLineNoGlobal then begin
            if CurrLineNoGlobal > 0 then
                ImportLine(CurrentLineGlobal, rowNo = HeadLineRowNoGlobal, ImportFromFileNameGlobal);
            Progress_Update(rowNo);
            //start new line
            CurrLineNoGlobal := rowNo;
            Clear(CurrentLineGlobal);
        end;
        CurrentLineGlobal.Add(cellValue);
    end;


    local procedure ImportLine(currentLine: List of [Text]; IsColumnCaptionLine: Boolean; ImportFromFileName: Text);
    var
        genBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
        NextEntryNo: Integer;
        CurrColIndex: Integer;
        cellValue: Text;
    begin
        NextEntryNo := genBuffTable.GetNextEntryNo();

        genBuffTable.Init();
        genBuffTable."Entry No." := NextEntryNo;
        genBuffTable.IsCaptionLine := IsColumnCaptionLine;
        RecRef.GetTable(genBuffTable);
        foreach cellValue in currentLine do begin
            CurrColIndex += 1;
            RecRef.Field(1000 + CurrColIndex).Value := cellValue;
        end;

        RecRef.SetTable(genBuffTable);
        genBuffTable."Import from Filename" := CopyStr(ImportFromFileName, 1, MaxStrLen(genBuffTable."Import from Filename"));
        genBuffTable."Column Count" := CurrColIndex;
        genBuffTable.Insert();
    end;

    internal procedure GetHeadlineColumnValues() HeadLine: List of [Text]
    begin
        if (DataTable.Count > 1) and (FirstRowWithValuesGlobal <> 0) then begin
            DataTable.Get(FirstRowWithValuesGlobal, HeadLine);
        end else begin
            HeadLine := DataTable.Get(1);
        end;
    end;

    internal procedure GetSheetName(): Text
    begin
        exit(SheetNameGlobal);
    end;

    #region ProgressDialog
    local procedure Progress_Update(lineNo: Integer)
    begin
        if not Progress_IsActive then exit;
        if (CurrentDateTime - LastDialogUpdate) > 2000 then begin
            Progress.Update(1, lineNo);
            LastDialogUpdate := CurrentDateTime;
        end;
    end;

    local procedure Progress_Open(dialogText: Text)
    begin
        Progress.Open(dialogText);
        LastDialogUpdate := CurrentDateTime;
        Progress_IsActive := true;
    end;

    local procedure Progress_Close()
    begin
        if not Progress_IsActive then
            exit;
        Progress.Close();
        Progress_IsActive := false;
    end;
    #endregion ProgressDialog

    local procedure ProcessLastLine()
    begin
        case ReadModeGlobal of
            ReadModeGlobal::ReadOnly:
                begin
                    DataTable.Add(CurrentLineGlobal);
                    Clear(CurrentLineGlobal);
                end;
            ReadModeGlobal::ImportToGenBuffer:
                ImportLine(CurrentLineGlobal, false, ImportFromFileNameGlobal);
        end;
    end;

    var
        ReadModeGlobal: Option ReadOnly,ImportToGenBuffer;
        TempBlobGlobal: Codeunit "Temp Blob";
        DataTable: List of [List of [Text]];
        CurrentLineGlobal: List of [Text];
        RowListGlobal: List of [Integer];
        CurrLineNoGlobal: Integer;
        FirstRowWithValuesGlobal: Integer;
        HeadLineRowNoGlobal: Integer;
        Progress: Dialog;
        Progress_IsActive: Boolean;
        LastDialogUpdate: DateTime;
        ImportFromFileNameGlobal: Text;
        SheetNameGlobal: Text;
}