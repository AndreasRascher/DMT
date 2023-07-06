tableextension 90000 "DMTSetup" extends DMTSetup
{
    fields
    {
        field(90000; "Default Export Folder Path"; Text[250])
        {
            Caption = 'Default Export Folder', comment = 'de-DE=Standard Export Ordnerpfad';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ServerFilePath: Text;
            begin
                if Rec."Default Export Folder Path" <> '' then begin
                    Rec."Default Export Folder Path" := DelChr(Rec."Default Export Folder Path", '<>', '"');
                    if not "Default Export Folder Path".EndsWith('\') then
                        Rec."Default Export Folder Path" += '\'
                end;
                // Try Find Schema.csv
                if (Rec."Default Export Folder Path" <> '') and (Rec."Schema.csv File Path" = '') then begin
                    ServerFilePath := Rec."Default Export Folder Path" + 'Schema.csv';
                    if Exists(ServerFilePath) then
                        Rec."Schema.csv File Path" := CopyStr(ServerFilePath, 1, MaxStrLen(Rec."Schema.csv File Path"));
                end;
            end;

            trigger OnLookup()
            var
                DMTOnPremMgt: Codeunit DMTOnPremMgt;
            begin
                Rec."Default Export Folder Path" := DMTOnPremMgt.LookUpPath(Rec."Default Export Folder Path", true);
            end;
        }
        field(90001; "Schema.csv File Path"; Text[250])
        {
            Caption = 'Schema File Path', comment = 'de-DE=Pfad Schemadatei';
            trigger OnValidate()
            begin
                Rec."Schema.csv File Path" := DelChr(Rec."Schema.csv File Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DMTOnPremMgt: Codeunit DMTOnPremMgt;
            begin
                Rec."Schema.csv File Path" := DMTOnPremMgt.LookUpPath(Rec."Schema.csv File Path", false);
            end;
        }
        field(90002; "Backup.xml File Path"; Text[250])
        {
            Caption = 'Backup.xml File Path', comment = 'de-DE=Pfad Backup.xml';
            trigger OnValidate()
            begin
                Rec."Backup.xml File Path" := DelChr(Rec."Backup.xml File Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DMTOnPremMgt: Codeunit DMTOnPremMgt;
            begin
                Rec."Backup.xml File Path" := DMTOnPremMgt.LookUpPath(Rec."Backup.xml File Path", false);
            end;
        }
    }
}