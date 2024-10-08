page 50013 DMTLogEntries
{
    Caption = 'DMT Log Entries', Comment = 'de-DE=DMT Protokollposten';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = DMTLogEntry;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Usage; Rec.Usage) { }
                field("Entry Type"; Rec."Entry Type") { }
                field("Entry No."; Rec."Entry No.") { Visible = false; }
                field("Process No."; Rec."Process No.") { Visible = false; }
                field("Source ID (Text)"; Rec."Source ID (Text)") { StyleExpr = LineStyle; }
                field(Errortext; Rec."Context Description") { StyleExpr = LineStyle; }
                field(CallStack; CallStack)
                {
                    Caption = 'Error Call Stack';

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorCallStack());
                    end;
                }
                field("Error Field Value"; Rec."Error Field Value") { }
                field(ErrorCode; Rec.ErrorCode) { }
                field("Ignore Error"; Rec."Ignore Error") { }
                field(SystemCreatedAt; Rec.SystemCreatedAt) { }
                field("Target Field Caption"; Rec."Target Field Caption") { }
                field("Target Field No."; Rec."Target Field No.") { }
                field("Target ID (Text)"; Rec."Target ID (Text)") { }
                field("Target Table No."; Rec."Target Table ID") { }
                field(NoOfTriggerLogEntries; Rec.NoOfTriggerLogEntries) { }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(HideIgnored)
            {
                Caption = 'Hide ignored Errors', Comment = 'de-DE=Ignorierte Fehler ausblenden';
                Image = ShowList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = ShowIgnoredErrorLines;

                trigger OnAction()
                begin
                    ShowIgnoredErrorLines := false;
                    UpdateFilters();
                end;
            }
            action(ShowIgnored)
            {
                Caption = 'Show ignored Errors', Comment = 'de-DE=Ignorierte Fehler anzeigen';
                Image = ShowList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = not ShowIgnoredErrorLines;

                trigger OnAction()
                begin
                    ShowIgnoredErrorLines := true;
                    UpdateFilters();
                end;
            }
            action(HideTriggerLog)
            {
                Caption = 'Hide trigger log entries', Comment = 'de-DE=Trigger Änderungen ausblenden';
                Image = ShowList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = ShowTriggerLogLines;

                trigger OnAction()
                begin
                    ShowTriggerLogLines := false;
                    UpdateFilters();
                end;
            }
            action(ShowTriggerLog)
            {
                Caption = 'Show trigger changes', Comment = 'de-DE=Trigger Änderungen anzeigen';
                Image = ShowList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = not ShowTriggerLogLines;

                trigger OnAction()
                begin
                    ShowTriggerLogLines := true;
                    UpdateFilters();
                end;
            }
            action(DeleteFilteredLines)
            {
                Caption = 'Delete filtered lines', Comment = 'de-DE=Gefilterte Zeilen löschen';
                Image = Delete;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;


                trigger OnAction()
                begin
                    if not Rec.IsEmpty() then
                        Rec.DeleteAll();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ShowIgnoredErrorLines := true;
        ShowTriggerLogLines := false;
        UpdateFilters();
    end;

    trigger OnAfterGetRecord()
    begin
        CallStack := Rec.GetErrorCallStack();
        // format Ignored Entries  
        LineStyle := Format(Enum::DMTFieldStyle::None);
        if Rec."Ignore Error" then
            LineStyle := Format(Enum::DMTFieldStyle::Grey);
    end;

    local procedure UpdateFilters()
    begin
        Rec.SetRange("Ignore Error");
        if not ShowIgnoredErrorLines then
            Rec.SetRange("Ignore Error", false);

        Rec.SetRange("Entry Type");
        if not ShowTriggerLogLines then
            Rec.SetFilter("Entry Type", '<>%1', Enum::DMTLogEntryType::"Trigger Changes");
    end;

    var
        CallStack, LineStyle : Text;
        // [InDataSet]
        ShowIgnoredErrorLines, ShowTriggerLogLines : Boolean;
}

