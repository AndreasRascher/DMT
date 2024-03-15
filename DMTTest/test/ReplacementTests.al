codeunit 90021 ReplacementTests
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure Test2by2Replacements_MigrateSelectedRecords()
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
        TestLibrary.ImportSelectedToTarget(importConfigHeader);
        // [THEN] Replacement is done
        VerifyReplacedValuesHaveBeenWritten(salesLine);
    end;

    [Test]
    procedure Test2by2Replacements_MigrateAllRecords()
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
        sourceFileStorage: Record DMTSourceFileStorage;
        dataLayout: Record DMTDataLayout;
        TempBlob: Codeunit "Temp Blob";
        dataTable: List of [List of [Text]];
    begin
        if CreatedImportConfigHeaderID <> 0 then begin
            importConfigHeader.GET(CreatedImportConfigHeaderID);
            exit;
        end;
        TestLibrary.CreateDMTSetup();
        TestLibrary.CreateOrGetDataLayout(dataLayout, 'DMT NAV CSV Export');

        TestLibrary.BuildDataTable(dataTable, 1, 1, 'Document Type');
        TestLibrary.BuildDataTable(dataTable, 1, 2, 'Document No.');
        TestLibrary.BuildDataTable(dataTable, 1, 3, 'Line No.');
        TestLibrary.BuildDataTable(dataTable, 1, 4, 'Description');
        TestLibrary.BuildDataTable(dataTable, 1, 5, 'Description 2');
        TestLibrary.BuildDataTable(dataTable, 2, 1, '1');
        TestLibrary.BuildDataTable(dataTable, 2, 2, 'TestDocNo');
        TestLibrary.BuildDataTable(dataTable, 2, 3, '10000');
        TestLibrary.BuildDataTable(dataTable, 2, 4, 'OldValue1');
        TestLibrary.BuildDataTable(dataTable, 2, 5, 'OldValue2');
        TestLibrary.WriteDataTableToFileBlob(TempBlob, dataTable);
        TestLibrary.CreateSourceFileStorage(sourceFileStorage, 'sample.csv', dataLayout, TempBlob);
        TestLibrary.CreateImportConfigHeader(importConfigHeader, 37, sourceFileStorage);
        TestLibrary.CreateFieldMapping(importConfigHeader, true);
        importConfigHeader.ImportFileToBuffer();
        CreatedImportConfigHeaderID := importConfigHeader.ID;
    end;

    local procedure VerifyReplacedValuesHaveBeenWritten(var salesLine: Record "Sales Line")
    begin
        salesLine.GET(1, 'TestDocNo', 10000);
        salesLine.TestField(Description, 'NewValue1');
        salesLine.TestField("Description 2", 'NewValue2');
        salesLine.Delete(); // Cleanup;
    end;

    var
        TestLibrary: Codeunit DMTTestLibrary;
        CreatedImportConfigHeaderID: Integer;
}