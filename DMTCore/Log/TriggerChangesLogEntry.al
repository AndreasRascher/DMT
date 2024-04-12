table 91013 DMTTriggerChangesLogEntry
{
    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.', Comment = 'de-DE=Lfd.Nr.'; }
        #region log_triggered_changes
        field(10; "Trigger"; Option) { OptionMembers = " ","OnValidate","OnInsert","OnModify","OnDelete"; }
        field(20; "Validate Field No."; Integer) { Caption = 'Validate Field No.', Comment = 'de-DE=Feldnr. Validierung'; }
        field(21; "Validate Caption"; Integer) { Caption = 'Validate Field Caption', Comment = 'de-DE=Feldbezeichnung Validierung'; }
        field(22; "Value Assigned"; Text[250]) { Caption = 'Value Assigned', Comment = 'de-DE=Zugewiesener Wert'; }
        field(11; "Changed Field No. (Trigger)"; Integer) { Caption = 'changed Field No. (Trigger)', Comment = 'de-DE=geändertes Feldnr. (Trigger)'; }
        field(12; "Changed Field Cap.(Trigger)"; Text[250]) { Caption = 'changed Field Caption (Trigger)', Comment = 'de-DE=geändertes Feld (Trigger)'; }
        field(13; "From Value (Trigger)"; Text[250]) { Caption = 'From Value (Trigger)', Comment = 'de-DE=Von Feldwert (Trigger)'; }
        field(15; "To Value (Trigger)"; Text[250]) { Caption = 'To Value (Trigger)', Comment = 'de-DE=Zu Feldwert (Trigger)'; }
        #endregion log_triggered_changes
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    internal procedure GetNextEntryNo() NextEntryNo: Integer
    var
        triggerChangesLogEntry: Record DMTTriggerChangesLogEntry;
    begin
        NextEntryNo := 1;
        triggerChangesLogEntry.Reset();
        triggerChangesLogEntry.SetLoadFields("Entry No.");
        if triggerChangesLogEntry.FindLast() then begin
            NextEntryNo += triggerChangesLogEntry."Entry No.";
        end;
    end;

}