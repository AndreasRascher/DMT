tableextension 90000 "DMTSetup" extends DMTSetup
{
    fields
    {
        field(90000; "Default Export Folder Path"; Text[250])
        {
            Caption = 'Default Export Folder', comment = 'de-DE=Standard Export Ordnerpfad';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if Rec."Default Export Folder Path" <> '' then begin
                    Rec."Default Export Folder Path" := DelChr(Rec."Default Export Folder Path", '<>', '"');
                    if not Rec."Default Export Folder Path".EndsWith('\') then
                        Rec."Default Export Folder Path" += '\'
                end;
            end;

            trigger OnLookup()
            var
                DMTOnPremMgt: Codeunit DMTOnPremMgt;
            begin
                Rec."Default Export Folder Path" := DMTOnPremMgt.LookUpPath(Rec."Default Export Folder Path", true);
            end;
        }
    }
}