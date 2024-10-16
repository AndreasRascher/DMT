codeunit 90023 ImportConfigCardActionsTest
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure GivenImportConfigHeaderWithSourceFile_WhenImportingToBuffer_ThenBufferRecordsHaveBeenCreated()
    var
        DMTSetup: Record DMTSetup;
    begin
        // [GIVEN] ImportConfigHeaderWithSourceFile 
        initializeImportConfigHeader();
        // [WHEN] WhenImporting 
        DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_ImportBufferDataFromFile(ImportConfigHeaderGlobal);
        ImportConfigHeaderGlobal.UpdateBufferRecordCount();
        // [THEN] Buffer records have been created
        if ImportConfigHeaderGlobal."No.of Records in Buffer Table" = 0 then
            Error('No records were imported');
    end;

    [Test]
    [HandlerFunctions('FieldSelectionHandler,LogEntriesPageHandler,MessageHandler')]
    procedure GivenImportConfigHeaderWithBufferRecords_WhenImportingToTarget_ThenFilterPageIsRaised()
    var
        DMTSetup: Record DMTSetup;
        genBuffTable: Record DMTGenBuffTable;
        testLibrary: Codeunit DMTTestLibrary;
        targetRef: RecordRef;
    begin
        // [GIVEN] GivenImportConfigHeaderWithSourceFile 
        initializeImportConfigHeader();
        testLibrary.CreateFieldMapping(ImportConfigHeaderGlobal, false);
        // [WHEN] WhenImporting 
        DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_TransferToTargetTable(ImportConfigHeaderGlobal);
        // [THEN] Buffer recors have reference to imported records
        // [THEN] Gen. Buffer lines with status 'Imported' exist
        genBuffTable.FilterBy(ImportConfigHeaderGlobal);
        genBuffTable.FindLast();
        genBuffTable.TestField(Imported, true);
        targetRef.Get(genBuffTable."RecId (Imported)");
    end;

    [ModalPageHandler]
    procedure FieldSelectionHandler(var fieldSelection: TestPage DMTFieldSelection)
    begin
        fieldSelection.OK().Invoke();
    end;

    [PageHandler]
    procedure LogEntriesPageHandler(var LogEntries: TestPage DMTLogEntries)
    begin
        LogEntries.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
    end;

    local procedure initializeImportConfigHeader()
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        customer: Record Customer;
        testLibrary: Codeunit DMTTestLibrary;
        dataTableHelper: Codeunit DMTDataTableHelper;
        tempBlob: Codeunit "Temp Blob";
    begin
        if IsInitializedGlobal then
            exit;
        testLibrary.CreateDMTSetup();
        customer."No." := 'DMT10000';
        customer.Name := 'Customer 1';

        dataTableHelper.AddRecordWithCaptionsToDataTable(customer);
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'Customer.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        TestLibrary.CreateImportConfigHeader(ImportConfigHeaderGlobal, customer.RecordId.TableNo, sourceFileStorage);
        IsInitializedGlobal := true;
    end;

    var

        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        IsInitializedGlobal: Boolean;
}