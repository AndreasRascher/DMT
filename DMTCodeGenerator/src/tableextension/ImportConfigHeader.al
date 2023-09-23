tableextension 90011 DMTImportConfigHeader extends DMTImportConfigHeader
{
    fields
    {
        // Add changes to table fields here
        field(90000; "NAV Src.Table No."; Integer)
        {
            Caption = 'NAV Src.Table No.', Comment = 'de-DE=NAV Tabellennr.';
            trigger OnValidate()
            var
            // ObjMgt: Codeunit DMTObjMgt;
            begin
                // ObjMgt.SetNAVTableCaptionAndTableName("NAV Src.Table No.", Rec."NAV Src.Table Caption", Rec."NAV Src.Table Name");
            end;
        }
        field(90001; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; Editable = false; }
        field(90002; "NAV Src.Table Caption"; Text[250]) { Caption = 'NAV Source Table Caption'; Editable = false; }
    }
}