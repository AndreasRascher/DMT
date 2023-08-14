page 91010 DMTImportConfigList
{
    Caption = 'DMT Import Config List', Comment = 'de-DE=DMT Importkonfigurationen';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTImportConfigHeader;
    CardPageId = DMTImportConfigCard;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                // field("Data Layout Code"; Rec."Data Layout ID") { }
                field("Source File Name"; Rec."Source File Name") { }
                field(ID; Rec.ID) { }
                field("Target Table ID"; Rec."Target Table ID") { }
                field("Target Table Caption"; Rec."Target Table Caption") { }
            }
        }
        area(FactBoxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(AddFromSelectedFiles)
            {
                Caption = 'Add File', Comment = 'de-DE=Datei hinzufügen';
                Image = Add;
                ApplicationArea = All;
                trigger OnAction()
                var
                    importConfigHeader: Record DMTImportConfigHeader;
                    DMTSetup: Record DMTSetup;
                    tempSourceFileStorage_SELECTED: Record DMTSourceFileStorage temporary;
                    sourceFiles: Page DMTSourceFiles;
                    NAVExportFileNamesDictionary: Dictionary of [Integer, Text];
                    PosNo: Integer;
                    ImportConfigMgt: Codeunit DMTImportConfigMgt;
                begin
                    sourceFiles.LookupMode(true);
                    if sourceFiles.RunModal() <> Action::LookupOK then exit;
                    if not sourceFiles.GetSelection(tempSourceFileStorage_SELECTED) then
                        exit;
                    DMTSetup.GetRecordOnce();
                    if DMTSetup.MigrationProfil = DMTSetup.MigrationProfil::"From NAV" then
                        CreateNAVExportFileNameDictionary(NAVExportFileNamesDictionary);
                    tempSourceFileStorage_SELECTED.FindSet();
                    repeat
                        if not importConfigHeader.filterBy(tempSourceFileStorage_SELECTED) then begin
                            // Assign Source File
                            Clear(importConfigHeader);
                            importConfigHeader."Source File ID" := tempSourceFileStorage_SELECTED."File ID";
                            importConfigHeader."Source File Name" := tempSourceFileStorage_SELECTED.Name;
                            importConfigHeader.Insert(true);
                            // Assign Target Table
                            if DMTSetup.MigrationProfil = DMTSetup.MigrationProfil::"From NAV" then begin
                                PosNo := NAVExportFileNamesDictionary.Values.IndexOf(tempSourceFileStorage_SELECTED.Name);
                                if PosNo > 0 then
                                    importConfigHeader.Validate("Target Table ID", NAVExportFileNamesDictionary.Keys.Get(PosNo));
                                importConfigHeader.Modify(true);
                            end;
                            if importConfigHeader."Target Table ID" <> 0 then begin
                                ImportConfigMgt.PageAction_InitImportConfigLine(importConfigHeader.ID);
                            end;
                        end;
                    until tempSourceFileStorage_SELECTED.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'Migration', Comment = 'de-DE=Migration';
            }
            group(Category_Process)
            {
                Caption = 'Files', Comment = 'de-DE=Dateien';
                ShowAs = SplitButton;
                actionref(AddFromSelectedFilesRef; AddFromSelectedFiles) { }
            }
        }
    }

    local procedure CreateNAVExportFileNameDictionary(var NAVExportFileNamesDictionary: Dictionary of [Integer, Text])
    var
        tableMetadata: Record "Table Metadata";
        FileNameFromCaption: Text;
    begin
        tableMetadata.SetRange(ID, 0, 2000000000);
        tableMetadata.FindSet();
        repeat
            FileNameFromCaption := StrSubstNo('%1.csv', ConvertStr(tableMetadata.Caption, '<>*\/|"', '_______'));
            NAVExportFileNamesDictionary.Add(tableMetadata.ID, FileNameFromCaption);
        until tableMetadata.Next() = 0;
    end;
}