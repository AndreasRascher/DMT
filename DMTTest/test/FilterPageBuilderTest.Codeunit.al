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
        bufferRef: RecordRef;
        FilterFields: Dictionary of [Integer, Text];
        dataTable: List of [List of [Text]];
    begin
        // [GIVEN] GivenImportConfigWithSavedFilters
        testLibrary.CreateDMTSetup();
        salesHeader.FindFirst();
        salesHeader.SetRecFilter();
        salesHeader.FindFirst();
        salesHeader.SetRecFilter();
        testLibrary.BuildDataTable(dataTable, salesHeader.RecordId.TableNo, salesHeader.GetView());
        testLibrary.WriteDataTableToFileBlob(TempBlob, dataTable);
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