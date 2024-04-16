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
        ExtTextHeader1, ExtTextHeader2 : Record "Extended Text Header";
        sourceFileMgt: Codeunit DMTSourceFileMgt;
        dataTableHelper: Codeunit dataTableHelper;
        fileBlob1, fileBlob2 : Codeunit "Temp Blob";
        iStr: InStream;
        fileID1, fileID2 : Integer;
    begin
        // [GIVEN] DMT Setup exists
        initialize();
        // [GIVEN] File 1
        ExtTextHeader2.FindFirst();
        ExtTextHeader1 := ExtTextHeader2;
        ExtTextHeader2.Next();
        ExtTextHeader1.SetRecFilter();
        ExtTextHeader2.SetRecFilter();
        dataTableHelper.AddRecordWithCaptionsToDataTable(ExtTextHeader1);
        dataTableHelper.WriteDataTableToFileBlob(fileBlob1);
        // [GIVEN] File 2
        Clear(dataTableHelper);
        dataTableHelper.AddRecordWithCaptionsToDataTable(ExtTextHeader2);
        dataTableHelper.WriteDataTableToFileBlob(fileBlob2);

        // [WHEN] Adding a file to the source file storage and then adding another file with the same name
        fileBlob1.CreateInStream(iStr);
        fileID1 := sourceFileMgt.AddFileToStorage('ExtTextHeader.csv', iStr);
        fileBlob2.CreateInStream(iStr);
        fileID2 := sourceFileMgt.AddFileToStorage('ExtTextHeader.csv', iStr);
        if fileID1 <> fileID2 then
            error('The file was not overwritten');
    end;

    var
        IsInitializedGlobal: Boolean;
}