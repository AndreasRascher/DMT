pageextension 90014 DMTSetup extends "DMT Setup"
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
            action(ImportNAVSchema)
            {
                Caption = 'Import Schema.csv', comment = 'NAV Schema.csv importieren';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    CodeGenerator: Codeunit DMTCodeGenerator;
                begin
                    CodeGenerator.ImportNAVSchemaFile();
                end;
            }
        }
    }
}