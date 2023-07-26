codeunit 91018 DMTExcelReadFirstLine
{
    EventSubscriberInstance = Manual;
    trigger OnRun()
    var
        DMTExcelMgt: Codeunit DMTExcelMgt;
    begin
        DMTExcelMgt.InitFileStreamFromBlob(TempBlob, 'DummyName');
        DMTExcelMgt.ReadSheet('');
    end;

    procedure Init(DMTSourceFileStorage: Record DMTSourceFileStorage; HeaderLineNo: integer)
    begin
        DMTSourceFileStorage.GetFileAsTempBlob(TempBlob);
        HeaderLineNoGlobal := HeaderLineNo;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", OnBeforeParseCellValue, '', false, false)]
    local procedure OnBeforeParseCellValue(var ExcelBuffer: Record "Excel Buffer"; var Value: Text; var FormatString: Text; var IsHandled: Boolean);
    begin
        IsHandled := true;
        if ExcelBuffer."Row No." > HeaderLineNoGlobal then
            Error(''); // stop reading
        if ExcelBuffer."Row No." = HeaderLineNoGlobal then begin
            HeadlineColumnValuesGlobal.Set(format(Value), ExcelBuffer."Column No.");
        end;
    end;

    procedure GetHeadlineColumnValues() HeadlineColumnValues: Dictionary of [Text, Integer];
    begin
        exit(HeadlineColumnValuesGlobal);
    end;


    var
        TempBlob: Codeunit "Temp Blob";
        HeaderLineNoGlobal: Integer;
        HeadlineColumnValuesGlobal: Dictionary of [Text, Integer];

}