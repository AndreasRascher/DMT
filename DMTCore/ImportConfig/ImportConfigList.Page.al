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
                field("Data Layout Code"; Rec."Data Layout ID") { }
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
            action(ImportNAVSchemaFile)
            {
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    ImportCfgMgt: Codeunit DMTImportConfigMgt;
                begin
                    ImportCfgMgt.ImportNAVSchemaFile();
                end;

            }
        }
    }
}