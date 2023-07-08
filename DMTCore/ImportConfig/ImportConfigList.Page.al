page 91010 DMTImportConfigList
{
    Caption = 'DMT Import Config List', Comment = 'DMT Importkonfigurationen';
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
                field("Data Layout Code"; Rec."Data Layout Code") { }
                field(ID; Rec.ID) { }
                field("Target Table Caption"; Rec."Target Table Caption") { }
                field("Target Table ID"; Rec."Target Table ID") { }
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
            action(ImportNAVSchemaFile)
            {
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    ImportCfgMgt: Codeunit ImportCfgMgt;
                begin
                    ImportCfgMgt.ImportNAVSchemaFile();
                end;

            }
        }
    }
}