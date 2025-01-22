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
                            CurrImportConfigHeader.find('=');
                            CurrImportConfigHeader.BufferTableMgt().ShowBufferTable();
                        end;
                    }
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
        runMode: Option " ","TableInfo","Log";
    begin
        if GetRunModeFromSubPageLink(runMode) then
            case true of

                FindImportConfigHeaderFromSubPageLink(CurrImportConfigHeader):
                    begin
                        case runMode of
                            runMode::TableInfo:
                                ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                            runMode::Log:
                                ShowAsLogAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                        end;
                    end;

                GetProcessingPlanFromSubPageLink(CurrProcessingPlan):
                    begin
                        case runMode of
                            runMode::TableInfo:
                                begin
                                    CurrProcessingPlan.findImportConfigHeader(CurrImportConfigHeader);
                                    ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(CurrImportConfigHeader);
                                end;
                            runMode::Log:
                                begin
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

    procedure FindImportConfigHeaderFromSubPageLink(var importConfigHeader: Record DMTImportConfigHeader) found: Boolean;
    begin
        Clear(importConfigHeader);
        Rec.FilterGroup(4);
        if (Rec.GetFilter(ImportConfigHeaderID_Filter) <> '') then
            found := importConfigHeader.Get(Rec.GetRangeMin(ImportConfigHeaderID_Filter));
    end;

    procedure GetProcessingPlanFromSubPageLink(var processingPlan: Record DMTProcessingPlan) Found: Boolean;
    begin
        Clear(processingPlan);
        Rec.FilterGroup(4);
        if (Rec.GetFilter("PrPl_LineNo_Filter") <> '') and (Rec.GetFilter(PrPl_JnlBatchName_Filter) <> '') then
            Found := processingPlan.Get(Rec.GetRangeMin(PrPl_JnlBatchName_Filter), Rec.GetRangeMin("PrPl_LineNo_Filter"));
        Rec.FilterGroup(0);
    end;

    procedure ShowAsLogAndUpdateOnAfterGetCurrRecord(importConfigHeader: Record DMTImportConfigHeader)
    var
        LogEntry: Record DMTLogEntry;
    begin
        Rec.DeleteAll();
        Clear(ViewMode);
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
        Clear(ViewMode);
        ViewMode := ViewMode::TableInfo;
        if importConfigHeader.ID = 0 then
            exit;

        Rec."Entry No." := importConfigHeader.ID;
        Rec.Insert();
    end;

    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        CurrProcessingPlan: Record DMTProcessingPlan;
        DMTSessionStorage: Codeunit DMTSessionStorage;
        ViewMode: Option " ",Log,TableInfo;
}

