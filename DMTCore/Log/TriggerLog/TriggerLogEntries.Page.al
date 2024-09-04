page 50166 DMTTriggerLogEntries
{
    Caption = 'DMT Trigger Log Entries', Comment = 'de-DE=DMT Trigger Protokollposten';
    // DeleteAllowed = false;
    // Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = DMTTriggerLogEntry;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Entry No."; Rec."Entry No.") { }
                field("Trigger"; Rec."Trigger") { }
                field("Validate Field No."; Rec."Validate Field No.") { Visible = false; }
                field("Validate Caption"; Rec."Validate Caption") { }
                field("Changed Field No. (Trigger)"; Rec."Changed Field No. (Trigger)") { }
                field("Changed Field Cap.(Trigger)"; Rec."Changed Field Cap.(Trigger)") { }
                field("Value Assigned"; Rec."Value Assigned") { }
                field("Old Value (Trigger)"; Rec."Old Value (Trigger)") { }
                field("New Value (Trigger)"; Rec."New Value (Trigger)") { }
                field("Source ID"; Rec."Source ID") { Visible = false; }
                field(SourceFileName; Rec.SourceFileName) { Visible = false; }
            }
        }
    }
    actions
    {
    }

}

