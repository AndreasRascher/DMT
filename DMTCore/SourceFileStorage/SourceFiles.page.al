page 91005 DMTSourceFiles
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
                field("File ID"; Rec."File ID") { Visible = false; Editable = false; StyleExpr = LineFormatStyle; }
                field(Name; Rec.Name) { StyleExpr = LineFormatStyle; }
                field(Extension; Rec.Extension) { StyleExpr = LineFormatStyle; }
                field(SizeInKB; Rec.SizeInKB) { StyleExpr = LineFormatStyle; }
                field("DateTime"; Rec.UploadDateTime) { StyleExpr = LineFormatStyle; }
                field(SourceFileFormat; Rec.SourceFileFormat) { StyleExpr = LineFormatStyle; }
                field("Data Layout Name"; Rec."Data Layout Name")
                {
                    ShowMandatory = true;
                    StyleExpr = LineFormatStyle;
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
        LineFormatStyle := '';
        if rec.Size = 0 then
            LineFormatStyle := format(Enum::DMTFieldStyle::Grey)
    end;

    var
        LineFormatStyle: Text;
}