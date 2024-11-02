codeunit 90031 FilterPageTest
{
    Subtype = Test;
    TestPermissions = Disabled;
    [Test]
    [HandlerFunctions('HandleFieldSelection')]
    procedure GIVEN_ImportConfigWithSavedFilters_WHEN_FilterPageFieldsAreCollected_THEN_KeyFieldsAndFilterFieldsAreShow()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        sourceFileStorage: Record DMTSourceFileStorage;
        salesHeader: Record "Sales Header";
        dataTableHelper: Codeunit DMTDataTableHelper;
        testLibrary: Codeunit DMTTestLibrary;
        assert: Codeunit "Library Assert";
        TempBlob: Codeunit "Temp Blob";
        fieldSelection: Page DMTFieldSelection;
        bufferRef: RecordRef;
    begin
        // [GIVEN] GivenImportConfigWithSavedFilters
        testLibrary.CreateDMTSetup();
        salesHeader."Document Type" := salesHeader."Document Type"::Order;
        salesHeader."No." := '10000';
        salesHeader."Sell-to Customer No." := '10000';
        salesHeader."Location Code" := 'BLAU';
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
        fieldSelection.EditSourceTableFilters(bufferRef, ImportConfigHeader);
        // [THEN] ThenKeyFieldsAndFilterFieldsAreShown 
        assert.AreEqual(2 + 1, NoOfLinesInFieldSelectionGlobal, '1 filtered field an 2 key fields are expected');
    end;

    [ModalPageHandler]
    procedure HandleFieldSelection(var fieldSelection: TestPage DMTFieldSelection)
    var
        fieldContent: Text;
    begin
        if fieldSelection.First() then begin
            fieldContent := fieldSelection.EditSourceTableFilters_SourceField.Value;
            if fieldContent <> '' then
                NoOfLinesInFieldSelectionGlobal := 1;
        end;

        while fieldSelection.Next() do begin
            fieldContent := fieldSelection.EditSourceTableFilters_SourceField.Value;
            if fieldContent <> '' then
                NoOfLinesInFieldSelectionGlobal += 1;
        end;
    end;

    var
        NoOfLinesInFieldSelectionGlobal: Integer;
}