codeunit 91018 DMTExcelReader
{
    EventSubscriberInstance = Manual;
    trigger OnRun()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        IStr: InStream;
        ColumnList: List of [Integer];
        SheetName: Text;
    begin
        Progress_Open('Lese Zeile #############1#');

        TempBlobGlobal.CreateInStream(IStr);
        if TempBlobGlobal.Length() = 0 then Error('File Empty');
        SheetName := TempExcelBuffer.SelectSheetsNameStream(IStr);
        TempExcelBuffer.OpenBookStream(IStr, SheetName);
        TempExcelBuffer.ReadSheetContinous(SheetName, true, ColumnList, RowListGlobal, 0);

        Progress_Close();
    end;

    internal procedure InitReadRows(DMTSourceFileStorage: Record DMTSourceFileStorage; fromRowNo: integer; toRowNo: Integer)
    var
        rowNo: Integer;
    begin
        DMTSourceFileStorage.GetFileAsTempBlob(TempBlobGlobal);
        for rowNo := fromRowNo to toRowNo do
            RowListGlobal.Add(rowNo);
    end;

    internal procedure GetHeadlineColumnValues() HeadLine: List of [Text]
    begin
        SaveLastLineReadButNotAssignedToDataTable();
        if (DataTable.Count > 1) and (FirstRowWithValuesGlobal <> 0) then begin
            DataTable.Get(FirstRowWithValuesGlobal, HeadLine);
        end else begin
            HeadLine := DataTable.Get(1);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", OnBeforeParseCellValue, '', false, false)]
    local procedure OnBeforeParseCellValue(var ExcelBuffer: Record "Excel Buffer"; var Value: Text; var FormatString: Text; var IsHandled: Boolean);
    begin
        IsHandled := true;
        AddDataTableField(ExcelBuffer."Row No.", Value);
        ExcelBuffer.DeleteAll(false);
    end;

    local procedure AddDataTableField(lineNo: Integer; fieldContent: Text)
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

    local procedure SaveLastLineReadButNotAssignedToDataTable()
    begin
        if CurrentLineGlobal.Count > 0 then begin
            DataTable.Add(CurrentLineGlobal);
            Clear(CurrentLineGlobal);
        end;
    end;



    var
        TempBlobGlobal: Codeunit "Temp Blob";
        DataTable: List of [List of [Text]];
        CurrentLineGlobal: List of [Text];
        CurrLineNoGlobal: Integer;
        RowListGlobal: List of [Integer];
        FirstRowWithValuesGlobal: Integer;
        Progress: Dialog;
        Progress_IsActive: Boolean;
        LastDialogUpdate: DateTime;

}