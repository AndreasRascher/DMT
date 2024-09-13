enum 50005 DMTLogEntryType
{
    value(0; " ") { Caption = ' ', Locked = true; }
    value(10; "Process Title") { Caption = 'Titel', Comment = 'de-DE=Titel'; }
    value(20; Info) { Caption = 'Information', Comment = 'de-DE=Information'; }
    value(30; Success) { Caption = 'Success', Comment = 'de-DE=Erfolg'; }
    value(40; Error) { Caption = 'Error', Comment = 'de-DE=Fehler'; }
    value(50; Summary) { Caption = 'Summary', Comment = 'de-DE=Zusammenfassung'; }
    value(60; "Trigger Changes") { Caption = 'Trigger Changes', Comment = 'de-DE=Trigger Änderungen'; }
}