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
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table") { }
                field(ImportToTargetPercentage; Rec.ImportToTargetPercentage) { StyleExpr = Rec.ImportToTargetPercentageStyle; }
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
                    ImportConfigMgt: Codeunit DMTImportConfigMgt;
                    migrationLib: Codeunit DMTMigrationLib;
                    sourceFiles: Page DMTSourceFiles;
                    NAVExportFileNamesDict: Dictionary of [Text, Integer];
                    TargetTableID: Integer;
                begin
                    sourceFiles.LookupMode(true);
                    if sourceFiles.RunModal() <> Action::LookupOK then exit;
                    if not sourceFiles.GetSelection(tempSourceFileStorage_SELECTED) then
                        exit;

                    DMTSetup.GetRecordOnce();
                    if DMTSetup.MigrationProfil = DMTSetup.MigrationProfil::"From NAV" then
                        migrationLib.CreateNAVExportFileNameDictionary(NAVExportFileNamesDict);

                    tempSourceFileStorage_SELECTED.FindSet();
                    repeat
                        if not importConfigHeader.filterBy(tempSourceFileStorage_SELECTED) then begin
                            // Assign Source File
                            Clear(importConfigHeader);
                            importConfigHeader."Source File ID" := tempSourceFileStorage_SELECTED."File ID";
                            importConfigHeader."Source File Name" := tempSourceFileStorage_SELECTED.Name;
                            importConfigHeader.Insert(true);
                            // Assign Target Table
                            if DMTSetup.MigrationProfil = DMTSetup.MigrationProfil::"From NAV" then
                                if not NAVExportFileNamesDict.Get(tempSourceFileStorage_SELECTED.Name, TargetTableID) then
                                    Clear(TargetTableID);
                        end;

                        if (DMTSetup.MigrationProfil = DMTSetup.MigrationProfil::"From NAV") and (TargetTableID <> 0) then
                            TargetTableID := migrationLib.HandleObsoleteNAVTargetTable(TargetTableID);

                        if TargetTableID <> 0 then begin
                            importConfigHeader.Validate("Target Table ID", TargetTableID);
                            importConfigHeader.Modify(true);
                            ImportConfigMgt.PageAction_InitImportConfigLine(importConfigHeader.ID);
                        end;
                    until tempSourceFileStorage_SELECTED.Next() = 0;
                end;
            }
            action(ImportSelectedToBuffer)
            {
                Caption = 'Import to buffer table', Comment = 'de-DE=In Puffertab. importieren';
                Image = Import;
                ApplicationArea = All;
                trigger OnAction()
                var
                    TempImportConfigHeader: Record DMTImportConfigHeader temporary;
                    progress: Dialog;
                begin
                    if not GetSelection(TempImportConfigHeader) then
                        exit;
                    TempImportConfigHeader.FindSet();
                    progress.Open('######################################################1#');
                    repeat
                        progress.Update(1, TempImportConfigHeader."Source File Name");
                        TempImportConfigHeader.ImportFileToBuffer();
                    until TempImportConfigHeader.Next() = 0;
                    progress.Close();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Category5)
            {
                Caption = 'Files', Comment = 'de-DE=Dateien';
                actionref(AddFromSelectedFilesRef; AddFromSelectedFiles) { }
            }
            group(Category_Category6)
            {
                Caption = 'Migration', Comment = 'de-DE=Migration';
                actionref(ImportSelectedToBufferRef; ImportSelectedToBuffer) { }
            }
        }
    }

    procedure GetSelection(var ImportConfigHeader_SELECTED: Record DMTImportConfigHeader temporary) HasLines: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        Debug: Integer;
    begin
        Clear(ImportConfigHeader_SELECTED);
        if ImportConfigHeader_SELECTED.IsTemporary then ImportConfigHeader_SELECTED.DeleteAll();
        Debug := Rec.Count;
        ImportConfigHeader.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(ImportConfigHeader);
        Debug := ImportConfigHeader.Count;
        ImportConfigHeader.CopyToTemp(ImportConfigHeader_SELECTED);
        HasLines := ImportConfigHeader_SELECTED.FindFirst();
    end;
}