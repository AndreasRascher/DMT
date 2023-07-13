page 91000 "DMT Setup"
{
    Caption = 'Data Migration Tool Setup', comment = 'de-DE=Data Migration Tool Einrichtung';
    AdditionalSearchTerms = 'DMT Setup', comment = 'de-DE=DMT Einrichtung';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTSetup;
    PromotedActionCategories = 'NAV,Backup,Lists,,', comment = 'de-DE=NAV,Backup,Listen,,';

    layout
    {
        area(Content)
        {
            group(MigrationSettings)
            {
                Caption = 'Migration Settings', Comment = 'de-DE=Migration Einstellungen';
            }
            group("Object Generator")
            {
                Caption = 'Object Generator', comment = 'de-DE=Objekte generieren';
                group(ObjectIDs)
                {
                    Caption = 'Object IDs', comment = 'de-DE=Objekt IDs';
                    field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables") { ApplicationArea = All; ShowMandatory = true; }
                    field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts") { ApplicationArea = All; ShowMandatory = true; }
                }
                field("Import with FlowFields"; Rec."Import with FlowFields") { ApplicationArea = All; }
            }
            group(Debugging)
            {
                field(SessionID; SessionId())
                {
                    ApplicationArea = All;
                    Caption = 'SessionID';
                    trigger OnAssistEdit()
                    var
                        activeSession: Record "Active Session";
                        Choice: Integer;
                        NoOfChoices: Integer;
                        SessionListID: Integer;
                        StopSessionInstructionLbl: Label 'Select which session to stop:\<Session ID> - <User ID> - <Client Type>- <Login Datetime>', comment = 'de-DE=Wählen Sie eine Session zum Beenden aus:\<Session ID> - <User ID> - <Client Type> - <Login Datetime>';
                        SessionList: List of [Integer];
                        Choices: Text;
                    begin
                        if activeSession.FindSet() then
                            repeat
                                Choices += StrSubstNo('%1 - %2 - %3 - %4,', activeSession."Session ID", activeSession."User ID", activeSession."Client Type", activeSession."Login Datetime");
                                NoOfChoices += 1;
                                SessionList.Add(activeSession."Session ID");
                            until activeSession.Next() = 0;
                        Choices += 'StopAllOtherSessions,';
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
                field("UserID"; UserId) { ApplicationArea = All; Caption = 'User ID'; }
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            action(ClearGenBuffer)
            {
                Caption = 'Delete Gen. Buffer Table Lines', comment = 'de-DE=Alle Zeilen in gen. Puffertabelle löschen';
                ApplicationArea = All;
                Image = ListPage;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    DMTGenBuffTable: Record DMTGenBuffTable;
                    deleteGenBufferLinesQst: Label 'Delete all lines in Gen. Buffer Table?', Comment = 'de-DE=Alle Zeilen in gen. Puffertabelle löschen?';
                begin
                    if Confirm(deleteGenBufferLinesQst) then
                        DMTGenBuffTable.DeleteAll();
                end;
            }
        }
        area(Processing)
        {
            action(XMLExport)
            {
                Caption = 'Create Backup', comment = 'de-DE=Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Export();
                end;
            }
            action(XMLImport)
            {
                Caption = 'Import Backup', comment = 'de-DE=Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

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

    }
    trigger OnOpenPage()
    begin
        Rec.InsertWhenEmpty();
    end;
}