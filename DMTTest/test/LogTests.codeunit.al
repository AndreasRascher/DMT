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
        dataTableHelper: Codeunit dataTableHelper;
    begin
        // [GIVEN] Import field values with validate 
        testLibrary.CreateDMTSetup();
        customer.SetFilter("Payment Terms Code", '<>''''');
        customer.FindFirst();
        clear(customer."Payment Terms Id");  // empty the field to trigger the validation

        dataTableHelper.AddRecordWithCaptionsToDataTable(customer);
        dataTableHelper.WriteDataTableToFileBlob(TempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStorage,
                                            'Customer.csv',
                                            testLibrary.GetDefaultNAVDMTLayout(),
                                            TempBlob);
        testLibrary.CreateImportConfigHeader(importConfigHeader, customer.RecordId.TableNo, sourceFileStorage);
        testLibrary.CreateFieldMapping(importConfigHeader, false);
        importConfigHeader.FilterRelated(importConfigLine);

        importConfigLine.SetRange("Target Field No.", customer.FieldNo("Payment Method Code"));
        importConfigLine.FindFirst();
        importConfigLine.Validate("Validation Type", importConfigLine."Validation Type"::AlwaysValidate);
        importConfigLine.Modify();

        importConfigLine.SetRange("Target Field No.", customer.FieldNo("Payment Terms Id"));
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
        triggerLogEntry: Record DMTTriggerLogEntry;
    begin
        logEntry.FilterFor(importConfigHeader);
        logEntry.SetRange("Target ID", customer.RecordId);
        logEntry.SetRange("Entry Type", logEntry."Entry Type"::"Trigger Changes");
#pragma warning disable AA0175
        logEntry.FindFirst();
#pragma warning restore AA0175

        triggerLogEntry.SetRange("Target ID", customer.RecordId);
#pragma warning disable AA0175
        triggerLogEntry.FindFirst();
#pragma warning restore AA0175
    end;
}