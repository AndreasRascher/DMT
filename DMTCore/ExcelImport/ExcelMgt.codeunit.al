codeunit 91005 DMTExcelMgt implements ISourceFileImport
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

}