page 50140 "DMT Setup"
{
    Caption = 'Data Migration Tool Setup', Comment = 'de-DE=Data Migration Tool Einrichtung';
    AdditionalSearchTerms = 'DMT Setup', Comment = 'de-DE=DMT Einrichtung';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTSetup;

    layout
    {
        area(Content)
        {
            group(MigrationSettings)
            {
                Caption = 'Migration Settings', Comment = 'de-DE=Migration Einstellungen';
                field(MigrationProfil; Rec.MigrationProfil) { ToolTipML = DEU = 'Aus NAV: ''DMT NAV CSV Export'' als Standard Datenlayout. Felder Mapping auf Basis bekannter NAV Feldnamen. Tabellen-ID Mapping auf Basis bekannter NAV zu BC Tabellenänderungen.'; }
            }
            group(Debugging)
            {
                field(SessionID; SessionId())
                {
                    ApplicationArea = All;
                    Caption = 'SessionID', Locked = true;
                    trigger OnAssistEdit()
                    var
                        activeSession: Record "Active Session";
                        Choice: Integer;
                        NoOfChoices: Integer;
                        SessionListID: Integer;
                        StopSessionInstructionLbl: Label 'Select which session to stop:\<Session ID> - <User ID> - <Client Type>- <Login Datetime>', Comment = 'de-DE=Wählen Sie eine Session zum Beenden aus:\<Session ID> - <User ID> - <Client Type> - <Login Datetime>';
                        StopAllOtherSessionsLbl: Label 'Stop all other sessions', Comment = 'de-DE=Alle anderen Sessions stoppen';
                        SessionList: List of [Integer];
                        Choices: Text;
                    begin
                        if activeSession.FindSet() then
                            repeat
                                Choices += StrSubstNo('%1 - %2 - %3 - %4,', activeSession."Session ID", activeSession."User ID", activeSession."Client Type", activeSession."Login Datetime");
                                NoOfChoices += 1;
                                SessionList.Add(activeSession."Session ID");
                            until activeSession.Next() = 0;
                        Choices += StopAllOtherSessionsLbl + ',';
                        Choices += 'Cancel';
                        Choice := StrMenu(Choices, NoOfChoices + 2, StopSessionInstructionLbl);
                        if Choice <> 0 then
                            case true of
                                //StopAllOtherSessions
                                (Choice = NoOfChoices + 1):
                                    begin
                                        foreach SessionListID in SessionList do begin
                                            if SessionId() <> SessionListID then
                                                if StopSession(SessionListID) then;
                                        end;
                                    end;
                                //Cancel
                                (Choice = NoOfChoices + 2):
                                    begin

                                    end;
                            end;
                        if Choice <= NoOfChoices then begin
                            if Choice <> 0 then // Cancel Menu
                                Message('%1', StopSession(SessionList.Get(Choice)));
                        end;
                    end;
                }
                field(UserID; UserId) { ApplicationArea = All; Caption = 'User ID', Locked = true; }
            }
            group("Field Mapping")
            {
                Caption = 'Mapping fields', Comment = 'de-DE=Mapping der Felder';
                field("Use exist. mappings"; Rec."Use exist. mappings") { }
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            action(ClearGenBuffer)
            {
                Caption = 'Delete Gen. Buffer Table Lines', Comment = 'de-DE=Alle Zeilen in gen. Puffertabelle löschen';
                ApplicationArea = All;
                Image = ListPage;
                trigger OnAction()
                var
                    genBuffTable: Record DMTGenBuffTable;
                    blobStorage: Record DMTBlobStorage;
                    deleteGenBufferLinesQst: Label 'Delete all lines in Gen. Buffer Table?', Comment = 'de-DE=Alle Zeilen in gen. Puffertabelle löschen?';
                begin
                    if Confirm(deleteGenBufferLinesQst) then begin
                        genBuffTable.DeleteAll(true);
                        blobStorage.DeleteAll(true);
                    end;
                end;
            }
        }
        area(Processing)
        {
            action(XMLExport)
            {
                Caption = 'Create Backup', Comment = 'de-DE=Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;

                trigger OnAction()
                var
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Export();
                end;
            }
            action(XMLImport)
            {
                Caption = 'Import Backup', Comment = 'de-DE=Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                var
                    ImportConfigHeader: Record DMTImportConfigHeader;
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Import();
                    // Update imported "Qty.Lines In Trgt. Table" with actual values
                    if ImportConfigHeader.FindSet() then
                        repeat
                            ImportConfigHeader.UpdateBufferRecordCount();
                        until ImportConfigHeader.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            group(Administration)
            {
                Caption = 'Administration', Comment = 'de-DE=Verwaltung';
                actionref(ClearGenBufferRef; ClearGenBuffer) { }
            }
            group(Backup)
            {
                Caption = 'Backup', Locked = true;
                actionref(XMLImportRef; XMLImport) { }
                actionref(XMLExportRef; XMLExport) { }
            }
        }

    }
    trigger OnOpenPage()
    begin
        Rec.InsertWhenEmpty();
    end;
}