codeunit 91005 DMTExcelFileImportImpl implements ISourceFileImport
{
    Access = Internal;

    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        logEntry: Record DMTLogEntry;
        triggerLogEntry: Record DMTTriggerLogEntry;
        SourceFileStorage: Record DMTSourceFileStorage;
        defaultSourceFileImportImpl: Codeunit DMTDefaultSourceFileImportImpl;
        excelReader: Codeunit DMTExcelReader;
        largeTextColCaptions: Dictionary of [Integer, Text];
    begin
        ImportConfigHeader.BufferTableMgt().DeleteAllBufferData(); // Delete existing lines
        if logEntry.FilterFor(ImportConfigHeader) then // Delete Error Log because it references the old autoincr. Line IDs
            logEntry.DeleteAll();
        if triggerLogEntry.FilterFor(ImportConfigHeader) then // Delete Trigger Log because it references the old autoincr. Line IDs
            triggerLogEntry.DeleteAll();

        // Read File Blob
        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        SourceFileStorage.TestField(Name);
        BindSubscription(excelReader);
        excelReader.InitSourceFile(SourceFileStorage);
        excelReader.InitImportToGenBuffer(SourceFileStorage, ImportConfigHeader);
        largeTextColCaptions := excelReader.LargeTextColCaptions();
        excelReader.Run();
        largeTextColCaptions := excelReader.LargeTextColCaptions();
        defaultSourceFileImportImpl.ShowTooLargeValuesHaveBeenCutOffWarningIfRequired(SourceFileStorage, largeTextColCaptions);
        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text])
    var
        excelReader: Codeunit DMTExcelReader;
    begin
        BindSubscription(excelReader);
        // read top 5 rows if undefined
        excelReader.InitSourceFile(sourceFileStorage);
        if dataLayout.HeadingRowNo = 0 then
            excelReader.InitReadRows(1, 5)
        else
            excelReader.InitReadRows(dataLayout.HeadingRowNo, dataLayout.HeadingRowNo);
        ClearLastError();
        excelReader.Run();
        if GetLastErrorText() <> '' then
            Error(GetLastErrorText());
        HeaderLine := excelReader.GetHeadlineColumnValues(FirstRowWithValues);
    end;
}