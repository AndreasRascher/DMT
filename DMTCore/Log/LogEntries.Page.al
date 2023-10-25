page 91013 DMTLogEntries
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
                    Rec.SetRange("Ignore Error", false);
                    ShowIgnoredErrorLines := false;
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
                    Rec.SetRange("Ignore Error");
                    ShowIgnoredErrorLines := true;
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

    trigger OnInit()
    begin
        ShowIgnoredErrorLines := true;
    end;

    trigger OnAfterGetRecord()
    begin
        CallStack := Rec.GetErrorCallStack();
        // format Ignored Entries  
        LineStyle := Format(Enum::DMTFieldStyle::None);
        if Rec."Ignore Error" then
            LineStyle := Format(Enum::DMTFieldStyle::Grey);
    end;

    var
        CallStack, LineStyle : Text;
        // [InDataSet]
        ShowIgnoredErrorLines: Boolean;
}

