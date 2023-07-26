codeunit 91018 DMTExcelReadFirstLine
{
    EventSubscriberInstance = Manual;
    trigger OnRun()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        IStr: InStream;
        ColumnList: List of [Integer];
        RowList: List of [Integer];
    begin
        TempBlobGlobal.CreateInStream(IStr);
        TempExcelBuffer.OpenBookStream(IStr, '');
        TempExcelBuffer.ReadSheetContinous('', true, ColumnList, RowList, 0);
    end;

    procedure Init(DMTSourceFileStorage: Record DMTSourceFileStorage; HeaderLineNo: integer)
    begin
        DMTSourceFileStorage.GetFileAsTempBlob(TempBlobGlobal);
        HeaderLineNoGlobal := HeaderLineNo;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", OnBeforeParseCellValue, '', false, false)]
    local procedure OnBeforeParseCellValue(var ExcelBuffer: Record "Excel Buffer"; var Value: Text; var FormatString: Text; var IsHandled: Boolean);
    begin
        IsHandled := true;
        AddDataTableField(ExcelBuffer."Row No.", Value);
    end;

    local procedure AddDataTableField(lineNo: Integer; fieldContent: Text)
    var
        Line: List of [Text];
    begin
        if DataTable.Get(lineNo, Line) then begin
            // append to existing line
            Line.Add(fieldContent);
            DataTable.Set(lineNo, Line);
        end else begin
            // new line
            Line.Add(fieldContent);
            DataTable.Add(Line);
        end;
    end;

    var
        TempBlobGlobal: Codeunit "Temp Blob";
        HeaderLineNoGlobal: Integer;
        DataTable: List of [List of [Text]];

}