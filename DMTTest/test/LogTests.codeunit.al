codeunit 90026 LogTests
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [HandlerFunctions('FieldSelectionHandler,LogEntriesPageHandler,MessageHandler')]
    procedure "GIVEN_ImportFieldValuesWithValidate_WHEN_OtherValuesAreWrittenAsIntended_THEN_LogEntriesExistToIndicateTheChanges"()
    var
        customer: Record Customer;
        paymentTerms: Record "Payment Terms";
        sourceFileStorage: Record DMTSourceFileStorage;
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        TempBlob: Codeunit "Temp Blob";
        testLibrary: Codeunit DMTTestLibrary;
        dataTableHelper: Codeunit DMTDataTableHelper;
    begin
        // [GIVEN] Import field values with validate 
        testLibrary.CreateDMTSetup();

        paymentTerms."Code" := '30 DAYS';
        paymentTerms."Description" := '30 Days';
        paymentTerms.Insert();

        customer."No." := 'DMT10000';
        customer.Name := 'Customer 1';
        customer."Search Name" := ''; // empty to trigger the override in the validation trigger
        customer.Insert();

        dataTableHelper.AddRecordWithCaptionsToDataTable(customer);
        dataTableHelper.WriteDataTableToFileBlob(TempBlob);
        testLibrary.AddFileToSourceFileStorage(sourceFileStorage,
                                            'Customer.csv',
                                            testLibrary.GetDefaultNAVDMTLayout(),
                                            TempBlob);
        testLibrary.CreateImportConfigHeader(importConfigHeader, customer.RecordId.TableNo, sourceFileStorage);
        testLibrary.CreateFieldMapping(importConfigHeader, false);

        importConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.SetRange("Is Key Field(Target)", false);
        importConfigLine.ModifyAll("Processing Action", importConfigLine."Processing Action"::Ignore);
        // Validate Search Name -> Validate Name -> Overrides "Search Name"
        importConfigLine.Reset();
        importConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.SetRange("Target Field No.", customer.FieldNo("Search Name"));
        importConfigLine.FindFirst();
        importConfigLine.Validate("Processing Action", importConfigLine."Processing Action"::Transfer);
        importConfigLine.Validate("Validation Type", importConfigLine."Validation Type"::AlwaysValidate);
        importConfigLine."Validation Order" := 3;
        importConfigLine.Modify();

        importConfigLine.Reset();
        importConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.SetRange("Target Field No.", customer.FieldNo(Name));
        importConfigLine.FindFirst();
        importConfigLine.Validate("Processing Action", importConfigLine."Processing Action"::Transfer);
        importConfigLine.Validate("Validation Type", importConfigLine."Validation Type"::AlwaysValidate);
        importConfigLine."Validation Order" := 4;
        importConfigLine.Modify();


        // [WHEN] Other values are written as intended 
        importConfigHeader.ImportFileToBuffer();
        importConfigHeader.Validate("Log Trigger Changes", true);
        importConfigHeader.Modify();
        TestLibrary.ImportAllToTarget(importConfigHeader);
        // [THEN] Log entries exist to indicate the changes 
        VerifyLogValuesOfTriggerChangesExist(importConfigHeader, customer);
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

    local procedure VerifyLogValuesOfTriggerChangesExist(importConfigHeader: Record DMTImportConfigHeader; customer: Record Customer)
    var
        logEntry: Record DMTLogEntry;
        triggerLogEntry: Record DMTTriggerLogEntry;
    begin
        triggerLogEntry.SetRange("Target ID", customer.RecordId);
#pragma warning disable AA0175
        triggerLogEntry.FindFirst();
#pragma warning restore AA0175

        logEntry.FilterFor(importConfigHeader);
        logEntry.SetRange("Target ID", customer.RecordId);
        logEntry.SetRange("Entry Type", logEntry."Entry Type"::"Trigger Changes");
#pragma warning disable AA0175
        logEntry.FindFirst();
#pragma warning restore AA0175

    end;
}