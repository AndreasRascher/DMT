page 50010 DMTImportConfigList
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
                field("Buffer Table ID"; Rec."Buffer Table ID") { StyleExpr = Rec.BufferTableIDStyle; Visible = false; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { StyleExpr = Rec.ImportXMLPortIDStyle; Visible = false; }
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
                    tempSourceFileStorage_SELECTED: Record DMTSourceFileStorage temporary;
                    importConfigMgt: Codeunit DMTImportConfigMgt;
                    sourceFiles: Page DMTSourceFiles;
                begin
                    sourceFiles.LookupMode(true);
                    if sourceFiles.RunModal() <> Action::LookupOK then exit;
                    if not sourceFiles.GetSelection(tempSourceFileStorage_SELECTED) then
                        exit;
                    importConfigMgt.addImportConfigForSelectedSourceFiles(tempSourceFileStorage_SELECTED);
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
            action(updateImportToTargetPercentageInSelectedLines)
            {
                Caption = 'Update Migrated % (Selected Lines)', Comment = 'de-DE=Migriert % aktualiseren (markierte Zeilen)';
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
                        TempImportConfigHeader.BufferTableMgt().updateImportToTargetPercentage();
                    until TempImportConfigHeader.Next() = 0;
                    progress.Close();
                    if rec.get(rec.RecordId) then;
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
                actionref(updateImportToTargetPercentageInSelectedLinesRef; updateImportToTargetPercentageInSelectedLines) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.UpdateIndicators();
    end;

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