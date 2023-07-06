pageextension 90000 "DMTSetup" extends "DMT Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(Content)
        {
            group(OnPremSettings)
            {
                Caption = 'OnPrem Settings', comment = 'de-DE=OnPrem Einstellungen';
                group(Paths)
                {
                    Caption = 'Paths', comment = 'de-DE=Pfade';
                    field("Default Export Folder Path"; Rec."Default Export Folder Path") { ApplicationArea = All; }
                    field("Backup.xml File Path"; Rec."Backup.xml File Path") { ApplicationArea = All; }
                    field("Schema File Path"; Rec."Schema.csv File Path") { ApplicationArea = All; }
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}