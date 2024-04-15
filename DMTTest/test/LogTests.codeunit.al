codeunit 90026 LogTests
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure "GIVEN_ImportFieldValuesWithValidate_WHEN_OtherValuesAreWrittenAsIntended_THEN_LogEntriesExistToIndicateTheChanges"()
    var
        customer: Record Customer;
        sourceFileStorage: Record DMTSourceFileStorage;
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        TempBlob: Codeunit "Temp Blob";
        testLibrary: Codeunit DMTTestLibrary;
        dataTable: List of [List of [Text]];
    begin
        // [GIVEN] Import field values with validate 
        testLibrary.CreateDMTSetup();
        customer.SetFilter("Payment Method Code", '<>''''');
        customer.FindFirst();
        customer.SetRecFilter();
        testLibrary.BuildDataTable(dataTable, customer.RecordId.TableNo, customer.GetView());
        testLibrary.WriteDataTableToFileBlob(TempBlob, dataTable);
        testLibrary.AddFileToSourceFileStorage(sourceFileStorage,
                                            'Customer.csv',
                                            testLibrary.GetDefaultNAVDMTLayout(),
                                            TempBlob);
        testLibrary.CreateImportConfigHeader(importConfigHeader, Database::"Sales Header", sourceFileStorage);
        testLibrary.CreateFieldMapping(importConfigHeader, false);
        importConfigHeader.FilterRelated(importConfigLine);

        importConfigLine.SetRange("Target Field No.", customer.FieldNo("Payment Method Code"));
        importConfigLine.FindFirst();
        importConfigLine.Validate("Validation Type", importConfigLine."Validation Type"::AlwaysValidate);
        importConfigLine.Modify();

        importConfigLine.SetRange("Target Field No.", customer.FieldNo("Payment Method Id"));
        importConfigLine.FindFirst();
        importConfigLine.Validate("Validation Type", importConfigLine."Validation Type"::AlwaysValidate);
        importConfigLine.Modify();

        // [WHEN] Other values are written as intended 
        TestLibrary.ImportSelectedToTarget(importConfigHeader);
        // [THEN] Log entries exist to indicate the changes 
        VerifyLogValuesOfTriggerChangesExist(importConfigHeader, customer);
    end;

    local procedure VerifyLogValuesOfTriggerChangesExist(importConfigHeader: Record DMTImportConfigHeader; customer: Record Customer)
    var
        logEntry: Record DMTLogEntry;
    begin
        logEntry.FilterFor(importConfigHeader);
        logEntry.SetRange("Target ID", customer.RecordId);
        logEntry.SetRange("Entry Type", logEntry."Entry Type"::"Trigger Changes");
        logEntry.FindSet();
    end;
}