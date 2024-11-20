codeunit 90032 "ImportExportTest"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure "GivenSetupExists_WhenSetupIsExportedAndImported_ThenSetupIsFoundOnImport"()
    var
        dmtSetup: Record DMTSetup;
        tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary;
        xmlBackup: Codeunit DMTXMLBackup;
        xmlFile: Codeunit "Temp Blob";
        xmlDoc: XmlDocument;
    begin
        // [GIVEN] GivenSetupExists
        dmtSetup.InsertWhenEmpty();
        dmtSetup."Use exist. mappings" := false; // init value is true
        dmtSetup.Modify();
        // [WHEN] WhenSetupIsExported 
        xmlBackup.MarkRecordForExport(dmtSetup.RecordId);
        xmlBackup.CreateExportXML(xmlFile);
        // [WHEN] WhenSetupIsImported
        dmtSetup.DeleteAll();
        if not dmtSetup.isEmpty() then
            Error('DMT Setup table is not empty');
        XmlDocument.ReadFrom(xmlFile.CreateInStream(), xmlDoc);
        xmlBackup.ImportTable(tempImportWorksheetBuffer, dmtSetup, xmlDoc);
        xmlBackup.saveRecords(tempImportWorksheetBuffer);
        // [THEN] ThenSetupIsFoundOnImport 
        if not dmtSetup.FindFirst() then
            Error('DMT Setup has not been imported');
    end;

    [Test]
    procedure "GivenSourceTableExists_WhenOtherSourceTableWithSameIDIsImported_ThenTheNewSourceTableReceivesANewID"()
    var
        customer: Record Customer;
        Vendor: Record Vendor;
        sourceFileStorage: Record DMTSourceFileStorage;
        TempBlob, backupFile : Codeunit "Temp Blob";
        testLibrary: Codeunit DMTTestLibrary;
        dataTableHelper: Codeunit DMTDataTableHelper;
        xmlBackup: Codeunit DMTXMLBackup;
    begin
        // [GIVEN] Create Backup File to Import
        testLibrary.CreateDMTSetup();
        customer."No." := 'DMT10000';
        customer.Name := 'Customer 1';
        dataTableHelper.AddRecordWithCaptionsToDataTable(customer);
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'Customer.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        xmlBackup.MarkRecordForExport(sourceFileStorage.RecordId);
        xmlBackup.CreateExportXML(backupFile);
        // [GIVEN] Create Existing Source File
        Vendor."No." := 'DMT10000';
        Vendor.Name := 'Vendor 1';
        dataTableHelper.AddRecordWithCaptionsToDataTable(Vendor);
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'Vendor.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        // TODO: Ensure IDs are the same
        // [WHEN] WhenOtherSourceTableWithSameIDIsImported
        // [THEN] ThenTheNewSourceTableReceivesANewID
    end;
}