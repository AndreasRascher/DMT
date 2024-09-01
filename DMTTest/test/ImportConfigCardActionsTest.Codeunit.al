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
        if ImportConfigHeaderGlobal."No.of Records in Buffer Table" = 0 then
            Error('No records were imported');
    end;

    [Test]
    [HandlerFunctions('ImportToTargetFilterPageHandler')]
    procedure GivenImportConfigHeaderWithBufferRecords_WhenImportingToTarget_ThenFilterPageIsRaised()
    var
        DMTSetup: Record DMTSetup;
        testLibrary: Codeunit DMTTestLibrary;
    begin
        // [GIVEN] GivenImportConfigHeaderWithSourceFile 
        initializeImportConfigHeader();
        testLibrary.CreateFieldMapping(ImportConfigHeaderGlobal, false);
        // [WHEN] WhenImporting 
        DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_TransferToTargetTable(ImportConfigHeaderGlobal);
    end;

    [FilterPageHandler]
    procedure ImportToTargetFilterPageHandler(var Record1: RecordRef): Boolean;
    begin
        // If this procedure isn't called, no filter page is raised and the test fails
    end;

    procedure GivenImportConfigHeaderWithBufferRecords_WhenImportingToTarget_LinesHaveBeenUpdated()
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        // [GIVEN] ImportConfigHeaderWithSourceFile, Import is finished
        // [WHEN] Lines have been updated
        genBuffTable.FilterBy(ImportConfigHeaderGlobal);
        // [THEN] Gen. Buffer lines with status 'Imported' exist
    end;

    local procedure initializeImportConfigHeader()
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        ExtendedTextHeader: Record "Extended Text Header";
        testLibrary: Codeunit DMTTestLibrary;
        dataTableHelper: Codeunit DMTDataTableHelper;
        tempBlob: Codeunit "Temp Blob";
    begin
        if IsInitializedGlobal then
            exit;
        testLibrary.CreateDMTSetup();
        ExtendedTextHeader.FindFirst();
        ExtendedTextHeader.SetRecFilter();
        dataTableHelper.AddRecordWithCaptionsToDataTable(ExtendedTextHeader);
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'ExtendedTextHeader.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        TestLibrary.CreateImportConfigHeader(ImportConfigHeaderGlobal, ExtendedTextHeader.RecordId.TableNo, sourceFileStorage);
        IsInitializedGlobal := true;
    end;

    var

        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        IsInitializedGlobal: Boolean;
}