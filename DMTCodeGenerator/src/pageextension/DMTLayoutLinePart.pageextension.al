pageextension 90000 DMTLayoutLinePart extends DMTLayoutLinePart
{
    layout
    {
        addlast(NAV)
        {
            field(NAV_NAVDataType; Rec.NAVDataType) { ApplicationArea = All; }
            field(NAV_NAVLen; Rec.NAVLen) { ApplicationArea = All; }
            field(NAV_FieldCaption; Rec.NAVFieldCaption) { ApplicationArea = All; }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}