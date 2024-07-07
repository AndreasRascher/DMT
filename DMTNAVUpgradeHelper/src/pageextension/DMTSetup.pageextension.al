pageextension 90014 DMTSetup extends "DMT Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter(MigrationSettings)
        {
            group("Object Generator")
            {
                Caption = 'Object Generator', Comment = 'de-DE=Objekte generieren';
                group(ObjectIDs)
                {
                    Caption = 'ID Ranges for ...', Comment = 'de-DE=ID Bereiche für ...';
                    field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables")
                    {
                        Caption = 'Buffer Tables', Comment = 'de-DE=Puffertabellen';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts")
                    {
                        Caption = 'XMLPorts (Import)', Comment = 'de-DE=XMLPorts (Import)';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Exports include FlowFields"; Rec."Exports include FlowFields") { ApplicationArea = All; }
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action(ImportNAVSchema)
            {
                Caption = 'Import Schema.csv', comment = 'NAV Schema.csv importieren';
                ApplicationArea = All;
                Image = DataEntry;

                trigger OnAction()
                var
                    CodeGenerator: Codeunit DMTCodeGenerator;
                begin
                    CodeGenerator.ImportNAVSchemaFile();
                end;
            }
        }
        addlast(Promoted)
        {
            group(NAV)
            {
                Caption = 'NAV', Locked = true;
                actionref(ImportNAVSchemaRef; ImportNAVSchema) { }
            }
        }
    }
}