page 50025 WebDAVFileBrowser
{
    Caption = 'WebDAV File Browser', Comment = 'de-DE=WebDAV Datei Browser';
    PageType = Worksheet;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = DMTWebDAVFile;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Authentication)
            {
                Caption = 'Authentication', Comment = 'de-DE=Authentifizierung';
                field(serverUrl; serverUrl)
                {
                    Caption = 'Server URL', Locked = true;
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        webDAVClient.SplitUrl(serverUrl, serverUrl, serverRelativeUrl);
                    end;
                }
                field(serverRelativeUrl; serverRelativeUrl) { Caption = 'Server relative URL', Locked = true; ApplicationArea = All; }
                field(UserName; UserName)
                {
                    Caption = 'User Name', Comment = 'de-DE=Benutzername';
                    ApplicationArea = All;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        serverRelativeUrl := StrSubstNo(UserFilesRelPathLbl, UserName);
                    end;
                }
                field(Password; Password)
                {
                    Caption = 'Password', Comment = 'de-DE=Passwort';
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ExtendedDatatype = Masked;
                }
            }
            group(SelectedFile)
            {
                Caption = 'Selected File', Comment = 'de-DE=Ausgewählte Datei';
                grid(inner)
                {
                    ShowCaption = false;
                    field(SelectedFilePath; selectedRecordGlobal.Path)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
            }
            repeater(Group)
            {
                Editable = false;
                field("Is Folder"; Rec."Is Folder") { ApplicationArea = All; }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Width = 100;
                    trigger OnDrillDown()
                    var
                        response: Text;
                    begin
                        if Rec."Is Folder" then begin
                            serverRelativeUrl := Rec.Path;
                            webDAVClient.setBasicAuth(UserName, Password);
                            webDAVClient.SetRequestUri(serverUrl, serverRelativeUrl);
                            if webDAVClient.PROPFIND_Request(response) then begin
                                webDAVClient.ReadFileStructure(Rec, response);
                                // CurrPage.Update();
                            end;
                        end else begin
                            selectedRecordGlobal := Rec;
                        end;
                    end;
                }
                field(LastModified; Rec.LastModified) { ApplicationArea = All; }
                field(Size; Rec.Size) { ApplicationArea = All; Width = 10; BlankZero = true; }
                field(Path; Rec.Path) { ApplicationArea = All; Width = 200; }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Image = Refresh;
                trigger OnAction()
                var
                    response: Text;
                begin
                    webDAVClient.setBasicAuth(UserName, Password);
                    webDAVClient.SetRequestUri(serverUrl, serverRelativeUrl);
                    webDAVClient.PROPFIND_Request(response);
                    webDAVClient.ReadFileStructure(Rec, response);
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            actionref(RefreshREf; Refresh)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        loadSettingsFromObjectOptions();
        serverRelativeUrl := StrSubstNo(UserFilesRelPathLbl, UserName);
    end;

    trigger OnClosePage()
    begin
        saveSettingsToObjectOptions();
    end;

    procedure getSetSelectedRecord() selectedRecord: Record DMTWebDAVFile;
    begin
        exit(selectedRecordGlobal);
    end;

    procedure downloadSelectedFile(var iStr: InStream)
    begin
        webDAVClient.setBasicAuth(UserName, Password);
        webDAVClient.SetRequestUri(serverUrl, selectedRecordGlobal.Path);
        webDAVClient.GET_Request(iStr);
    end;

    internal procedure hasSelectedFile(): Boolean
    begin
        if selectedRecordGlobal."Is Folder" then
            exit(false);
        if selectedRecordGlobal.Path = '' then
            exit(false);
        if selectedRecordGlobal.Name = '' then
            exit(false);
        exit(true);
    end;

    local procedure loadSettingsFromObjectOptions()
    var
        ObjectOptions: Record "Object Options";
        IStr: InStream;
        JOBj: JsonObject;
        JToken: JsonToken;
        pageID: Integer;
        pageName: TExt;
    begin
        pageName := CurrPage.ObjectId(false);
        Evaluate(pageID, CopyStr(CurrPage.ObjectId(false), 6));
        if not ObjectOptions.Get('WebDAVFileBrowser', pageID, ObjectOptions."Object Type"::Page, UserId, CompanyName) then
            exit;
        ObjectOptions.CalcFields("Option Data");
        if not ObjectOptions."Option Data".HasValue then
            exit;
        ObjectOptions."Option Data".CreateInStream(IStr);
        JOBj.ReadFrom(IStr);
        if JOBj.Get('baseUrl', JToken) then
            serverUrl := JToken.AsValue().AsText();
        if JOBj.Get('UserName', JToken) then
            UserName := JToken.AsValue().AsText();
        if JOBj.Get('Password', JToken) then
            Password := JToken.AsValue().AsText();
    end;

    local procedure saveSettingsToObjectOptions()
    var
        ObjectOptions: Record "Object Options";
        pageID: Integer;
        OStr: OutStream;
        JObj: JsonObject;
    begin
        if serverUrl = '' then
            exit;
        Evaluate(pageID, CopyStr(CurrPage.ObjectId(false), 6));
        if not ObjectOptions.Get('WebDAVFileBrowser', pageID, ObjectOptions."Object Type"::Page, UserId, CompanyName) then begin
            ObjectOptions."Parameter Name" := 'WebDAVFileBrowser';
            ObjectOptions."Object ID" := pageID;
            ObjectOptions."Object Type" := ObjectOptions."Object Type"::Page;
            ObjectOptions."User Name" := CopyStr(UserId, 1, MaxStrLen(ObjectOptions."User Name"));
            ObjectOptions."Company Name" := CopyStr(CompanyName, 1, MaxStrLen(ObjectOptions."Company Name"));
            ObjectOptions.Insert();
        end;

        Clear(ObjectOptions."Option Data");
        ObjectOptions."Option Data".CreateOutStream(OStr);
        JOBj.Add('baseUrl', serverUrl);
        JOBj.Add('UserName', UserName);
        JOBj.Add('Password', Password);
        JOBj.WriteTo(OStr);
        ObjectOptions.Modify();
    end;

    var
        selectedRecordGlobal: Record DMTWebDAVFile;
        webDAVClient: Codeunit DMTWebDAVClient;
        UserFilesRelPathLbl: Label '/remote.php/dav/files/%1/', locked = true;
        Password, serverRelativeUrl, serverUrl, UserName : Text;

}