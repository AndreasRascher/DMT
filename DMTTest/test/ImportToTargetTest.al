codeunit 90023 ImportToTargetTest
{
    local procedure initialize()
    var
        testLibrary: Codeunit DMTTestLibrary;
        sourceFileStorage: Record DMTSourceFileStorage;
        importConfigHeader: Record DMTImportConfigHeader;
        dataTable: List of [List of [Text]];
        SalesHeader: Record "Sales Header";
    begin
        testLibrary.CreateDMTSetup();
        SalesHeader.SetFilter("Sell-to Customer No.", '<>''''');
        SalesHeader.FindFirst();
        testLibrary.BuildDataTable(dataTable, 1, 1, SalesHeader.FieldName("Document Type"));
        testLibrary.BuildDataTable(dataTable, 1, 2, SalesHeader.FieldName("No."));
        testLibrary.BuildDataTable(dataTable, 1, 3, SalesHeader.FieldName("Sell-to Customer No."));
        testLibrary.BuildDataTable(dataTable, 2, 1, 1 * SalesHeader."Document Type");
        testLibrary.BuildDataTable(dataTable, 2, 2, SalesHeader."No.");
        testLibrary.BuildDataTable(dataTable, 2, 3, SalesHeader."Sell-to Customer No.");

        TestLibrary.CreateSourceFileStorage(sourceFileStorage, 'sample.csv', testLibrary.GetDefaultNAVDMTLayout());
        TestLibrary.WriteDataTableToSourceFile(sourceFileStorage, dataTable);
        TestLibrary.CreateImportConfigHeader(importConfigHeader, SalesHeader.RecordId.TableNo, sourceFileStorage);
        TestLibrary.CreateFieldMapping(importConfigHeader, true);
        importConfigHeader.ImportFileToBuffer();
        
        testLibrary.ImportAllToTarget(importConfigHeader);
    end;
}