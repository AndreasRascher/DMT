codeunit 90021 ReplacementTests
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [HandlerFunctions('ImportToTargetFilterPageHandler,LogEntriesPageHandler,MessageHandler')]
    procedure Test2by2Replacements()
    var
        importConfigHeader: Record DMTImportConfigHeader;
        salesLine: Record "Sales Line";
    begin
        // [GIVEN] Setup exists, DataLayout exists, Source File exists         
        // [GIVEN] Import Config Header exists, Field Mapping exists, Buffer exists
        CreateImportConfigWithSampleSourceFileAndFieldMapping(importConfigHeader);
        // [GIVEN] Replacement Setup exists
        TestLibrary.CreateReplacementSetup2by2('2x2', importConfigHeader);
        TestLibrary.ValidateAssignmentsExitsFor(importConfigHeader);
        TestLibrary.ValidateRulesExitsFor('2x2');

        // [WHEN] Migrate Data
        TestLibrary.ImportAllToTarget(importConfigHeader);
        // [THEN] Replacement is done
        VerifyReplacedValuesHaveBeenWritten(salesLine);
    end;

    [Test]
    [HandlerFunctions('ImportToTargetFilterPageHandler,LogEntriesPageHandler,MessageHandler')]
    procedure Test2by2Replacements_UpdateRecordsWithSelectedFields()
    var
        importConfigHeader: Record DMTImportConfigHeader;
        salesLine: Record "Sales Line";
        SelectedFieldsNoFilter: Text;
    begin
        // [GIVEN] Setup exists, DataLayout exists, Source File exists         
        // [GIVEN] Import Config Header exists, Field Mapping exists, Buffer exists
        CreateImportConfigWithSampleSourceFileAndFieldMapping(importConfigHeader);
        // [GIVEN] Replacement Setup exists
        TestLibrary.CreateReplacementSetup2by2('2x2', importConfigHeader);
        TestLibrary.ValidateAssignmentsExitsFor(importConfigHeader);
        TestLibrary.ValidateRulesExitsFor('2x2');
        // [GIVEN] Record for Update exists
        salesLine."Document Type" := 1;
        salesLine."Document No." := 'TestDocNo';
        salesLine."Line No." := 10000;
        if not salesLine.get(salesLine.RecordId) then
            salesLine.Insert(true);
        salesLine.Description := 'OldValue1';
        salesLine."Description 2" := 'OldValue2';
        salesLine.Modify();

        // [WHEN] Migrate Data
        SelectedFieldsNoFilter := StrSubstNo('%1|%2', salesLine.FieldNo(Description), salesLine.FieldNo("Description 2"));
        TestLibrary.UpdateSelectedFieldsInTarget(importConfigHeader, SelectedFieldsNoFilter);
        // [THEN] Replacement is done
        VerifyReplacedValuesHaveBeenWritten(salesLine);
    end;

    local procedure CreateImportConfigWithSampleSourceFileAndFieldMapping(var importConfigHeader: Record DMTImportConfigHeader)
    var
        dataLayout: Record DMTDataLayout;
        sourceFileStorage: Record DMTSourceFileStorage;
        dataTableHelper: Codeunit DMTDataTableHelper;
        TempBlob: Codeunit "Temp Blob";
    begin
        if CreatedImportConfigHeaderID <> 0 then begin
            importConfigHeader.GET(CreatedImportConfigHeaderID);
            exit;
        end;
        TestLibrary.CreateDMTSetup();
        dataLayout.CreateOrGetDataLayout(dataLayout, 'DMT NAV CSV Export');

        dataTableHelper.setDataTableField(1, 1, 'Document Type');
        dataTableHelper.setDataTableField(1, 2, 'Document No.');
        dataTableHelper.setDataTableField(1, 3, 'Line No.');
        dataTableHelper.setDataTableField(1, 4, 'Description');
        dataTableHelper.setDataTableField(1, 5, 'Description 2');
        dataTableHelper.setDataTableField(2, 1, '1');
        dataTableHelper.setDataTableField(2, 2, 'TestDocNo');
        dataTableHelper.setDataTableField(2, 3, '10000');
        dataTableHelper.setDataTableField(2, 4, 'OldValue1');
        dataTableHelper.setDataTableField(2, 5, 'OldValue2');
        dataTableHelper.WriteDataTableToFileBlob(TempBlob);
        TestLibrary.AddFileToSourceFileStorage(sourceFileStorage, 'sample.csv', dataLayout, TempBlob);
        TestLibrary.CreateImportConfigHeader(importConfigHeader, 37, sourceFileStorage);
        importConfigHeader.ImportFileToBuffer();
        TestLibrary.CreateFieldMapping(importConfigHeader, true);
        CreatedImportConfigHeaderID := importConfigHeader.ID;
    end;

    local procedure VerifyReplacedValuesHaveBeenWritten(var salesLine: Record "Sales Line")
    begin
        salesLine.GET(1, 'TestDocNo', 10000);
        salesLine.TestField(Description, 'NewValue1');
        salesLine.TestField("Description 2", 'NewValue2');
        salesLine.Delete(); // Cleanup;
    end;

    [FilterPageHandler]
    procedure ImportToTargetFilterPageHandler(var Record1: RecordRef): Boolean;
    begin
        exit(true); // OK to proceed
        // If this procedure isn't called, no filter page is raised and the test fails
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

    var
        TestLibrary: Codeunit DMTTestLibrary;
        CreatedImportConfigHeaderID: Integer;
}