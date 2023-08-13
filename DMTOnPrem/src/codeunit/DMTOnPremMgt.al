codeunit 90002 "DMTOnPremMgt"
{
    procedure LookUpPath(CurrentPath: Text; LookUpFolder: Boolean) ResultPath: Text[250]
    var
        FileBrowser: Page "DMTFileBrowser";
    begin
        DMTSetup.GetRecordOnce();
        if CurrentPath = '' then
            CurrentPath := DMTSetup."Default Export Folder Path";
        FileBrowser.SetupFileBrowser(CurrentPath, LookUpFolder);
        FileBrowser.LookupMode(true);
        if not (FileBrowser.RunModal() = Action::LookupOK) then
            exit(CopyStr(CurrentPath, 1, 250));
        ResultPath := CopyStr(FileBrowser.GetSelectedPath(), 1, MaxStrLen(ResultPath));
    end;

    var
        DMTSetup: Record "DMTSetup";

}