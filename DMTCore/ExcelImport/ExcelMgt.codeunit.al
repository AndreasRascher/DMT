codeunit 91005 DMTExcelMgt implements ISourceFileImport
{
    Access = Internal;

    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        genBuffTable: Record DMTGenBuffTable;
        SourceFileStorage: Record DMTSourceFileStorage;
        excelReader: Codeunit DMTExcelReader;
        TempBlob: Codeunit "Temp Blob";
    begin
        // Delete existing lines
        if genBuffTable.FilterBy(ImportConfigHeader) then
            genBuffTable.DeleteAll();
        // Read File Blob
        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        SourceFileStorage.TestField(Name);
        SourceFileStorage.GetFileAsTempBlob(TempBlob);
        BindSubscription(excelReader);
        excelReader.InitImportToGenBuffer(SourceFileStorage, ImportConfigHeader.GetDataLayout()."HeadingRowNo");
        excelReader.Run();
        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text])
    var
        excelReader: Codeunit DMTExcelReader;
    begin
        BindSubscription(excelReader);
        // read top 5 rows if undefined
        if dataLayout."HeadingRowNo" = 0 then
            excelReader.InitReadRows(sourceFileStorage, 1, 5)
        else
            excelReader.InitReadRows(sourceFileStorage, dataLayout."HeadingRowNo", dataLayout."HeadingRowNo");
        ClearLastError();
        excelReader.Run();
        if GetLastErrorText() <> '' then
            Error(GetLastErrorText());
        HeaderLine := excelReader.GetHeadlineColumnValues(FirstRowWithValues);
    end;

}