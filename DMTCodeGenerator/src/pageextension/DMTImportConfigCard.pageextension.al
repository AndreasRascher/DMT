pageextension 90011 DMTImportConfigCard extends DMTImportConfigCard
{
    layout
    {
        // Add changes to page layout here
        addlast(SeperateBufferObjects)
        {
            field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}