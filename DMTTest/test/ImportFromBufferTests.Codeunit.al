codeunit 90025 DMTImportFromBufferTests
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [HandlerFunctions('ImportFieldFilterDialog,LogEntriesAfterRun,ResultMessageHandler')]
    procedure GivenCustomerDataWithoutNoColumn_WhenNoSeriesTypeStartNoIsUsed_ThenAssignNoOnlyOnce()
    var
        customer: Record Customer;
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        testLibrary: Codeunit DMTTestLibrary;
        assert: Codeunit "Library Assert";
        customValueSettings: Page DMTCustomValueSettings;
    begin
        // [GIVEN] GivenCustomerDataWithoutNoColumn
        initializeImportConfigForCustomerDataWithoutNoField(importConfigHeader);

        // [GIVEN] NoSeriesTypeStartNoIsUsed 
        importConfigLine.Get(importConfigHeader.ID, customer.FieldNo("No."));
        customValueSettings.SetSetting_NoSeriesType_StartingNo(importConfigLine);
        customValueSettings.SetSetting_StartingNo(importConfigLine, '001');
        importConfigLine."Processing Action" := importConfigLine."Processing Action"::CustomValue;
        importConfigLine."Custom Value Type" := importConfigLine."Custom Value Type"::"No.Series";
        importConfigLine.Modify();

        // [WHEN] When importing data 
        testLibrary.ImportAllToTarget(importConfigHeader);

        // [THEN] Last Used No is 003
        importConfigLine.Get(importConfigLine.RecordId);
        assert.AreEqual(customValueSettings.GetSetting_LastUsedNo(importConfigLine), '003', 'Last used No has to be 003');
    end;

    [Test]
    [HandlerFunctions('ImportFieldFilterDialog,LogEntriesAfterRun,ResultMessageHandler')]
    procedure GivenCustomerDataWithoutNoColumn_WhenBCNoSeriesIsUsed_ThenAssignNoOnlyOnce()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        customer: Record Customer;
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        testLibrary: Codeunit DMTTestLibrary;
        assert: Codeunit "Library Assert";
        customValueSettings: Page DMTCustomValueSettings;
    begin
        // [GIVEN] GivenCustomerDataWithoutNoColumn
        initializeImportConfigForCustomerDataWithoutNoField(importConfigHeader);

        // [GIVEN] NoSeries
        NoSeries.Code := 'DMTTest';
        NoSeries."Default Nos." := true;
        NoSeries.Insert(true);
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := '001';
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);

        // [GIVEN] BCNoSeriesIsUsed
        importConfigLine.Get(importConfigHeader.ID, customer.FieldNo("No."));
        customValueSettings.SetSetting_NoSeriesType_BCNoSeries(importConfigLine);
        customValueSettings.SetSetting_BcNoSeriesCode(importConfigLine, NoSeries.Code);
        importConfigLine."Processing Action" := importConfigLine."Processing Action"::CustomValue;
        importConfigLine."Custom Value Type" := importConfigLine."Custom Value Type"::"No.Series";
        importConfigLine.Modify();

        // [WHEN] when importing data
        testLibrary.ImportAllToTarget(importConfigHeader);

        // [THEN] Last Used No is 003
        NoSeriesLine.get(NoSeriesLine.RecordId);
        assert.AreEqual(NoSeriesLine."Last No. Used", '003', 'Last used No has to be 003');
    end;

    local procedure initializeImportConfigForCustomerDataWithoutNoField(var importConfigHeader: Record DMTImportConfigHeader)
    var
        customer: Record Customer;
        sourceFileStorage: Record DMTSourceFileStorage;
        dataTableHelper: Codeunit DMTDataTableHelper;
        testLibrary: Codeunit DMTTestLibrary;
        tempBlob: Codeunit "Temp Blob";
    begin
        if isInitialized(importConfigHeaderGlobal) then begin
            importConfigHeader := importConfigHeaderGlobal;
            exit;
        end;
        testLibrary.CreateDMTSetup();
        dataTableHelper.SetLine(1, customer.FieldCaption(Name), customer.FieldCaption(Address));
        dataTableHelper.SetLine(2, 'Sample1Name1', 'Sample1Address1');
        dataTableHelper.SetLine(3, 'Sample2Name1', 'Sample2Address1');
        dataTableHelper.SetLine(4, 'Sample3Name1', 'Sample3Address1');
        dataTableHelper.WriteDataTableToFileBlob(tempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'Customer.csv', testLibrary.GetDefaultNAVDMTLayout(), tempBlob);
        testLibrary.CreateImportConfigHeader(importConfigHeader, customer.RecordId.TableNo, sourceFileStorage);
        importConfigHeader.ImportFileToBuffer();
        testLibrary.InitTargetFields(importConfigHeader);
        testLibrary.CreateFieldMapping(importConfigHeader, false);
        importConfigHeaderGlobal := importConfigHeader;
    end;

    #region PageHandlers
    [ModalPageHandler]
    procedure ImportFieldFilterDialog(var fieldSelection: TestPage DMTFieldSelection)
    begin
        fieldSelection.OK().Invoke();
    end;

    [PageHandler]
    procedure LogEntriesAfterRun(var LogEntries: TestPage DMTLogEntries)
    begin
        LogEntries.OK().Invoke();
    end;

    [MessageHandler]
    procedure ResultMessageHandler(Message: Text[1024])
    begin
    end;
    #endregion PageHandlers

    local procedure isInitialized(importConfigHeader: Record DMTImportConfigHeader): Boolean
    begin
        exit(importConfigHeader.ID <> 0);
    end;


    var
        importConfigHeaderGlobal: Record DMTImportConfigHeader;
}