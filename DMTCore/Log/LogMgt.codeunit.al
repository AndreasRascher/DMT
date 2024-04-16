codeunit 91006 DMTLog
{

    procedure DeleteExistingLogFor(BufferRef: RecordRef);
    var
        LogEntry: Record DMTLogEntry;
    begin
        LogEntry.SetRange("Source ID", BufferRef.RecordId);
        if not LogEntry.IsEmpty then
            LogEntry.DeleteAll();
    end;

    procedure InitNewProcess(LogUsage: Enum DMTLogUsage; ImportConfigHeader: Record DMTImportConfigHeader)
    var
        LogEntry: Record DMTLogEntry;
    begin
        Clear(LogEntryTemplate);
        LogEntryTemplate."Process No." := LogEntry.GetNextProcessNo();
        LogEntryTemplate.Usage := LogUsage;
        if ImportConfigHeader.ID <> 0 then begin
            LogEntryTemplate."Owner RecordID" := ImportConfigHeader.RecordId;
            LogEntryTemplate."Target Table ID" := ImportConfigHeader."Target Table ID";
            LogEntryTemplate.SourceFileName := ImportConfigHeader.GetSourceFileName();
        end;
        StartGlobal := CurrentDateTime;

        Clear(ProcessingStatistics);
        ProcessingStatistics.Add(Format(StatisticType::Success), 0);
        ProcessingStatistics.Add(Format(StatisticType::Error), 0);
        ProcessingStatistics.Add(Format(StatisticType::Processed), 0);
    end;

    /// <summary>
    /// Returns the current log entry template. It initialized with process number and the usage. Every new log entry will be created based on this template.
    /// </summary>
    /// <returns>Current log entry template</returns>
    procedure GetCurrentLogEntryTemplate() CurrLogEntryTemplate: Record DMTLogEntry
    begin
        exit(LogEntryTemplate);
    end;

    procedure AddTargetSuccessEntry(SourceID: RecordId; ImportConfigHeader: Record DMTImportConfigHeader)
    var
        ImportConfigLineDummy: Record DMTImportConfigLine;
        ErrorItemDummy: Dictionary of [Text, Text];
    begin
        AddEntry(SourceID, Enum::DMTLogEntryType::Success, ImportConfigHeader, ImportConfigLineDummy, ErrorItemDummy);
    end;

    procedure AddTargetErrorByIDEntry(TargetID: RecordId; ImportConfigHeader: Record DMTImportConfigHeader; ErrorItem: Dictionary of [Text, Text])
    var
        ImportConfigLineDummy: Record DMTImportConfigLine;
    begin
        AddEntry(TargetID, Enum::DMTLogEntryType::Error, ImportConfigHeader, ImportConfigLineDummy, ErrorItem);
    end;

    procedure AddErrorByImportConfigLineEntry(SourceID: RecordId; ImportConfigHeader: Record DMTImportConfigHeader; ImportConfigLine: Record DMTImportConfigLine; ErrorItem: Dictionary of [Text, Text])
    begin
        AddEntry(SourceID, Enum::DMTLogEntryType::Error, ImportConfigHeader, ImportConfigLine, ErrorItem);
    end;

    local procedure AddEntry(sourceID: RecordId; logEntryType: Enum DMTLogEntryType; ImportConfigHeader: Record DMTImportConfigHeader; ImportConfigLine: Record DMTImportConfigLine; errorItem: Dictionary of [Text, Text])
    var
        targetIDDummy: RecordId;
    begin
        AddEntry(sourceID, targetIDDummy, logEntryType, ImportConfigHeader, ImportConfigLine, errorItem);
    end;

    local procedure AddEntry(SourceID: RecordId; TargetID: RecordId; LogEntryType: Enum DMTLogEntryType; ImportConfigHeader: Record DMTImportConfigHeader; ImportConfigLine: Record DMTImportConfigLine; ErrorItem: Dictionary of [Text, Text])
    var
        LogEntry: Record DMTLogEntry;
        KeyImportConfigLine: Record DMTImportConfigLine;
        GenBuffTable: Record DMTGenBuffTable;
        SourceRef: RecordRef;
        SourceIdText: Text;
    begin
        CheckIfProcessNoIsSet();
        if SourceID.TableNo = Database::DMTGenBuffTable then begin
            ImportConfigHeader.FilterRelated(KeyImportConfigLine);
            KeyImportConfigLine.SetRange("Is Key Field(Target)", true);
            GenBuffTable.Get(SourceID);
            SourceRef.GetTable(GenBuffTable);
            if KeyImportConfigLine.FindSet() then
                repeat
                    if KeyImportConfigLine."Source Field No." <> 0 then
                        SourceIdText := Format(SourceRef.Field(KeyImportConfigLine."Source Field No.").Value) + ',';
                until KeyImportConfigLine.Next() = 0;
            if SourceIdText.EndsWith(',') then
                SourceIdText := SourceIdText.Remove(StrLen(SourceIdText));
        end else begin
            SourceIdText := Format(SourceID);
        end;
        LogEntry := LogEntryTemplate;
        LogEntry."Entry Type" := LogEntryType;
        LogEntry."Source ID" := SourceID;
        LogEntry."Source ID (Text)" := CopyStr(SourceIdText, 1, MaxStrLen(LogEntry."Source ID (Text)"));
        LogEntry."Target ID" := TargetID;
        LogEntry."Target ID (Text)" := Format(TargetID);
        if ImportConfigLine."Imp.Conf.Header ID" <> 0 then begin
            LogEntry."Target Field No." := ImportConfigLine."Target Field No.";
        end;

        if LogEntryType = LogEntryType::Error then begin
            LogEntry."Ignore Error" := ImportConfigLine."Ignore Validation Error";
            LogEntry.ErrorCode := CopyStr(ErrorItem.Get('GetLastErrorCode'), 1, MaxStrLen(LogEntry.ErrorCode));
            LogEntry.SetErrorCallStack(ErrorItem.Get('GetLastErrorCallStack'));
            LogEntry."Context Description" := CopyStr(ErrorItem.Get('GetLastErrorText'), 1, MaxStrLen(LogEntry."Context Description"));
            if ErrorItem.ContainsKey('ErrorValue') then
                LogEntry."Error Field Value" := CopyStr(ErrorItem.Get('ErrorValue'), 1, MaxStrLen(LogEntry."Error Field Value"));
            if ErrorItem.ContainsKey('ErrorTargetRecID') then
                LogEntry."Target ID (Text)" := CopyStr(ErrorItem.Get('ErrorTargetRecID'), 1, MaxStrLen(LogEntry."Target ID (Text)"));
        end;

        LogEntry.Insert();
    end;

    internal procedure CreateErrorItem() ErrorItem: Dictionary of [Text, Text];
    begin
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
    end;

    internal procedure ShowLogForCurrentProcess()
    var
        LogEntry: Record DMTLogEntry;
        LogEntries: Page DMTLogEntries;
    begin
        CheckIfProcessNoIsSet();
        LogEntry.SetRange("Process No.", LogEntryTemplate."Process No.");
        LogEntries.SetTableView(LogEntry);
        LogEntries.Run();
    end;

    internal procedure FieldErrorsExistFor(var ImportConfigLine: Record DMTImportConfigLine) ErrExist: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        LogEntry: Record DMTLogEntry;
    begin
        if ImportConfigLine."Imp.Conf.Header ID" = 0 then
            // Filtered Rec from Page 
            ImportConfigHeader.Get(ImportConfigLine.GetRangeMin("Imp.Conf.Header ID"))
        else
            ImportConfigHeader.Get(ImportConfigLine."Imp.Conf.Header ID");
        // exit if no source file is set
        if ImportConfigHeader."Source File ID" = 0 then
            exit(false);
        LogEntry.SetRange("Entry Type", LogEntry."Entry Type"::Error);
        LogEntry.SetRange(SourceFileName, ImportConfigHeader.GetSourceFileName());
        LogEntry.SetRange("Target Field No.", ImportConfigLine."Target Field No.");
        ErrExist := not LogEntry.IsEmpty;
    end;

    internal procedure AddImportToBufferSummary(ImportConfigHeader: Record DMTImportConfigHeader; duration: Duration)
    var
        logEntry: Record DMTLogEntry;
        durationLbl: Label '⌛: %1', Locked = true;
    begin
        logEntry.Usage := logEntry.Usage::"Import to Buffer Table";
        logEntry."Entry Type" := logEntry."Entry Type"::Summary;
        logEntry."Process No." := logEntry.GetNextProcessNo();
        logEntry."Context Description" := StrSubstNo(durationLbl, duration);
        logEntry.SourceFileName := ImportConfigHeader.GetSourceFileName();
        logEntry."Target Table ID" := ImportConfigHeader."Target Table ID";
        logEntry."Owner RecordID" := ImportConfigHeader.RecordId;
        logEntry.Insert();
    end;

    procedure CreateSummary()
    var
        LogEntry: Record DMTLogEntry;
        SummaryLbl: Label '∑: %1/ ✅: %2/ ❌: %3 / ⌛: %4', Locked = true;
    begin
        CheckIfProcessNoIsSet();
        LogEntry := LogEntryTemplate;
        LogEntry."Entry Type" := LogEntry."Entry Type"::Summary;
        LogEntry."Context Description" := StrSubstNo(SummaryLbl,
                                           ProcessingStatistics.Get(Format(StatisticType::Processed)),
                                           ProcessingStatistics.Get(Format(StatisticType::Success)),
                                           ProcessingStatistics.Get(Format(StatisticType::Error)),
                                           CurrentDateTime - StartGlobal);
        LogEntry.Insert(true);
    end;

    local procedure CheckIfProcessNoIsSet()
    var
        ProcessNoNotInitializedErr: Label 'Process number has not been initialized', Comment = 'de-DE=Prozessnummer wurde nicht initialisiert';
    begin
        if LogEntryTemplate."Process No." = 0 then
            Error(ProcessNoNotInitializedErr);
    end;

    procedure IncNoOfProcessedRecords()
    begin
        ProcessingStatistics.Set(Format(StatisticType::Processed), GetNoOfProcessedRecords() + 1);
    end;

    procedure GetNoOfProcessedRecords(): Integer
    begin
        exit(ProcessingStatistics.Get(Format(StatisticType::Processed)));
    end;

    procedure IncNoOfRecordsWithErrors()
    begin
        ProcessingStatistics.Set(Format(StatisticType::Error), GetNoOfRecordsWithErrors() + 1);
    end;

    procedure GetNoOfRecordsWithErrors(): Integer
    begin
        exit(ProcessingStatistics.Get(Format(StatisticType::Error)));
    end;

    procedure IncNoOfSuccessfullyProcessedRecords()
    begin
        ProcessingStatistics.Set(Format(StatisticType::Success), GetNoOfSuccessfullyProcessedRecords());
    end;

    procedure GetNoOfSuccessfullyProcessedRecords(): Integer
    begin
        exit(ProcessingStatistics.Get(Format(StatisticType::Success)));
    end;

    procedure GetProgress(MaxSteps: Integer): Integer
    begin
        exit(GetProgress(GetNoOfProcessedRecords(), MaxSteps));
    end;

    procedure GetProgress(StepCount: Integer; MaxSteps: Integer): Integer
    begin
        exit((10000 * (StepCount / MaxSteps)) div 1);
    end;

    procedure ShowLogEntriesFor(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        LogEntry: Record DMTLogEntry;
        LogEntries: Page DMTLogEntries;
    begin
        LogEntry.FilterFor(ImportConfigHeader);
        LogEntries.SetTableView(LogEntry);
        LogEntries.Run();
    end;

    procedure ShowLogEntriesFor(LogEntryWithProcessNo: Record DMTLogEntry)
    var
        LogEntry: Record DMTLogEntry;
        LogEntries: Page DMTLogEntries;
    begin
        LogEntry.SetRange("Process No.", LogEntryWithProcessNo."Process No.");
        LogEntries.SetTableView(LogEntry);
        LogEntries.Run();
    end;

    var
        LogEntryTemplate: Record DMTLogEntry;
        StartGlobal: DateTime;
        ProcessingStatistics: Dictionary of [Text, Integer];
        StatisticType: Option Processed,Success,Error;
}