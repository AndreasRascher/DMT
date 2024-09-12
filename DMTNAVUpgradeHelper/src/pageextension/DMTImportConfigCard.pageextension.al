pageextension 50000 DMTImportConfigCard extends DMTImportConfigCard
{
    layout
    {
        // Add changes to page layout here
        modify("Separate Buffer Table Objects")
        {
            trigger OnAfterValidate()
            begin
                updateVisibleFields();
            end;
        }
        addafter(SeperateBufferObjects)
        {
            group(NAVSrcTableNo)
            {
                Visible = NAVSrcTableNo_Visible;
                ShowCaption = false;
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    begin
        updateVisibleFields();
    end;

    local procedure updateVisibleFields()
    begin
        NAVSrcTableNo_Visible := (Rec."Separate Buffer Table Objects" = Rec."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)");
    end;


    var
        NAVSrcTableNo_Visible: Boolean;

}