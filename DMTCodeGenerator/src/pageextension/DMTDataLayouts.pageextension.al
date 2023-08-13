pageextension 90001 DMTDataLayouts extends DMTDataLayouts
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
            action(ImportNAVSchemaFile)
            {
                ApplicationArea = All;
                Image = Import;

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