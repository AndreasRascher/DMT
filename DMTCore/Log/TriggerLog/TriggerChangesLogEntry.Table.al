table 50140 DMTTriggerLogEntry
{
    LookupPageId = DMTTriggerLogEntries;
    DrillDownPageId = DMTTriggerLogEntries;
    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.', Comment = 'de-DE=Lfd.Nr.'; }
        field(10; "Trigger"; Enum DMTTriggerType) { Caption = 'Trigger', Locked = true; }
        field(11; "Source ID"; RecordId) { Caption = 'Source ID', Comment = 'de-DE=Herkunfts-ID'; }
        field(12; "Target ID"; RecordId) { Caption = 'Target ID', Comment = 'de-DE=Ziel-ID'; }
        field(20; "Validate Field No."; Integer) { Caption = 'Validate Field No.', Comment = 'de-DE=Feldnr. Validierung'; }
        field(21; "Validate Caption"; Text[250]) { Caption = 'Validate Field Caption', Comment = 'de-DE=Validiertes Feld'; }
        field(30; "Changed Field No. (Trigger)"; Integer) { Caption = 'changed Field No.', Comment = 'de-DE=geändertes Feldnr.'; }
        field(31; "Changed Field Cap.(Trigger)"; Text[250]) { Caption = 'changed Field Caption', Comment = 'de-DE=Geändertes Feld'; }
        field(40; "Old Value (Trigger)"; Text[250]) { Caption = 'Old Value', Comment = 'de-DE=Alter Feldwert'; }
        field(41; "Value Assigned"; Text[250]) { Caption = 'Value Assigned', Comment = 'de-DE=Zugewiesener Wert'; }
        field(42; "New Value (Trigger)"; Text[250]) { Caption = 'New Value', Comment = 'de-DE=Neuer Feldwert'; }
        field(50; "Owner RecordID"; RecordId) { Caption = 'Owner ID', Locked = true; }
        field(51; SourceFileName; Text[250]) { Caption = 'Source File Name', Comment = 'de-DE=Quelldatei Name'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    internal procedure GetNextEntryNo() NextEntryNo: Integer
    var
        triggerChangesLogEntry: Record DMTTriggerLogEntry;
        tempTriggerChangesLogEntry: Record DMTTriggerLogEntry temporary;
    begin
        NextEntryNo := 1;
        if Rec.IsTemporary then begin
            tempTriggerChangesLogEntry.Copy(Rec, true);
            tempTriggerChangesLogEntry.Reset();
            if tempTriggerChangesLogEntry.FindLast() then;
            NextEntryNo += tempTriggerChangesLogEntry."Entry No.";
        end else begin
            triggerChangesLogEntry.Reset();
            triggerChangesLogEntry.SetLoadFields("Entry No.");
            if triggerChangesLogEntry.FindLast() then;
            NextEntryNo += triggerChangesLogEntry."Entry No.";
        end;
    end;

    internal procedure FilterFor(ImportConfigHeader: Record DMTImportConfigHeader) HasLinesInFilter: Boolean
    begin
        Rec.SetRange("Owner RecordID", ImportConfigHeader.RecordId);
        Rec.SetRange(SourceFileName, ImportConfigHeader.GetSourceFileName());
        HasLinesInFilter := not Rec.IsEmpty;
    end;

}