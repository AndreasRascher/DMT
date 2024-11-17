codeunit 90032 "ImportExportTest"
{
    Subtype = Test;
    TestPermissions = Disabled;
    [Test]
    procedure "GivenSetupExists_WhenSetupIsExportedAndImported_ThenSetupIsFoundOnImport"()
    var
        dmtSetup: Record DMTSetup;
        xmlBackup: Codeunit DMTXMLBackup;
        xmlFile: Codeunit "Temp Blob";
        xmlDoc: XmlDocument;
    begin
        // [GIVEN] GivenSetupExists
        dmtSetup.InsertWhenEmpty();
        dmtSetup."Use exist. mappings" := false; // init value is true
        dmtSetup.Modify();
        // [WHEN] WhenSetupIsExported 
        xmlBackup.MarkRecordForExport(dmtSetup.RecordId);
        xmlBackup.CreateExportXML(xmlFile);
        // [WHEN] WhenSetupIsImported
        XmlDocument.ReadFrom(xmlFile.CreateInStream(), xmlDoc);
        xmlBackup.ImportSetup(xmlDoc);
        // [THEN] ThenSetupIsFoundOnImport 
    end;
}