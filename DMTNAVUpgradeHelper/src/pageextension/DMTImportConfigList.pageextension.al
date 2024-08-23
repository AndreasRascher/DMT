pageextension 90013 ImportConfigList extends DMTImportConfigList
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
            action(ExportALObjects)
            {
                Image = ExportFile;
                ApplicationArea = All;
                Caption = 'Download buffer table objects', Comment = 'de-DE=Puffertabellen Objekte runterladen';
                trigger OnAction()
                var
                    codeGenerator: Codeunit DMTCodeGenerator;
                begin
                    codeGenerator.DownloadAllALDataMigrationObjects();
                end;
            }
        }
        addlast(Category_Category6)
        {
            actionref(ExportALObjectsRef; ExportALObjects) { }
        }
    }
}