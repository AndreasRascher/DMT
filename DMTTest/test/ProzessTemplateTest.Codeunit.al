codeunit 90028 ProzessTemplateTest
{
    Subtype = Test;

    [Test]
    procedure DefaultDownloadURLIsValidTest()
    // [FEATURE] Process template provides a default download URL
    // [SCENARIO] download URL is valid
    var
        processTemplateLib: codeunit DMTProcessTemplateLib;
        downloadedFile: Codeunit "Temp Blob";
        importOptionNew: Option "Replace entries","Add entries";
    begin
        // [GIVEN] Download URL exists
        // [WHEN] When downloading the file
        // [THEN] no error occurs
        Initialize();
        processTemplateLib.downloadProcessTemplateXLSFromGitHub(downloadedFile, importOptionNew, true);
    end;

    local procedure Initialize()
    begin
    end;

}