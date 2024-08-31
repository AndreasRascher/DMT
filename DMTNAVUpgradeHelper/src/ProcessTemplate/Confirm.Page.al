page 90013 DMTConfirm
{
    PageType = ConfirmationDialog;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(DownloadTemplateOptions)
            {
                Visible = (Mode = Mode::DownloadDefaultTemplateMode);
                Caption = 'Option', Comment = 'de-DE=Optionen';
                field(DownloadURL; URL)
                {
                    Caption = 'Download URL', Locked = true;
                    ApplicationArea = All;
                }
                field(ImportOption; DownloadDefautTemplate_ImportOption)
                {
                    ApplicationArea = All;
                    Caption = 'Import Option', comment = 'de-DE=Importoptionen';
                    OptionCaption = 'Replace entries,Add entries', Comment = 'de-DE=Einträge ersetzen,Neue Einträge hinzufügen';
                }
            }
            group(SelectTargetTemplateCode)
            {
                Visible = (Mode = Mode::SelectTargetTemplateCodeMode);
                Caption = 'Option', Comment = 'de-DE=Optionen';
                field(TargetProcessTemplateCode; TargetProcessTemplateCode)
                {
                    Caption = 'Process Template Code', Comment = 'de-DE=Prozessvorlagen-Code';
                    ToolTip = 'Selection of an existing process template: Entries will be added.\nInput of a new process template code: New process template will be created.',
                    Comment = 'de-DE= Auswahl einer vorhandene Prozessvorlage: Einträge werden hinzugefügt.\Eingabe eines neuen Prozessvorlagen-Codes: Neue Prozessvorlage wird erstellt.';
                    ApplicationArea = All;
                    // ToDo: LookUp für vorhandene Prozessvorlagen, ohne Validate der TableRelation
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
        DownloadDefautTemplate_ImportOption := importOptionNew;
    end;

    procedure GetImportOption(): Option "Replace entries","Add entries"
    begin
        exit(DownloadDefautTemplate_ImportOption);
    end;

    procedure GetTargetProcessTemplateCode(): Code[150]
    begin
        exit(TargetProcessTemplateCode);
    end;

    procedure SetMode_DownloadDefaultTemplateMode()
    begin
        Mode := Mode::DownloadDefaultTemplateMode;
    end;

    procedure SetMode_SelectTargetTemplateCodeMode()
    begin
        Mode := Mode::SelectTargetTemplateCodeMode;
    end;


    var
        URL: Text;
        Mode: Option DownloadDefaultTemplateMode,SelectTargetTemplateCodeMode;
        DownloadDefautTemplate_ImportOption: Option "Replace entries","Add entries";
        TargetProcessTemplateCode: Code[150];
}