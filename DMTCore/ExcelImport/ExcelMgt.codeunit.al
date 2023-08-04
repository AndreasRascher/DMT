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

}