enum 91006 DMTLogUsage
{
    value(0; " ") { Caption = ' ', Locked = true; }
    value(10; Information) { Caption = 'Information', Locked = true; }
    value(20; "Import to Buffer Table") { Caption = 'Import to Buffer Table', Comment = 'de-DE=Import in P.'; }
    value(30; "Process Buffer - Record") { Caption = 'Process Buffer Record', Comment = 'de-DE=DS Verarbeiten'; }
    value(40; "Process Buffer - Field Update") { Caption = 'Update Fields', Comment = 'de-DE=Update'; }
    value(50; "Apply Fixed Values") { Caption = 'Apply Fixed Values', Comment = 'de-DE=Fixwerte anwenden'; }
    value(60; "Delete Record") { Caption = 'Delete Record', Comment = 'de-DE=DS Löschen'; }
}