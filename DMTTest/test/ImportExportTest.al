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
        tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary;
        customer: Record Customer;
        Vendor: Record Vendor;
        sourceFileStorage1, sourceFileStorage2 : Record DMTSourceFileStorage;
        TempBlob, backupFile : Codeunit "Temp Blob";
        testLibrary: Codeunit DMTTestLibrary;
        dataTableHelper: Codeunit DMTDataTableHelper;
        xmlBackup: Codeunit DMTXMLBackup;
        assert: Codeunit "Library Assert";
        xmlDoc: XmlDocument;
        oldID: Integer;
    begin
        // [GIVEN] Create Backup File to Import
        testLibrary.CreateDMTSetup();
        customer."No." := 'DMT10000';
        customer.Name := 'Customer 1';
        Clear(dataTableHelper);
        dataTableHelper.AddRecordWithCaptionsToDataTable(customer);
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage1, 'Customer.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        xmlBackup.MarkRecordForExport(sourceFileStorage1.RecordId);
        xmlBackup.CreateExportXML(backupFile);
        sourceFileStorage1.Delete(true);

        // [GIVEN] Create another source file storage record with the same "File ID"
        Vendor."No." := 'DMT10000';
        Vendor.Name := 'Vendor 1';
        Clear(dataTableHelper);
        dataTableHelper.AddRecordWithCaptionsToDataTable(Vendor);
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage2, 'Vendor.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        // [THEN] Ensure IDs are the same
        assert.AreEqual(sourceFileStorage1."File ID", sourceFileStorage2."File ID", 'File ID should be the same');
        // [WHEN] WhenOtherSourceTableWithSameIDIsImported
        XmlDocument.ReadFrom(backupFile.CreateInStream(), xmlDoc);
        xmlBackup.ImportTable(tempImportWorksheetBuffer, sourceFileStorage1, xmlDoc);
        xmlBackup.findImportAction(tempImportWorksheetBuffer);
        xmlBackup.saveRecords(tempImportWorksheetBuffer);
        // [THEN] ThenTheNewSourceTableReceivesANewID
        oldID := sourceFileStorage2."File ID";
        sourceFileStorage2.SetRange(Name, sourceFileStorage2.Name);
        sourceFileStorage2.FindFirst();
    end;
}