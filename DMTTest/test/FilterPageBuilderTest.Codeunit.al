codeunit 90025 FilterPageBuilderTest
{
    Subtype = Test;
    TestPermissions = Disabled;
    [Test]
    procedure GIVEN_ImportConfigWithSavedFilters_WHEN_FilterPageFieldsAreCollected_THEN_KeyFieldsAndFilterFieldsAreShow()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        sourceFileStorage: Record DMTSourceFileStorage;
        salesHeader: Record "Sales Header";
        importConfigLine: Record DMTImportConfigLine;
        FPBuilder: Codeunit DMTFPBuilder;
        testLibrary: Codeunit DMTTestLibrary;
        TempBlob: Codeunit "Temp Blob";
        assert: Codeunit "Library Assert";
        dataTableHelper: Codeunit DMTDataTableHelper;
        bufferRef: RecordRef;
        FilterFields: Dictionary of [Integer, Text];
    begin
        // [GIVEN] GivenImportConfigWithSavedFilters
        testLibrary.CreateDMTSetup();
        salesHeader.FindFirst();
        salesHeader.SetRecFilter();
        dataTableHelper.AddRecordWithCaptionsToDataTable(salesHeader);
        dataTableHelper.WriteDataTableToFileBlob(TempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStorage,
                                            'SalesHeader.csv',
                                            testLibrary.GetDefaultNAVDMTLayout(),
                                            TempBlob);
        testLibrary.CreateImportConfigHeader(ImportConfigHeader, Database::"Sales Header", sourceFileStorage);
        testLibrary.CreateFieldMapping(ImportConfigHeader, false);
        ImportConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.SetRange("Target Field No.", salesHeader.FieldNo("Location Code"));
        importConfigLine.FindFirst();
        ImportConfigHeader.BufferTableMgt().InitBufferRef(bufferRef);
        bufferRef.Field(importConfigLine."Source Field No.").SetFilter('<>''''');
        ImportConfigHeader.WriteSourceTableView(bufferRef.GetView(false));
        // [WHEN] WhenFilterPageFieldsAreCollected 
        FilterFields := FPBuilder.InitFilterFields(bufferRef, ImportConfigHeader);
        // [THEN] ThenKeyFieldsAndFilterFieldsAreShown 
        assert.AreEqual(2 + 1, FilterFields.Keys.Count, '1 filtered field an 2 key fields are expected');
    end;
}