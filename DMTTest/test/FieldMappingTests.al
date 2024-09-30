codeunit 90029 FieldMappingTests
{
    /*
    Tests:
- Feldmapping
   - Import Headline
   - Reuse Names
    */
    Subtype = Test;
    [Test]
    procedure TestFieldMappingIsReusedBetweenImportConfigsTest()
    // [SCENARIO] Scenario Description
    // users have data from other sources than NAV oder Business Central
    // they want to import this data into NAV or Business Central
    // other systems have their own naming conventions
    // users want to reuse the field mapping from one import config to another
    var
        importConfigA, importConfigB : Record DMTImportConfigHeader;
        importConfigLineB: Record DMTImportConfigLine;
        sourceFileStrorage: Record DMTSourceFileStorage;
        DMTSetup: Record DMTSetup;
        dummyCustomer: Record Customer;
        testLibrary: Codeunit DMTTestLibrary;
        dataTableHelper: Codeunit DMTDataTableHelper;
        tempBlob: Codeunit "Temp Blob";
        ISourceFileImport: Interface ISourceFileImport;
        BuffTableCaptions: Dictionary of [Integer, Text];
    begin
        // [GIVEN] Import Configuration A with source file and field mapping
        dataTableHelper.SetLine(1, 'ID', 'Name', 'Street');
        dataTableHelper.SetLine(2, '1', 'Test', 'Teststreet 1');
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStrorage, 'Customer.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        testLibrary.CreateImportConfigHeader(importConfigA, Database::Customer, sourceFileStrorage);
        // [THEN] Then the headline is imported from the source file
        ISourceFileImport := importConfigA.GetSourceFileStorage().SourceFileFormat;
        ISourceFileImport.ImportSelectedRows(importConfigA, importConfigA.GetDataLayout().HeadingRowNo, importConfigA.GetDataLayout().HeadingRowNo);

        if not importConfigA.BufferTableMgt().ReadBufferTableColumnCaptions(BuffTableCaptions) then
            Error('Buffer Table Captions could not be read');
        // [GIVEN] Import Configuration A Target fields are initialized
        testLibrary.InitTargetFields(importConfigA);
        testLibrary.SetFieldMapping(importConfigA, dummyCustomer.FieldCaption("No."), 'ID');
        testLibrary.SetFieldMapping(importConfigA, dummyCustomer.FieldCaption(Address), 'Street');

        // [GIVEN] Import Configuration B with source file no field mapping
        dataTableHelper.SetLine(1, 'ID', 'Name', 'Street');
        dataTableHelper.SetLine(2, '1', 'Test', 'Teststreet 1');
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStrorage, 'Vendor.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        testLibrary.CreateImportConfigHeader(importConfigB, Database::Vendor, sourceFileStrorage);
        // [THEN] Then the headline is imported from the source file
        ISourceFileImport := importConfigB.GetSourceFileStorage().SourceFileFormat;
        ISourceFileImport.ImportSelectedRows(importConfigB, importConfigB.GetDataLayout().HeadingRowNo, importConfigB.GetDataLayout().HeadingRowNo);
        if not importConfigB.BufferTableMgt().ReadBufferTableColumnCaptions(BuffTableCaptions) then
            Error('Buffer Table Captions could not be read');
        // [GIVEN] Import Configuration B Target fields are initialized
        testLibrary.InitTargetFields(importConfigB);
        // [WHEN] Reuse field mapping is enabled in Setup
        DMTSetup.GetRecordOnce();
        DMTSetup.Validate("Use exist. mappings", true);
        DMTSetup.Modify();
        // [WHEN] proposing a field mapping
        testLibrary.proposeMatchingFields(importConfigB);
        // [THEN] Then the field mapping is reused
        importConfigLineB.Get(importConfigB.ID, dummyCustomer.FieldNo("No."));
        importConfigLineB.TestField("Source Field Caption", 'ID');
        importConfigLineB.Get(importConfigB.ID, dummyCustomer.FieldNo(Address));
        importConfigLineB.TestField("Source Field Caption", 'Street');
        // [THEN] unassigned fields are mapped by name
        importConfigLineB.Get(importConfigB.ID, dummyCustomer.FieldNo(Name));
        importConfigLineB.TestField("Source Field Caption", 'Name');
    end;


}