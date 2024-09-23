page 91014 DMTImportConfigFactBox
{
    Caption = 'ImportConfig FactBox', Locked = true;
    PageType = ListPart;
    SourceTable = DMTLogEntry;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    SourceTableTemporary = true;

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
                            CurrImportConfigHeader.BufferTableMgt().ShowBufferTable();
                        end;
                    }
                    // debug csv import
                    field("No.of CSV lines read"; DMTSessionStorage.LastLineRead())
                    {
                        ApplicationArea = All;
                        Visible = false;
                        Caption = 'No.of CSV lines read', comment = 'de-DE=Anz. CSV Zeilen gelesen';
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
                Visible = ViewMode = ViewMode::Log;

                trigger OnAction()
                var
                    Log: Codeunit DMTLog;
                begin
                    Log.ShowLogEntriesFor(Rec);
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        found: Boolean;
    begin
        LoadLines();
        found := Rec.Find(Which);
        exit(found);
    end;

    procedure LoadLines()
    var
        lineNo: Integer;
        importConfigHeaderID: Integer;
        runMode: Option " ","TableInfo","Log";
    begin
        // Read RunMode from Filter
        if GetRunModeFromSubPageLink(runMode) then
            case true of

                // Run from Import Config. Card
                GetSubPageLinkFilterValueAsInteger(importConfigHeaderID, Rec.FieldNo(ImportConfigHeaderID_Filter)):
                    begin
                        // Is loaded
                        // if importConfigHeaderID = CurrImportConfigHeader.ID then
                        //     exit;
                        // load
                        CurrImportConfigHeader.Get(importConfigHeaderID);
                        case runMode of
                            runMode::TableInfo:
                                ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                            runMode::Log:
                                ShowAsLogAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                        end;
                    end;

                // Run from Processing Plan
                GetSubPageLinkFilterValueAsInteger(lineNo, Rec.FieldNo("PrPl_LineNo_Filter")):
                    begin
                        // Is loaded
                        // if lineNo = CurrProcessingPlan."Line No." then
                        //     exit;
                        // load
                        CurrProcessingPlan.Get(lineNo);
                        case runMode of
                            runMode::TableInfo:
                                begin
                                    CurrProcessingPlan.findImportConfigHeader(CurrImportConfigHeader);
                                    ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                                end;
                            runMode::Log:
                                begin
                                    CurrProcessingPlan.Get(lineNo);
                                    if not CurrProcessingPlan.findImportConfigHeader(CurrImportConfigHeader) then
                                        Clear(CurrImportConfigHeader);
                                    ShowAsLogAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                                end;
                        end;
                    end;
            end;
    end;

    procedure GetRunModeFromSubPageLink(var runMode: Option) hasFilter: Boolean;
    begin
        Rec.FilterGroup(4);
        hasFilter := (Rec.GetFilter(FBRunMode_Filter) <> '');
        if hasFilter then
            runMode := Rec.GetRangeMin(FBRunMode_Filter);
    end;

    procedure GetSubPageLinkFilterValueAsInteger(var filterValue: Integer; fieldId: Integer) hasFilter: Boolean;
    var
        recRef: RecordRef;
    begin
        recRef.GetTable(Rec);
        recRef.FilterGroup(4);
        hasFilter := recRef.Field(fieldId).GetFilter <> '';
        if hasFilter then
            filterValue := recRef.Field(fieldId).GetRangeMin();
    end;

    procedure ShowAsLogAndUpdateOnAfterGetCurrRecord(importConfigHeader: Record DMTImportConfigHeader)
    var
        LogEntry: Record DMTLogEntry;
    begin
        Rec.DeleteAll();
        Clear(ViewMode); // hide log if type doesnt support log
        if importConfigHeader.ID = 0 then
            exit;

        ViewMode := ViewMode::Log;
        LogEntry.SetRange("Owner RecordID", importConfigHeader.RecordId);
        LogEntry.SetRange("Entry Type", Rec."Entry Type"::Summary);
        if LogEntry.FindSet() then
            repeat
                Rec.Copy(LogEntry);
                Rec.Insert(false);
            until LogEntry.Next() = 0;
    end;

    procedure ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(importConfigHeader: Record DMTImportConfigHeader)
    begin
        Rec.DeleteAll();
        Clear(ViewMode); // hide log if type doesnt support log
        ViewMode := ViewMode::TableInfo;
        if importConfigHeader.ID = 0 then
            exit;

        Rec."Entry No." := importConfigHeader.ID;
        Rec.Insert();
    end;

    // procedure DoUpdate(importConfigHeader: Record DMTImportConfigHeader)
    // begin
    //     CurrImportConfigHeader.Copy(importConfigHeader);

    //     if ViewMode = ViewMode::Log then begin
    //         Rec.SetRange("Owner RecordID", importConfigHeader.RecordId);
    //         Rec.SetRange("Entry Type", Rec."Entry Type"::Summary);
    //     end;

    //     CurrPage.Update(false);
    // end;

    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        CurrProcessingPlan: Record DMTProcessingPlan;
        DMTSessionStorage: Codeunit DMTSessionStorage;
        ViewMode: Option " ",Log,TableInfo;
}

