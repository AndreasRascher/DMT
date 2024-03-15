codeunit 90024 SourceFileStorageTests
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
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
        SalesHeader1, SalesHeader2 : Record "Sales Header";
        sourceFileMgt: Codeunit DMTSourceFileMgt;
        testLibrary: Codeunit DMTTestLibrary;
        fileBlob1, fileBlob2 : Codeunit "Temp Blob";
        iStr: InStream;
        dataTable1, dataTable2 : List of [List of [Text]];
        fileID1, fileID2 : Integer;
    begin
        // [GIVEN] DMT Setup exists
        initialize();
        // [GIVEN] File 1
        SalesHeader1.SetFilter("Sell-to Customer No.", '<>''''');
        SalesHeader1 := SalesHeader2;
        SalesHeader1.SetRecFilter();
        testLibrary.BuildDataTable(dataTable1, SalesHeader1.RecordId.TableNo, SalesHeader1.GetView());
        testLibrary.WriteDataTableToFileBlob(fileBlob1, dataTable1);
        // [GIVEN] File 2
        SalesHeader2 := SalesHeader1;
        SalesHeader2.SetFilter("Sell-to Customer No.", '<>''''');
        SalesHeader2.Find('>');
        SalesHeader2.SetRecFilter();
        testLibrary.BuildDataTable(dataTable2, SalesHeader2.RecordId.TableNo, SalesHeader2.GetView());
        testLibrary.WriteDataTableToFileBlob(fileBlob2, dataTable2);

        // [WHEN] Adding a file to the source file storage and then adding another file with the same name
        fileBlob1.CreateInStream(iStr);
        fileID1 := sourceFileMgt.AddFileToStorage('SalesHeader.csv', iStr);
        fileBlob2.CreateInStream(iStr);
        fileID2 := sourceFileMgt.AddFileToStorage('SalesHeader.csv', iStr);
        if fileID1 = fileID2 then
            error('The file was not overwritten');
    end;

    var
        IsInitializedGlobal: Boolean;
}