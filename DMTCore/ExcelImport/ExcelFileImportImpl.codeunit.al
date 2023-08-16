codeunit 91005 DMTExcelFileImportImpl implements ISourceFileImport
{
    Access = Internal;

    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        genBuffTable: Record DMTGenBuffTable;
        SourceFileStorage: Record DMTSourceFileStorage;
        excelReader: Codeunit DMTExcelReader;
    begin
        // Delete existing lines
        if genBuffTable.FilterBy(ImportConfigHeader) then
            genBuffTable.DeleteAll();
        // Read File Blob
        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        SourceFileStorage.TestField(Name);
        BindSubscription(excelReader);
        excelReader.InitSourceFile(SourceFileStorage);
        excelReader.InitImportToGenBuffer(SourceFileStorage, ImportConfigHeader);
        LargeTextColCaptionGlobal := excelReader.LargeTextColCaptions();
        excelReader.Run();
        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text])
    var
        excelReader: Codeunit DMTExcelReader;
    begin
        BindSubscription(excelReader);
        // read top 5 rows if undefined
        excelReader.InitSourceFile(sourceFileStorage);
        if dataLayout."HeadingRowNo" = 0 then
            excelReader.InitReadRows(1, 5)
        else
            excelReader.InitReadRows(dataLayout."HeadingRowNo", dataLayout."HeadingRowNo");
        ClearLastError();
        excelReader.Run();
        if GetLastErrorText() <> '' then
            Error(GetLastErrorText());
        HeaderLine := excelReader.GetHeadlineColumnValues(FirstRowWithValues);
    end;

    procedure TooLargeValuesHaveBeenCutOffWarningIfRequired()
    var
        TooLargeValuesHaveBeenCutOffMsg: Label 'too large field values have been cut off. Max. string length is 250 chars',
                                           Comment = 'de-DE=Zu lange Feldwerte wurden abgeschnitten. Max. Textlänge ist 250 Zeichen';
        ColCaption, ColCaptionsList : Text;
    begin
        foreach ColCaption in LargeTextColCaptionGlobal.Values do begin
            ColCaptionsList += ',' + ColCaption;
        end;
        ColCaptionsList := ColCaptionsList.TrimStart(',');
        if ColCaptionsList <> '' then
            Message(TooLargeValuesHaveBeenCutOffMsg + '\' + ColCaptionsList);
    end;

    var
        LargeTextColCaptionGlobal: Dictionary of [Integer, Text];
}