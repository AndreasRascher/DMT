codeunit 91014 DMTMigrate
{
    /// <summary>
    /// Process buffer records defined by RecordIds
    /// </summary>
    procedure RetryBufferRecordIDs(var RecIdToProcessList: List of [RecordId]; ImportConfigHeader: Record DMTImportConfigHeader)
    var
        Log: Codeunit DMTLog;
    begin
        Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", ImportConfigHeader);
        ListOfBufferRecIDs(RecIdToProcessList, Log, ImportConfigHeader, false);
        Log.CreateSummary();
        Log.ShowLogForCurrentProcess();
    end;
    /// <summary>
    /// Process buffer records defined by RecordIds
    /// </summary>
    procedure ListOfBufferRecIDs(var RecIdToProcessList: List of [RecordId]; var Log: Codeunit DMTLog; ImportConfigHeader: Record DMTImportConfigHeader; StopProcessingRecIDListAfterError: Boolean) IsFullyProcessed: Boolean
    var
        ImportSettings: Codeunit DMTImportSettings;
    begin
        ImportSettings.RecIdToProcessList(RecIdToProcessList);
        ImportSettings.ImportConfigHeader(ImportConfigHeader);
        ImportSettings.NoUserInteraction(true);
        ImportSettings.StopProcessingRecIDListAfterError(StopProcessingRecIDListAfterError);
        LoadImportConfigLine(ImportSettings);
        IsFullyProcessed := ListOfBufferRecIDsInner(RecIdToProcessList, Log, ImportSettings);
    end;
    /// <summary>
    /// Process buffer records with field selection
    /// </summary>
    procedure AllFieldsFrom(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.ImportConfigHeader(ImportConfigHeader);
        DMTImportSettings.SourceTableView(ImportConfigHeader.ReadLastUsedSourceTableView());
        LoadImportConfigLine(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;
    /// <summary>
    /// Process buffer records with field selection
    /// </summary>
    procedure AllFieldsWithoutDialogFrom(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.ImportConfigHeader(ImportConfigHeader);
        DMTImportSettings.NoUserInteraction(true);
        LoadImportConfigLine(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;
    /// <summary>
    /// Process buffer records
    /// </summary>
    procedure SelectedFieldsFrom(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.ImportConfigHeader(ImportConfigHeader);
        DMTImportSettings.UpdateFieldsFilter(ImportConfigHeader.ReadLastFieldUpdateSelection());
        DMTImportSettings.UpdateExistingRecordsOnly(true);
        LoadImportConfigLine(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;

    /// <summary>
    /// Process buffer records with ProcessingPlan settings
    /// </summary>
    procedure BufferFor(ProcessingPlan: Record DMTProcessingPlan)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.ProcessingPlan(ProcessingPlan);
        ImportConfigHeader.Get(ProcessingPlan.ID);
        DMTImportSettings.ImportConfigHeader(ImportConfigHeader);
        DMTImportSettings.UpdateFieldsFilter(ProcessingPlan.ReadUpdateFieldsFilter());
        DMTImportSettings.SourceTableView(ProcessingPlan.ReadSourceTableView());
        LoadImportConfigLine(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;

    local procedure LoadImportConfigLine(var DMTImportSettings: Codeunit DMTImportSettings) OK: Boolean
    var
        ImportConfigLine: Record DMTImportConfigLine;
        TempImportConfigLine, TempImportConfigLine_ProcessingPlanSettings : Record DMTImportConfigLine temporary;
        ImportConfigHeader: Record DMTImportConfigHeader;
    begin
        ImportConfigHeader := DMTImportSettings.ImportConfigHeader();
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        if ImportConfigHeader."Use Separate Buffer Table" then
            ImportConfigLine.SetFilter("Source Field No.", '<>0');

        if DMTImportSettings.UpdateFieldsFilter() <> '' then begin // Scope ProcessingPlan
            ImportConfigLine.SetRange("Is Key Field(Target)", true);
            // Mark Key Fields
            ImportConfigLine.FindSet();
            repeat
                ImportConfigLine.Mark(true);
            until ImportConfigLine.Next() = 0;

            // Mark Selected Fields
            ImportConfigLine.SetRange("Is Key Field(Target)");
            ImportConfigLine.SetFilter("Target Field No.", DMTImportSettings.UpdateFieldsFilter());
            ImportConfigLine.FindSet();
            repeat
                ImportConfigLine.Mark(true);
            until ImportConfigLine.Next() = 0;

            ImportConfigLine.SetRange("Target Field No.");
            ImportConfigLine.MarkedOnly(true);
        end;
        ImportConfigLine.CopyToTemp(TempImportConfigLine);
        // Apply Processing Plan Settings
        if DMTImportSettings.ProcessingPlan()."Line No." <> 0 then begin
            DMTImportSettings.ProcessingPlan().ConvertDefaultValuesViewToFieldLines(TempImportConfigLine_ProcessingPlanSettings);
            if TempImportConfigLine_ProcessingPlanSettings.FindSet() then
                repeat
                    TempImportConfigLine.Get(TempImportConfigLine_ProcessingPlanSettings.RecordId);
                    TempImportConfigLine := TempImportConfigLine_ProcessingPlanSettings;
                    TempImportConfigLine.Modify();
                until TempImportConfigLine_ProcessingPlanSettings.Next() = 0;
        end;

        // Update From Field No From Index To Gen.Buff Field No
        if not ImportConfigHeader."Use Separate Buffer Table" then begin
            TempImportConfigLine.Reset();
            if TempImportConfigLine.FindSet() then
                repeat
                    if TempImportConfigLine."Source Field No." < 1000 then begin
                        TempImportConfigLine."Source Field No." += 1000;
                        TempImportConfigLine.Modify();
                    end;
                until TempImportConfigLine.Next() = 0;
        end;

        OK := TempImportConfigLine.FindFirst();
        DMTImportSettings.SetImportConfigLine(TempImportConfigLine);
    end;

    local procedure ProcessFullBuffer(var DMTImportSettings: Codeunit DMTImportSettings)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
        Log: Codeunit DMTLog;
        MigrationLib: Codeunit DMTMigrationLib;
        ProgressDialog: Codeunit DMTProgressDialog;
        BufferRef, BufferRef2 : RecordRef;
        Start: DateTime;
        ResultType: Enum DMTProcessingResultType;
        NoBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filter: "%1"', Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Filter: "%1"';
        replacement: Record DMTReplacement;
        iReplacementHandler: Interface IReplacementHandler;
    begin
        Start := CurrentDateTime;
        APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        ImportConfigHeader := DMTImportSettings.ImportConfigHeader();

        // Show Filter Dialog
        ImportConfigHeader.InitBufferRef(BufferRef);
        Commit(); // Runmodal Dialog in Edit View
        if not EditView(BufferRef, DMTImportSettings) then
            exit;
        CheckMappedFieldsExist(ImportConfigHeader);
        CheckBufferTableIsNotEmpty(ImportConfigHeader);

        //Prepare Progress Bar
        if not BufferRef.FindSet() then
            Error(NoBufferTableRecorsInFilterErr, BufferRef.GetFilters);

        PrepareProgressBar(ProgressDialog, ImportConfigHeader, BufferRef);
        ProgressDialog.Open();
        ProgressDialog.UpdateFieldControl('Filter', ConvertStr(BufferRef.GetFilters, '@', '_'));

        replacement.getDefaultImplementation(iReplacementHandler);
        iReplacementHandler.InitBatchProcess(ImportConfigHeader);

        if DMTImportSettings.UpdateFieldsFilter() <> '' then
            Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Field Update", ImportConfigHeader)
        else
            Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", ImportConfigHeader);


        repeat
            // hier weiter machen:
            // Wenn beim Feldupdate ein Zieldatensatz nicht existiert, dann soll der als geskipped gekennzeichnet werden
            // Nur wenn ein Zieldatensatz existiert und kein Fehler auftreteten ist , dann ist das ok
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, DMTImportSettings, Log, ResultType);
            UpdateLog(DMTImportSettings, Log, ResultType);
            UpdateProgress(DMTImportSettings, ProgressDialog, ResultType);
            if ProgressDialog.GetStep('Process') mod 50 = 0 then
                Commit();
        until BufferRef.Next() = 0;
        MigrationLib.RunPostProcessingFor(ImportConfigHeader);
        ProgressDialog.Close();
        Log.CreateSummary();
        Log.ShowLogForCurrentProcess();
        ShowResultDialog(ProgressDialog);
    end;

    local procedure ProcessSingleBufferRecord(BufferRef2: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings; var Log: Codeunit DMTLog; var ResultType: Enum DMTProcessingResultType)
    var
        ProcessRecord: Codeunit DMTProcessRecord;
    begin
        ClearLastError();
        Clear(ResultType);
        Log.DeleteExistingLogFor(BufferRef2);
        ProcessRecord.InitFieldTransfer(BufferRef2, DMTImportSettings);
        Commit();
        while not ProcessRecord.Run() do begin
            ProcessRecord.LogLastError();
        end;

        if DMTImportSettings.UpdateExistingRecordsOnly() then begin
            ProcessRecord.InitModify();
            Commit();
            if not ProcessRecord.Run() then
                ProcessRecord.LogLastError();
        end else begin
            ProcessRecord.InitInsert();
            Commit();
            if not ProcessRecord.Run() then
                ProcessRecord.LogLastError();
        end;
        ProcessRecord.SaveErrorLog(Log);
        ResultType := ProcessRecord.GetProcessingResultType();
    end;

    local procedure EditView(var BufferRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings) Continue: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        FPBuilder: Codeunit DMTFPBuilder;
    begin
        Continue := true; // Canceling the dialog should stop th process

        if DMTImportSettings.SourceTableView() <> '' then
            BufferRef.SetView(DMTImportSettings.SourceTableView());

        if DMTImportSettings.NoUserInteraction() then begin
            exit(Continue);
        end;

        ImportConfigHeader.Get(DMTImportSettings.ImportConfigHeader().RecordId);
        if not FPBuilder.RunModal(BufferRef, ImportConfigHeader, true) then
            exit(false);
        if BufferRef.HasFilter then begin
            ImportConfigHeader.WriteSourceTableView(BufferRef.GetView());
            Commit();
        end else begin
            ImportConfigHeader.WriteSourceTableView('');
            Commit();
        end;
    end;

    local procedure ShowResultDialog(var ProgressDialog: Codeunit DMTProgressDialog)
    var
        ResultMsg: Label 'No. of Records..\processed: %1\imported: %2\With Error: %3\Processing Time:%4',
         Comment = 'de-DE=Anzahl Datensätze..\verarbeitet: %1\eingelesen : %2\mit Fehlern: %3\Verarbeitungsdauer: %4';
    begin
        Message(ResultMsg,
                ProgressDialog.GetStep('Process'),
                ProgressDialog.GetStep('ResultOK'),
                ProgressDialog.GetStep('ResultError'),
                ProgressDialog.GetCustomDuration('Progress'));
    end;

    local procedure UpdateLog(var DMTImportSettings: Codeunit DMTImportSettings; var Log: Codeunit DMTLog; var ResultType: Enum DMTProcessingResultType)
    begin
        Log.IncNoOfProcessedRecords();
        case ResultType of
            ResultType::Error:
                Log.IncNoOfRecordsWithErrors();
            ResultType::Ignored:
                begin
                    if DMTImportSettings.UpdateFieldsFilter() = '' then;
                    //Field Update
                    if DMTImportSettings.UpdateFieldsFilter() <> '' then;
                end;
            ResultType::ChangesApplied:
                Log.IncNoOfSuccessfullyProcessedRecords();
            else begin
                Error('Unhandled Case %1', ResultType::" ");
            end;
        end;
    end;

    procedure PrepareProgressBar(var ProgressDialog: Codeunit DMTProgressDialog; var ImportConfigHeader: Record DMTImportConfigHeader; var BufferRef: RecordRef)
    var
        MaxWith: Integer;
        DurationLbl: Label 'Duration', Comment = 'de-DE Dauer';
        TimeRemainingLbl: Label 'Time Remaining', Comment = 'de-DE Verbleibende Zeit';
        ProgressBarTitle: Text;
    begin
        ProgressBarTitle := ImportConfigHeader."Target Table Caption";
        MaxWith := 100 - 32;
        if StrLen(ProgressBarTitle) < MaxWith then begin
            ProgressBarTitle := PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_') +
                                ProgressBarTitle +
                                PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_');
        end;
        // ToDo: Performance der Codeunit ProgressDialog schlecht, ggf.weniger generisch,
        //       durch konkrete Programmierung aller Progressdialoge ersetzten

        ProgressDialog.SaveCustomStartTime('Progress');
        ProgressDialog.SetTotalSteps('Process', BufferRef.Count);
        ProgressDialog.AppendTextLine(ProgressBarTitle);
        ProgressDialog.AppendText('\Filter:');
        ProgressDialog.AddField(42, 'Filter');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Record:');
        ProgressDialog.AddField(42, 'NoofRecord');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\' + DurationLbl + ':');
        ProgressDialog.AddField(42, 'Duration');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Progress:');
        ProgressDialog.AddBar(42, 'Progress');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\' + TimeRemainingLbl + ':');
        ProgressDialog.AddField(42, 'TimeRemaining');
        ProgressDialog.AppendTextLine('');
    end;

    procedure UpdateProgress(var DMTImportSettings: Codeunit DMTImportSettings; var ProgressDialog: Codeunit DMTProgressDialog; ResultType: Enum DMTProcessingResultType)
    begin
        ProgressDialog.NextStep('Process');
        case ResultType of
            ResultType::Error:
                ProgressDialog.NextStep('ResultError');
            ResultType::Ignored:
                begin
                    if DMTImportSettings.UpdateFieldsFilter() = '' then
                        ProgressDialog.NextStep(('Ignored'));
                    //Field Update
                    if DMTImportSettings.UpdateFieldsFilter() <> '' then begin
                        //Log.IncNoOfSuccessfullyProcessedRecords();
                    end;
                end;
            ResultType::ChangesApplied:
                ProgressDialog.NextStep('ResultOK');
            else begin
                Error('Unhandled Case %1', ResultType::" ");
            end;
        end;
        ProgressDialog.UpdateFieldControl('NoofRecord', StrSubstNo('%1 / %2', ProgressDialog.GetStep('Process'), ProgressDialog.GetTotalStep('Process')));
        ProgressDialog.UpdateControlWithCustomDuration('Duration', 'Progress');
        ProgressDialog.UpdateProgressBar('Progress', 'Process');
        ProgressDialog.UpdateFieldControl('TimeRemaining', ProgressDialog.GetRemainingTime('Progress', 'Process'));
    end;

    procedure FindCollationProblems(RecordMapping: Dictionary of [RecordId, RecordId]) CollationProblems: Dictionary of [RecordId, RecordId]
    var
        TargetRecID: RecordId;
        LastIndex, ListIndex : Integer;
    begin
        for ListIndex := 1 to RecordMapping.Values.Count do begin
            TargetRecID := RecordMapping.Values.Get(ListIndex);
            LastIndex := RecordMapping.Values.LastIndexOf(TargetRecID);
            if LastIndex <> ListIndex then begin
                CollationProblems.Add(RecordMapping.Keys.Get(ListIndex), RecordMapping.Values.Get(ListIndex));
                CollationProblems.Add(RecordMapping.Keys.Get(LastIndex), RecordMapping.Values.Get(LastIndex));
            end;
        end;
    end;

    procedure CheckMappedFieldsExist(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        ImportConfigLine: Record DMTImportConfigLine;
        ImportConfigLineEmptyErr: Label 'No field mapping found for %1 "%2"', Comment = 'de-DE=Kein Feldmapping gefunden für  %1 "%2"';
    begin
        // Key Fields Mapping Exists
        ImportConfigHeader.FilterRelated(ImportConfigLine);
        ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
        ImportConfigLine.SetRange("Is Key Field(Target)", true);
        ImportConfigLine.SetFilter("Source Field No.", '<>0');


        if ImportConfigLine.IsEmpty then
            Error(ImportConfigLineEmptyErr, ImportConfigHeader.TableCaption, ImportConfigHeader.ID);
    end;

    procedure CheckBufferTableIsNotEmpty(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        GenBuffTable: Record DMTGenBuffTable;
        refHelper: Codeunit DMTRefHelper;
        bufferTableEmptyErr: Label 'The buffer table is empty for %1:%2', Comment = 'de-DE=Die Puffertable entält keine Zeilen für %1:%2';
    begin
        if ImportConfigHeader."Use Separate Buffer Table" then begin
            if refHelper.IsTableEmpty(ImportConfigHeader."Buffer Table ID") then
                Error(bufferTableEmptyErr, ImportConfigHeader.TableCaption, ImportConfigHeader.ID);
        end else begin
            if not GenBuffTable.FilterBy(ImportConfigHeader) then
                Error(bufferTableEmptyErr, ImportConfigHeader.TableCaption, ImportConfigHeader.ID);
        end;
    end;

    procedure ListOfBufferRecIDsInner(var RecIdToProcessList: List of [RecordId]; var Log: Codeunit DMTLog; ImportSettings: Codeunit DMTImportSettings) IsFullyProcessed: Boolean
    var
        // DMTErrorLog: Record DMTErrorLog;
        ImportConfigHeader: Record DMTImportConfigHeader;
        ID: RecordId;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
        ResultType: Enum DMTProcessingResultType;
    begin
        if RecIdToProcessList.Count = 0 then
            Error('Keine Daten zum Verarbeiten');

        ImportConfigHeader := ImportSettings.ImportConfigHeader();
        // Buffer loop
        BufferRef.Open(ImportConfigHeader."Buffer Table ID");
        ID := RecIdToProcessList.Get(1);
        BufferRef.Get(ID);

        IsFullyProcessed := true;
        foreach ID in RecIdToProcessList do begin
            BufferRef.Get(ID);
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, ImportSettings, Log, ResultType);
            Log.IncNoOfProcessedRecords();
            if ResultType = ResultType::ChangesApplied then begin
                Log.IncNoOfSuccessfullyProcessedRecords();
            end;
            if ResultType = ResultType::Error then begin
                Log.IncNoOfRecordsWithErrors();
                if ImportSettings.StopProcessingRecIDListAfterError() then begin
                    exit(false); // break;
                end;
            end;
        end;
    end;

    procedure AssignFieldWithoutValidate(var TargetRef: RecordRef; SourceRef: RecordRef; var importConfigLine: Record DMTImportConfigLine; DoModify: Boolean)
    var
        RefHelper: Codeunit DMTRefHelper;
        FromField: FieldRef;
        ToField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        // Check - Don't copy from or to timestamp
        if (importConfigLine."Source Field No." = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter FromFieldNo = 0');
        if (importConfigLine."Target Field No." = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter ToFieldNo = 0');
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRef.Number);
        FromField := SourceRef.Field(importConfigLine."Source Field No.");
        ToField := TargetRef.Field(importConfigLine."Target Field No.");
        if ToField.Type = FromField.Type then
            ToField.Value := FromField.Value
        else
            if not RefHelper.EvaluateFieldRef(ToField, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
                Error('Evaluating "%1" into "%2" failed', FromField.Value, ToField.Caption);
        // ApplyReplacements(ImportConfigLine, ToField);
        if DoModify then
            TargetRef.Modify();
    end;

}