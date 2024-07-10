page 50145 DMTSourceFiles
{
    Caption = 'DMT Source Files', Comment = 'de-DE=DMT Quelldateien';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTSourceFileStorage;
    SourceTableView = sorting(Name);
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("File ID"; Rec."File ID") { Visible = false; Editable = false; }
                field(Name; Rec.Name) { }
                field(Extension; Rec.Extension) { }
                field(SizeInKB; Rec.SizeInKB) { StyleExpr = SizeInKBStyle; }
                field("DateTime"; Rec.UploadDateTime) { }
                field(SourceFileFormat; Rec.SourceFileFormat) { }
                field("Data Layout Name"; Rec."Data Layout Name")
                {
                    ShowMandatory = true;

                    TableRelation = DMTDataLayout where(SourceFileFormat = field(SourceFileFormat));

                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.DataLayoutName_OnAfterLookup(Selected);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.DataLayoutName_OnValidate();
                    end;
                }
            }
        }
        area(FactBoxes) { }
    }

    actions
    {
        area(Processing)
        {
            action(UploadFile)
            {
                Image = MoveUp;
                Caption = 'Upload File', Comment = 'de-DE=Datei hochladen';
                ApplicationArea = All;
                trigger OnAction()
                var
                    SourceFileMgt: Codeunit DMTSourceFileMgt;
                begin
                    SourceFileMgt.UploadFileIntoFileStorage();
                end;
            }
            action(DownloadFile)
            {
                Image = Download;
                Caption = 'Download File', Comment = 'de-DE=Datei runterladen';
                ApplicationArea = All;
                trigger OnAction()
                var
                    SourceFileMgt: Codeunit DMTSourceFileMgt;
                begin
                    SourceFileMgt.DownloadSourceFile(Rec);
                end;
            }
            action(ImportFileFromWebDAV)
            {
                Image = Web;
                Caption = 'Import File from WebDAV', Comment = 'de-DE=Datei von WebDAV importieren';
                ApplicationArea = All;
                trigger OnAction()
                var
                    sourceFileMgt: Codeunit DMTSourceFileMgt;
                    TempBlob: Codeunit "Temp Blob";
                    WebDAVFileBrowser: Page WebDAVFileBrowser;
                    IStr: InStream;
                    OStr: OutStream;
                    RunAction: Action;
                    Length: Integer;
                begin
                    // WebDAVFileBrowser.LookupMode(true);
                    RunAction := WebDAVFileBrowser.RunModal();
                    if WebDAVFileBrowser.hasSelectedFile() then begin
                        TempBlob.CreateInStream(IStr);
                        WebDAVFileBrowser.downloadSelectedFile(IStr);
                        TempBlob.CreateOutStream(OStr);
                        CopyStream(OStr, IStr);
                        Length := TempBlob.Length();
                        TempBlob.CreateInStream(IStr);
                        sourceFileMgt.AddFileToStorage(WebDAVFileBrowser.getSetSelectedRecord().Name, IStr);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Upload; UploadFile) { }
        }
    }

    procedure GetSelection(var SourceFileStorage_SELECTED: Record DMTSourceFileStorage temporary) HasLines: Boolean
    var
        SourceFileStorage: Record DMTSourceFileStorage;
        Debug: Integer;
    begin
        Clear(SourceFileStorage_SELECTED);
        if SourceFileStorage_SELECTED.IsTemporary then SourceFileStorage_SELECTED.DeleteAll();
        Debug := Rec.Count;
        SourceFileStorage.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(SourceFileStorage);
        Debug := SourceFileStorage.Count;
        SourceFileStorage.CopyToTemp(SourceFileStorage_SELECTED);
        HasLines := SourceFileStorage_SELECTED.FindFirst();
    end;

    trigger OnAfterGetRecord()
    begin
        SizeInKBStyle := '';
        if rec.Size = 0 then
            SizeInKBStyle := format(Enum::DMTFieldStyle::"Red + Italic")
    end;

    var
        SizeInKBStyle: Text;
}