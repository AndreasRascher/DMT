codeunit 90023 ImportConfigCardActionsTest
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    [Test]
    procedure GivenImportConfigHeaderWithSourceFile_WhenImportingToBuffer_ThenBufferRecordsHaveBeenCreated()
    var
        DMTSetup: Record DMTSetup;
    begin
        // [GIVEN] ImportConfigHeaderWithSourceFile 
        initializeImportConfigHeader();
        // [WHEN] WhenImporting 
        DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_ImportBufferDataFromFile(ImportConfigHeaderGlobal);
        if ImportConfigHeaderGlobal."No.of Records in Buffer Table" = 0 then
            Error('No records were imported');
    end;

    [Test]
    procedure GivenImportConfigHeaderWithBufferRecords_WhenImportingToTarget_ThenFilterPageIsRaised()
    var
        DMTSetup: Record DMTSetup;
        importConfigHeader: Record DMTImportConfigHeader;
    begin
        // [GIVEN] GivenImportConfigHeaderWithSourceFile 
        // [WHEN] WhenImporting 
        DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_TransferToTargetTable(importConfigHeader);
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
        SalesHeader: Record "Sales Header";
        testLibrary: Codeunit DMTTestLibrary;
        tempBlob: Codeunit "Temp Blob";
        dataTable: List of [List of [Text]];
    begin
        if IsInitializedGlobal then
            exit;
        testLibrary.CreateDMTSetup();
        SalesHeader.SetFilter("Sell-to Customer No.", '<>''''');
        SalesHeader.FindFirst();
        SalesHeader.SetRecFilter();
        testLibrary.BuildDataTable(dataTable, SalesHeader.RecordId.TableNo, SalesHeader.GetView());
        testLibrary.WriteDataTableToFileBlob(tempBlob, dataTable);
        TestLibrary.CreateSourceFileStorage(sourceFileStorage, 'SalesHeader.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        TestLibrary.CreateImportConfigHeader(ImportConfigHeaderGlobal, SalesHeader.RecordId.TableNo, sourceFileStorage);
        IsInitializedGlobal := true;
    end;

    var

        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        IsInitializedGlobal: Boolean;
}