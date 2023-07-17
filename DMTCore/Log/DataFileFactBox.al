page 91014 DMTImportConfigFactBox
{
    Caption = 'ImportConfig FactBox';
    PageType = ListPart;
    SourceTable = DMTLogEntry;

    layout
    {
        area(Content)
        {
            group(InfoGroups)
            {
                ShowCaption = false;
                Visible = (ViewMode = ViewMode::TableInfo);
                group(TableInfo)
                {
                    Caption = 'No. of Records in', Comment = 'de-DE=Anz. Datensätze in';
                    field("No. of Records In Trgt. Table"; CurrImportConfigHeader.GetNoOfRecordsInTrgtTable())
                    {
                        Caption = 'Target', Comment = 'de-DE=Ziel';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        begin
                            CurrImportConfigHeader.ShowTableContent(CurrImportConfigHeader."Target Table ID");
                        end;
                    }
                    field("No.of Records in Buffer Table"; CurrImportConfigHeader."No.of Records in Buffer Table")
                    {
                        Caption = 'Buffer';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        begin
                            CurrImportConfigHeader.find('='); // update if changes on main page have not been read
                            CurrImportConfigHeader.ShowBufferTable();
                        end;
                    }
                }
            }
            repeater(Log)
            {
                Caption = 'Log', Comment = 'de-DE=Protokoll';
                Visible = (ViewMode = ViewMode::Log);
                field(SystemCreatedAt; Rec.SystemCreatedAt) { ApplicationArea = All; Visible = false; }
                field(Usage; Rec.Usage) { ApplicationArea = All; }
                field("Context Description"; Rec."Context Description") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenLog)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = Log;
                Caption = 'Show Log', Comment = 'de-DE=Protoll öffnen';

                trigger OnAction()
                var
                    Log: Codeunit DMTLog;
                begin
                    Log.ShowLogEntriesFor(Rec);
                end;
            }
        }
    }

    procedure ShowAsLogAndUpdateOnAfterGetCurrRecord(importConfigHeader: Record DMTImportConfigHeader)
    begin
        ViewMode := ViewMode::Log;
        CurrImportConfigHeader.Copy(importConfigHeader);
        Rec.SetRange("Target Table ID", importConfigHeader."Target Table ID");
        Rec.SetRange("Entry Type", Rec."Entry Type"::Summary);
    end;

    procedure ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(importConfigHeader: Record DMTImportConfigHeader)
    begin
        ViewMode := ViewMode::TableInfo;
        CurrImportConfigHeader.Copy(importConfigHeader);
        Rec.SetRecFilter();
    end;

    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        ViewMode: Option " ",Log,TableInfo;
}

