codeunit 90032 "ImportExportTest"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // Test that the setup is found after it has been exported, deleted and re-imported
    [Test]
    procedure "GivenSetupExists_WhenSetupIsExportedAndImported_ThenSetupIsFoundOnImport"()
    var
        tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary;
        dmtSetup, dmtSetupOld : Record DMTSetup;
        xmlBackup: Codeunit DMTXMLBackup;
        backupXmlFile: Codeunit "Temp Blob";
        xmlDoc: XmlDocument;
    begin
        // [GIVEN] GivenSetupExists
        dmtSetupOld.InsertWhenEmpty();
        dmtSetupOld."Use exist. mappings" := false; // init value is true
        dmtSetupOld.Modify();
        // [WHEN] WhenSetupIsExported and cleared 
        xmlBackup.MarkRecordForExport(dmtSetupOld.RecordId);
        xmlBackup.CreateBackupXML(backupXmlFile);
        dmtSetup.DeleteAll();
        if not dmtSetup.isEmpty() then
            Error('DMT Setup table is not empty');
        // [WHEN] When importing setup from the backup file
        XmlDocument.ReadFrom(backupXmlFile.CreateInStream(), xmlDoc);
        xmlBackup.ImportTable(tempImportWorksheetBuffer, dmtSetup, xmlDoc);
        xmlBackup.SaveRecords(tempImportWorksheetBuffer);
        dmtSetupOld.Copy(dmtSetup);
        // [THEN] setup exists 
        if not dmtSetup.FindFirst() then
            Error('DMT Setup has not been imported');
        // [THEN] imported Setup is identical to the original
        if Format(dmtSetupOld) <> Format(dmtSetup) then
            Error('Imported DMT Setup is not identical to the original');
    end;

    // Test that the import of a source file storage record with a conflicting ID will assign a new ID
    // and that the import config header will be updated with the new ID
    [Test]
    procedure GIVEN_IDIsAlreadyInUse_WHEN_ImportAssignNewID()
    var
        tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary;
        importConfigHeader: Record DMTImportConfigHeader;
        customer: Record Customer;
        Vendor: Record Vendor;
        sourceFileStorage_Customer, sourcefilestorage_Vendor : Record DMTSourceFileStorage;
        backupFile_CustomerSourceFile: Codeunit "Temp Blob";
        testLibrary: Codeunit DMTTestLibrary;
        xmlBackup: Codeunit DMTXMLBackup;
        assert: Codeunit "Library Assert";
        xmlDoc: XmlDocument;
        oldID: Integer;
    begin
        // [GIVEN] Source file storage 
        testLibrary.CreateDMTSetup();
        customer."No." := 'DMT10000';
        customer.Name := 'Customer 1';
        testLibrary.CreateSourceFileStorage(sourceFileStorage_Customer, customer);

        // [GIVEN] Import Config Header using the source file storage
        testLibrary.CreateImportConfigHeader(importConfigHeader, Database::Customer, sourceFileStorage_Customer);

        // [GIVEN] Export of the source file storage and import config header
        xmlBackup.MarkRecordForExport(sourceFileStorage_Customer.RecordId);
        xmlBackup.MarkRecordForExport(importConfigHeader.RecordId);
        xmlBackup.CreateBackupXML(backupFile_CustomerSourceFile);
        importConfigHeader.Delete(true);
        sourceFileStorage_Customer.Delete(true);

        // [GIVEN] Create another source file storage record with the same "File ID"
        Vendor."No." := 'DMT10000';
        Vendor.Name := 'Vendor 1';
        testLibrary.CreateSourceFileStorage(sourcefilestorage_Vendor, Vendor);
        // [THEN] Ensure IDs are the same
        assert.AreEqual(sourceFileStorage_Customer."File ID", sourcefilestorage_Vendor."File ID", 'File ID should be the same');
        // [WHEN] When source file storage with conflicting ID is imported
        XmlDocument.ReadFrom(backupFile_CustomerSourceFile.CreateInStream(), xmlDoc);
        xmlBackup.ImportTables(tempImportWorksheetBuffer, xmlDoc);
        xmlBackup.findImportActions(tempImportWorksheetBuffer);
        xmlBackup.RenameIncomingRecordsIfRequired(tempImportWorksheetBuffer);
        xmlBackup.SaveRecords(tempImportWorksheetBuffer);
        // [THEN] On Re-Import, the new source table receives a new ID because the ID is already in use
        oldID := sourceFileStorage_Customer."File ID";
        sourceFileStorage_Customer.SetRange(Name, sourceFileStorage_Customer.Name);
        sourceFileStorage_Customer.FindFirst();
        assert.AreNotEqual(oldID, sourceFileStorage_Customer."File ID", 'File ID should be different');
        importConfigHeader.Get(importConfigHeader.RecordId);
        assert.AreEqual(sourceFileStorage_Customer."File ID", importConfigHeader."Source File ID", 'Source File ID should be the same');
    end;

    [Test]
    procedure GIVEN_ImportMultipleNewImportConfigs_WHEN_ImportingNewValidIDsAreAssigned()
    var
        tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary;
        importConfigHeader1, importConfigHeader2 : Record DMTImportConfigHeader;
        xmlBackup: Codeunit DMTXMLBackup;
        backupXmlFile: Codeunit "Temp Blob";
        lastUsedID: Integer;
        xmlDoc: XmlDocument;
    begin
        //[GIVEN] Import Config Header with the same target table and source file name
        if importConfigHeader1.FindLast() then
            lastUsedID := importConfigHeader1."ID";
        Clear(importConfigHeader1);

        importConfigHeader1."ID" := lastUsedID + 1;
        importConfigHeader1."Source File Name" := 'DummyFileName1';
        importConfigHeader1.Insert();
        xmlBackup.MarkRecordForExport(importConfigHeader1.RecordId);

        importConfigHeader2.ID += lastUsedID + 2;
        importConfigHeader2."Source File Name" := 'DummyFileName2';
        importConfigHeader2.Insert();
        xmlBackup.MarkRecordForExport(importConfigHeader2.RecordId);

        xmlBackup.CreateBackupXML(backupXmlFile);

        importConfigHeader1.Delete(true);
        importConfigHeader2.Delete(true);

        XmlDocument.ReadFrom(backupXmlFile.CreateInStream(), xmlDoc);
        xmlBackup.ImportTables(tempImportWorksheetBuffer, xmlDoc);
        xmlBackup.findImportActions(tempImportWorksheetBuffer);
        xmlBackup.RenameIncomingRecordsIfRequired(tempImportWorksheetBuffer);
        xmlBackup.SaveRecords(tempImportWorksheetBuffer);

        importConfigHeader1.SetRecFilter();
        importConfigHeader1.FindFirst();
        importConfigHeader2.SetRecFilter();
        importConfigHeader2.FindFirst();
    end;
}