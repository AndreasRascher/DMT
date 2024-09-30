// ToDo:
// Wenn beim Feldupdate ein Zieldatensatz nicht existiert, dann soll der als geskipped gekennzeichnet werden
// Nur wenn ein Zieldatensatz existiert und kein Fehler auftreteten ist , dann ist das ok

codeunit 90024 SourceFileStorageTests
{
    Subtype = Test;
    TestPermissions = Disabled;
    local procedure initialize()
    var
        testLibrary: Codeunit DMTTestLibrary;
    begin
        if IsInitializedGlobal then
            exit;
        testLibrary.CreateDMTSetup();
        IsInitializedGlobal := true;
    end;

    [Test]
    procedure WHEN_ImportingSameFileTwice_THEN_TheOldFileIsOverwriten()
    var
        Customer, Customer2 : Record Customer;
        sourceFileMgt: Codeunit DMTSourceFileMgt;
        dataTableHelper: Codeunit DMTDataTableHelper;
        fileBlob1, fileBlob2 : Codeunit "Temp Blob";
        fileID1, fileID2 : Integer;
    begin
        // [GIVEN] DMT Setup exists
        initialize();
        // [GIVEN] File 1
        customer."No." := 'DMT10000';
        Customer.Name := 'Customer 1';
        dataTableHelper.AddRecordWithCaptionsToDataTable(Customer);
        dataTableHelper.WriteDataTableToFileBlob(fileBlob1);
        // [GIVEN] File 2
        Customer2."No." := 'DMT10001';
        Customer2.Name := 'Customer 2';
        Clear(dataTableHelper);
        dataTableHelper.AddRecordWithCaptionsToDataTable(Customer2);
        dataTableHelper.WriteDataTableToFileBlob(fileBlob2);

        // [WHEN] Adding a file to the source file storage and then adding another file with the same name
        fileID1 := sourceFileMgt.AddFileToStorage('Customer.csv', fileBlob1);
        fileID2 := sourceFileMgt.AddFileToStorage('Customer.csv', fileBlob2);
        if fileID1 <> fileID2 then
            error('The file was not overwritten');
    end;

    var
        IsInitializedGlobal: Boolean;
}