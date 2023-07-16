table 91008 DMTLogEntry
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', Comment = 'de-DE=Lfd.Nr.';
            AutoIncrement = true;
        }
        field(10; Usage; Enum DMTLogUsage) { Caption = 'Usage', Comment = 'de-DE=Verwendung'; }
        field(11; "Process No."; Integer) { Caption = 'Process No.', Comment = 'de-DE=Vorgangsnr.'; }
        field(12; "Entry Type"; Enum DMTLogEntryType) { Caption = 'Entry Type', Comment = 'de-DE=Postenart'; }
        field(20; "Source ID"; RecordId) { Caption = 'Source ID', Comment = 'de-DE=Herkunfts-ID'; }
        field(21; "Source ID (Text)"; Text[250]) { Caption = 'Source ID (Text)', Comment = 'de-DE=Herkunfts-ID (Text)'; }
        field(30; "Target ID"; RecordId) { Caption = 'Target ID', Comment = 'de-DE=Ziel-ID'; }
        field(31; "Target ID (Text)"; Text[250]) { Caption = 'Target ID (Text)', Comment = 'de-DE=Ziel-ID (Text)'; }
        field(32; "Target Table ID"; Integer) { Caption = 'Target Table ID', Comment = 'de-DE=Zieltabellen ID'; }
        field(33; "Target Field No."; Integer) { Caption = 'Target Field No.', Comment = 'de-De=Zielfeldnr.'; }
        field(40; "Context Description"; Text[2048]) { Caption = 'Context Description', Comment = 'de-DE=Kontext Beschreibung'; }
        field(41; ErrorCode; Text[250]) { Caption = 'Error Code', Comment = 'de-DE=Fehler Code'; }
        field(42; "Error Call Stack"; Blob) { Caption = 'Error Callstack', Comment = 'de-DE=Fehler Aufrufliste'; }
        field(43; "Ignore Error"; Boolean) { Caption = 'Ignore Error', Comment = 'de-DE=Fehler ignorieren'; }
        field(44; "Error Field Value"; Text[250]) { Caption = 'Error Field Value', Comment = 'de-DE=Fehler für Feldwert'; }
        field(51; SourceFileName; Text[250]) { Caption = 'Source File Name', Comment = 'de-DE=Quelldatei Name'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    procedure GetErrorCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not Rec."Error Call Stack".HasValue() then
            exit('');
        CalcFields("Error Call Stack");
        "Error Call Stack".CreateInStream(InStream, TextEncoding::Windows);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    procedure SetErrorCallStack(NewCallStack: Text)
    var
        OutStream: OutStream;
    begin
        "Error Call Stack".CreateOutStream(OutStream, TextEncoding::Windows);
        OutStream.Write(NewCallStack);
    end;

    procedure GetNextProcessNo() NextEntryNo: Integer
    var
        LogEntry: Record DMTLogEntry;
    begin
        NextEntryNo := 1;
        LogEntry.SetLoadFields("Process No.");
        if LogEntry.FindLast() then
            NextEntryNo += LogEntry."Process No.";
    end;

    internal procedure FilterFor(ImportConfigHeader: Record DMTImportConfigHeader) HasLinesInFilter: Boolean
    begin
        Rec.SetRange("Target Table ID", ImportConfigHeader."Target Table ID");
        Rec.SetRange(SourceFileName, ImportConfigHeader.GetSourceFileName());
        HasLinesInFilter := not Rec.IsEmpty;
    end;

}