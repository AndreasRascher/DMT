pageextension 90001 DMTSourceFiles extends "DMTSourceFiles"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action(AddFileFromServer)
            {
                Image = Server;
                ApplicationArea = All;

                trigger OnAction()
                var
                    setup: Record DMTSetup;
                    sourceFileMgt: Codeunit DMTSourceFileMgt;
                    fileMgt: Codeunit "File Management";
                    FileBrowser: Page "DMTFileBrowser";
                    File: File;
                    IStr: InStream;
                    selectedFilePath: Text;
                begin
                    setup.GetRecordOnce();
                    FileBrowser.SetupFileBrowser(setup."Default Export Folder Path", false);
                    FileBrowser.LookupMode(true);
                    if FileBrowser.RunModal() = Action::LookupOK then
                        selectedFilePath := FileBrowser.GetSelectedPath();
                    if selectedFilePath = '' then exit;
                    File.Open(selectedFilePath, TextEncoding::MSDos);
                    File.CreateInStream(IStr);
                    sourceFileMgt.AddFileToStorage(fileMgt.GetFileName(File.Name), IStr);
                end;
            }

        }
    }
}