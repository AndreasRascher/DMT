page 90013 DMTConfirm
{
    PageType = ConfirmationDialog;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Option', Comment = 'de-DE=Optionen';
                field(DownloadURL; URL)
                {
                    Caption = 'Download URL', Locked = true;
                    ApplicationArea = All;
                }
                field(ImportOption; ImportOption)
                {
                    ApplicationArea = All;
                    Caption = 'Import Option', comment = 'de-DE=Importoptionen';
                    OptionCaption = 'Replace entries,Add entries', Comment = 'de-DE=Einträge ersetzen,Neue Einträge hinzufügen';
                }

            }
        }
    }

    actions
    {
    }

    procedure SetURL(urlNew: Text)
    begin
        URL := urlNew;
    end;

    procedure GetURL(): Text
    begin
        exit(URL);
    end;

    procedure SetImportOption(importOptionNew: Option "Replace entries","Add entries")
    begin
        ImportOption := importOptionNew;
    end;

    procedure GetImportOption(): Option "Replace entries","Add entries"
    begin
        exit(ImportOption);
    end;

    var
        URL: Text;
        ImportOption: Option "Replace entries","Add entries";
}