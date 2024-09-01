codeunit 90028 ProzessTemplateTest
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure DefaultDownloadURLIsValidTest()
    // [FEATURE] Process template provides a default download URL
    // [SCENARIO] download URL is valid
    var
        processTemplateLib: codeunit DMTProcessTemplateLib;
        downloadedFile: Codeunit "Temp Blob";
        importOptionNew: Option "Replace entries","Add entries";
    begin
        // [GIVEN] Download URL exists
        // [WHEN] When downloading the file
        // [THEN] no error occurs
        Initialize();
        processTemplateLib.downloadProcessTemplateXLSFromGitHub(downloadedFile, importOptionNew, true);
    end;

    // Test: Copy Processing Plan Line to Process Template Setup
    [Test]
    [HandlerFunctions('SetTemplateCodePageHandler')]
    procedure CopyProcessingPlanLineToProcessTemplateSetup()
    // [FEATURE] Copy Processing Plan Line to Process Template Setup
    // [SCENARIO] Copy Processing Plan Line to Process Template Setup
    var
        processingPlan: Record DMTProcessingPlan;
        tempProcessingPlan: Record DMTProcessingPlan temporary;
        processTemplateSetup: Record "DMTProcessTemplateSetup";
        processTemplateLib: codeunit DMTProcessTemplateLib;
    begin
        // [GIVEN] Processing Plan Lines with filters exists
        Initialize();
        // [WHEN] When copying the Processing Plan Line to Process Template Setup
        processingPlan.CopyToTemp(tempProcessingPlan);
        processTemplateLib.CopySelectedLinesToProcessTemplateSetup(tempProcessingPlan);
        // [THEN] Process Template Setup is created
        processTemplateSetup.SetRange("Template Code", 'TEST_TEMPLATE');
        if processTemplateSetup.IsEmpty() then
            Error('Process Template Setup is not created');
        // [THEN] Filters are copied
        //TODO: Check if filters are copied
    end;

    [ModalPageHandler]
    procedure SetTemplateCodePageHandler(var confirm: TestPage DMTConfirm)
    begin
        confirm.TargetProcessTemplateCode.SetValue('TEST_TEMPLATE');
        confirm.Close();
    end;

    local procedure Initialize()
    var
        Contact: Record Contact;
        dataLayout: Record DMTDataLayout;
        importConfigHeader: Record DMTImportConfigHeader;
        processingPlan: Record DMTProcessingPlan;
        sourceFileStorage: Record DMTSourceFileStorage;
        dataTableHelper: Codeunit DMTDataTableHelper;
        testLibrary: Codeunit DMTTestLibrary;
        TempBlob: Codeunit "Temp Blob";
        CreatedImportConfigHeaderID: Integer;
        filter: Dictionary of [Text, Text];
    begin
        if IsInitialized then
            exit;
        // Create an import configuration for contact table
        testLibrary.CreateDMTSetup();
        dataLayout.CreateOrGetDataLayout(dataLayout, 'DMT NAV CSV Export');

        Contact.Init();
        Contact."No." := 'CompanyTest';
        Contact.Name := 'CompanyTest';
        Contact.Type := Contact.Type::Company;
        dataTableHelper.AddRecordWithCaptionsToDataTable(Contact);
        Contact.Init();
        Contact."No." := 'PersonTest';
        Contact.Name := 'PersonTest';
        Contact.Type := Contact.Type::Person;
        Contact."Company No." := 'CompanyTest';
        dataTableHelper.AddRecordWithCaptionsToDataTable(Contact);

        dataTableHelper.WriteDataTableToFileBlob(TempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'ContactSample.csv', dataLayout, TempBlob);
        testLibrary.CreateImportConfigHeader(importConfigHeader, Contact.RecordId.TableNo, sourceFileStorage);
        testLibrary.CreateFieldMapping(importConfigHeader, true);
        importConfigHeader.ImportFileToBuffer();
        CreatedImportConfigHeaderID := importConfigHeader.ID;

        // Create a Sample Processing Plan with 1 import to buffer  and 2 import lines with filters
        processingPlan.addGroupLine('ContactTestGroup', 1);
        processingPlan.setUseAutomaticIndentation(true);
        processingPlan.addImportToBufferLine(CreatedImportConfigHeaderID, 'Kontakte.csv');

        processingPlan.addImportToTargetLine(CreatedImportConfigHeaderID, 'Unternehmendskontakte importieren');
        Clear(filter);
        filter.Add('Type', '0');
        processingPlan.SaveSourceTableFilterCreatedFromTargetFilter(CreatedImportConfigHeaderID, filter);

        processingPlan.addImportToTargetLine(CreatedImportConfigHeaderID, 'Personenkontakte');
        Clear(filter);
        filter.Add('Type', '1');
        processingPlan.SaveSourceTableFilterCreatedFromTargetFilter(CreatedImportConfigHeaderID, filter);
    end;



    var
        IsInitialized: Boolean;
}