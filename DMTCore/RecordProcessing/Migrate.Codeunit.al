// codeunit 50014 DMTMigrate
// {
//     /// <summary>
//     /// Process buffer records defined by RecordIds
//     /// </summary>
//     procedure RetryBufferRecordIDs(var RecIdToProcessList: List of [RecordId]; ImportConfigHeader: Record DMTImportConfigHeader)
//     var
//         Log: Codeunit DMTLog;
//     begin
//         Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", ImportConfigHeader);
//         ListOfBufferRecIDs(RecIdToProcessList, Log, ImportConfigHeader, false);
//         Log.CreateSummary();
//         Log.ShowLogForCurrentProcess();
//     end;
//     /// <summary>
//     /// Process buffer records defined by RecordIds
//     /// </summary>
//     procedure ListOfBufferRecIDs(var RecIdToProcessList: List of [RecordId]; var Log: Codeunit DMTLog; ImportConfigHeader: Record DMTImportConfigHeader; StopProcessingRecIDListAfterError: Boolean) IsFullyProcessed: Boolean
//     var
//         ImportSettings: Codeunit DMTImportSettings;
//     begin
//         ImportSettings.RecIdToProcessList(RecIdToProcessList);
//         ImportSettings.ImportConfigHeader(ImportConfigHeader);
//         ImportSettings.NoUserInteraction(true);
//         ImportSettings.StopProcessingRecIDListAfterError(StopProcessingRecIDListAfterError);
//         LoadImportConfigLine(ImportSettings);
//         IsFullyProcessed := ListOfBufferRecIDsInner(RecIdToProcessList, Log, ImportSettings);
//     end;
//     /// <summary>
//     /// Process buffer records with field selection
//     /// </summary>
//     procedure AllFieldsFrom(ImportConfigHeader: Record DMTImportConfigHeader; noUserInteractionNEW: Boolean)
//     var
//         importSettings: Codeunit DMTImportSettings;
//     begin
//         importSettings.ImportConfigHeader(ImportConfigHeader);
//         importSettings.NoUserInteraction(noUserInteractionNEW);
//         importSettings.SourceTableView(ImportConfigHeader.ReadLastUsedSourceTableView());
//         LoadImportConfigLine(importSettings);
//         ProcessFullBuffer(importSettings);
//     end;
//     /// <summary>
//     /// Process buffer records
//     /// </summary>
//     procedure SelectedFieldsFrom(ImportConfigHeader: Record DMTImportConfigHeader; noUserInteractionNEW: Boolean)
//     var
//         DMTImportSettings: Codeunit DMTImportSettings;
//     begin
//         DMTImportSettings.ImportConfigHeader(ImportConfigHeader);
//         DMTImportSettings.UpdateFieldsFilter(ImportConfigHeader.ReadLastFieldUpdateSelection());
//         DMTImportSettings.UpdateExistingRecordsOnly(true);
//         DMTImportSettings.NoUserInteraction(noUserInteractionNEW);
//         LoadImportConfigLine(DMTImportSettings);
//         ProcessFullBuffer(DMTImportSettings);
//     end;

//     /// <summary>
//     /// Process buffer records with ProcessingPlan settings
//     /// </summary>
//     procedure BufferFor(ProcessingPlan: Record DMTProcessingPlan)
//     var
//         ImportConfigHeader: Record DMTImportConfigHeader;
//         DMTImportSettings: Codeunit DMTImportSettings;
//     begin
//         DMTImportSettings.NoUserInteraction(true);
//         DMTImportSettings.ProcessingPlan(ProcessingPlan);
//         ImportConfigHeader.Get(ProcessingPlan.ID);
//         DMTImportSettings.ImportConfigHeader(ImportConfigHeader);
//         DMTImportSettings.UpdateFieldsFilter(ProcessingPlan.ReadUpdateFieldsFilter());
//         DMTImportSettings.SourceTableView(ProcessingPlan.ReadSourceTableView());
//         // Wenn beim Feld-Update der Validierungscode das weitere Felder des Records prüft, müssen diese vorher geladen werden. 
//         // UpdateExistingRecordsOnly - sorgt dafür der vorhande Datensatz
//         if ProcessingPlan.Type = ProcessingPlan.type::"Update Field" then
//             DMTImportSettings.UpdateExistingRecordsOnly(true);
//         LoadImportConfigLine(DMTImportSettings);
//         ProcessFullBuffer(DMTImportSettings);
//     end;

//     local procedure LoadImportConfigLine(var DMTImportSettings: Codeunit DMTImportSettings) OK: Boolean
//     var
//         ImportConfigLine: Record DMTImportConfigLine;
//         TempImportConfigLine, TempImportConfigLine_ProcessingPlanSettings : Record DMTImportConfigLine temporary;
//         ImportConfigHeader: Record DMTImportConfigHeader;
//     begin
//         ImportConfigHeader := DMTImportSettings.ImportConfigHeader();
//         ImportConfigHeader.FilterRelated(ImportConfigLine);
//         ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
//         if not ImportConfigHeader.UseGenericBufferTable() then
//             ImportConfigLine.SetFilter("Source Field No.", '<>0');

//         if DMTImportSettings.UpdateFieldsFilter() <> '' then begin // Scope ProcessingPlan
//             ImportConfigLine.SetRange("Is Key Field(Target)", true);
//             // Mark Key Fields
//             ImportConfigLine.FindSet();
//             repeat
//                 ImportConfigLine.Mark(true);
//             until ImportConfigLine.Next() = 0;

//             // Mark Selected Fields
//             ImportConfigLine.SetRange("Is Key Field(Target)");
//             ImportConfigLine.SetFilter("Target Field No.", DMTImportSettings.UpdateFieldsFilter());
//             ImportConfigLine.FindSet();
//             repeat
//                 ImportConfigLine.Mark(true);
//             until ImportConfigLine.Next() = 0;

//             ImportConfigLine.SetRange("Target Field No.");
//             ImportConfigLine.MarkedOnly(true);
//         end;
//         ImportConfigLine.CopyToTemp(TempImportConfigLine);
//         // Apply Processing Plan Settings
//         if DMTImportSettings.ProcessingPlan()."Line No." <> 0 then begin
//             DMTImportSettings.ProcessingPlan().ConvertDefaultValuesViewToFieldLines(TempImportConfigLine_ProcessingPlanSettings);
//             if TempImportConfigLine_ProcessingPlanSettings.FindSet() then
//                 repeat
//                     TempImportConfigLine.Get(TempImportConfigLine_ProcessingPlanSettings.RecordId);
//                     TempImportConfigLine := TempImportConfigLine_ProcessingPlanSettings;
//                     TempImportConfigLine.Modify();
//                 until TempImportConfigLine_ProcessingPlanSettings.Next() = 0;
//         end;

//         // Update From Field No From Index To Gen.Buff Field No
//         if ImportConfigHeader.UseGenericBufferTable() then begin
//             TempImportConfigLine.Reset();
//             if TempImportConfigLine.FindSet() then
//                 repeat
//                     if TempImportConfigLine."Source Field No." < 1000 then begin
//                         TempImportConfigLine."Source Field No." += 1000;
//                         TempImportConfigLine.Modify();
//                     end;
//                 until TempImportConfigLine.Next() = 0;
//         end;

//         OK := TempImportConfigLine.FindFirst();
//         DMTImportSettings.SetImportConfigLine(TempImportConfigLine);
//     end;

//     local procedure ProcessFullBuffer(var DMTImportSettings: Codeunit DMTImportSettings)
//     var
//         importConfigHeader: Record DMTImportConfigHeader;
//         DMTSetup: Record DMTSetup;
//         APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
//         log: Codeunit DMTLog;
//         migrationLib: Codeunit DMTMigrationLib;
//         progressDialog: Codeunit DMTProgressDialog;
//         bufferRef, bufferRef2 : RecordRef;
//         start: DateTime;
//         resultType: Enum DMTProcessingResultType;
//         iReplacementHandler: Interface IReplacementHandler;
//         iTriggerLog: Interface ITriggerLog;
//         noBufferTableRecorsInFilterErr: Label 'No buffer table records match the filter.\ Filter: "%1"', Comment = 'de-DE=Keine Puffertabellen-Zeilen im Filter gefunden.\ Filter: "%1"';
//     begin
//         start := CurrentDateTime;
//         APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
//         importConfigHeader := DMTImportSettings.ImportConfigHeader();

//         CheckMappedFieldsExist(importConfigHeader);
//         importConfigHeader.BufferTableMgt().ThrowErrorIfBufferTableIsEmpty();

//         // Show Filter Dialog
//         importConfigHeader.BufferTableMgt().InitBufferRef(bufferRef, true);
//         Commit(); // Runmodal Dialog in Edit View
//         if not EditView(bufferRef, DMTImportSettings) then
//             exit;

//         //Prepare Progress Bar
//         if not bufferRef.FindSet() then
//             Error(noBufferTableRecorsInFilterErr, bufferRef.GetFilters);

//         PrepareProgressBar(progressDialog, importConfigHeader, bufferRef);
//         progressDialog.Open();
//         progressDialog.UpdateFieldControl('Filter', ConvertStr(bufferRef.GetFilters, '@', '_'));

//         DMTSetup.getDefaultReplacementImplementation(iReplacementHandler);
//         iReplacementHandler.InitBatchProcess(importConfigHeader);
//         DMTSetup.getDefaultTriggerLogImplementation(iTriggerLog);

//         if DMTImportSettings.UpdateFieldsFilter() <> '' then
//             log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Field Update", importConfigHeader)
//         else
//             log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", importConfigHeader);


//         repeat
//             bufferRef2 := bufferRef.Duplicate(); // Variant + Events = Call By Reference 
//             ProcessSingleBufferRecord(bufferRef2, DMTImportSettings, log, iTriggerLog, resultType);
//             UpdateLog(DMTImportSettings, log, resultType);
//             UpdateProgress(DMTImportSettings, progressDialog, resultType);
//             if progressDialog.GetStep('Process') mod 50 = 0 then
//                 Commit();
//         until bufferRef.Next() = 0;
//         migrationLib.RunPostProcessingFor(importConfigHeader);
//         importConfigHeader.BufferTableMgt().updateImportToTargetPercentage();
//         progressDialog.Close();
//         log.CreateSummary();
//         if not DMTImportSettings.NoUserInteraction() then begin
//             log.ShowLogForCurrentProcess();
//             ShowResultDialog(progressDialog);
//         end;
//     end;

//     local procedure ProcessSingleBufferRecord(BufferRef2: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings; var Log: Codeunit DMTLog; var triggerLog: Interface ITriggerLog; var ResultType: Enum DMTProcessingResultType)
//     var
//         ProcessRecord: Codeunit DMTProcessRecord;
//     begin
//         ClearLastError();
//         Clear(ResultType);
//         Log.DeleteExistingLogFor(BufferRef2);
//         triggerLog.DeleteExistingLogFor(BufferRef2);
//         ProcessRecord.InitFieldTransfer(BufferRef2, DMTImportSettings);
//         // apply field values to target record
//         Commit();
//         while not ProcessRecord.Run() do begin
//             ProcessRecord.LogLastError();
//         end;
//         // do modify on existing records
//         if DMTImportSettings.UpdateExistingRecordsOnly() then begin
//             ProcessRecord.InitModify();
//             Commit();
//             if not ProcessRecord.Run() then
//                 ProcessRecord.LogLastError();
//         end else begin
//             // insert new records
//             ProcessRecord.InitInsert();
//             Commit();
//             if not ProcessRecord.Run() then
//                 ProcessRecord.LogLastError()
//             else
//                 ProcessRecord.SaveTargetRefInfosInBuffertable();
//         end;
//         ProcessRecord.SaveErrorLog(Log);
//         ProcessRecord.SaveTriggerLog(Log);
//         ResultType := ProcessRecord.GetProcessingResultType();
//     end;

//     local procedure EditView(var BufferRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings) Continue: Boolean
//     var
//         ImportConfigHeader: Record DMTImportConfigHeader;
//         FPBuilder: Codeunit DMTFPBuilder;
//     // Filters, Filters2 : List of [Text];
//     begin
//         Continue := true; // Canceling the dialog should stop the process

//         if DMTImportSettings.SourceTableView() <> '' then begin
//             BufferRef.FilterGroup(2);
//             // Filters.Add(BufferRef.GetFilters);
//             BufferRef.FilterGroup(0);
//             // Filters.Add(BufferRef.GetFilters);
//             BufferRef.SetView(DMTImportSettings.SourceTableView());
//             BufferRef.FilterGroup(2);
//             // Filters2.Add(BufferRef.GetFilters);
//             BufferRef.FilterGroup(0);
//             // Filters2.Add(BufferRef.GetFilters);
//         end;

//         if DMTImportSettings.NoUserInteraction() then begin
//             exit(Continue);
//         end;

//         ImportConfigHeader.Get(DMTImportSettings.ImportConfigHeader().RecordId);
//         if not FPBuilder.RunModal(BufferRef, ImportConfigHeader) then
//             exit(false);
//         if BufferRef.HasFilter then begin
//             ImportConfigHeader.WriteSourceTableView(BufferRef.GetView(false));
//             Commit();
//         end else begin
//             ImportConfigHeader.WriteSourceTableView('');
//             Commit();
//         end;
//     end;

//     local procedure ShowResultDialog(var ProgressDialog: Codeunit DMTProgressDialog)
//     var
//         ResultMsg: Label 'No. of Records..\processed: %1\imported: %2\With Error: %3\Processing Time:%4',
//          Comment = 'de-DE=Anzahl Datensätze..\verarbeitet: %1\eingelesen : %2\mit Fehlern: %3\Verarbeitungsdauer: %4';
//     begin
//         Message(ResultMsg,
//                 ProgressDialog.GetStep('Process'),
//                 ProgressDialog.GetStep('ResultOK'),
//                 ProgressDialog.GetStep('ResultError'),
//                 ProgressDialog.GetCustomDuration('Progress'));
//     end;

//     local procedure UpdateLog(var DMTImportSettings: Codeunit DMTImportSettings; var Log: Codeunit DMTLog; var ResultType: Enum DMTProcessingResultType)
//     begin
//         Log.IncNoOfProcessedRecords();
//         case ResultType of
//             ResultType::Error:
//                 Log.IncNoOfRecordsWithErrors();
//             ResultType::Ignored:
//                 begin
//                     if DMTImportSettings.UpdateFieldsFilter() = '' then;
//                     //Field Update
//                     if DMTImportSettings.UpdateFieldsFilter() <> '' then;
//                 end;
//             ResultType::ChangesApplied:
//                 Log.IncNoOfSuccessfullyProcessedRecords();
//             else begin
//                 Error('Unhandled Case %1', ResultType::" ");
//             end;
//         end;
//     end;

//     procedure PrepareProgressBar(var ProgressDialog: Codeunit DMTProgressDialog; var ImportConfigHeader: Record DMTImportConfigHeader; var BufferRef: RecordRef)
//     var
//         MaxWith: Integer;
//         DurationLbl: Label 'Duration', Comment = 'de-DE=Dauer';
//         TimeRemainingLbl: Label 'Time Remaining', Comment = 'de-DE=Verbleibende Zeit';
//         ProgressBarTitle: Text;
//     begin
//         ProgressBarTitle := ImportConfigHeader."Target Table Caption";
//         MaxWith := 100 - 40;
//         if StrLen(ProgressBarTitle) < MaxWith then begin
//             ProgressBarTitle := PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_') +
//                                 ProgressBarTitle +
//                                 PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_');
//         end;
//         // ToDo: Performance der Codeunit ProgressDialog schlecht, ggf.weniger generisch,
//         //       durch konkrete Programmierung aller Progressdialoge ersetzten

//         ProgressDialog.SaveCustomStartTime('Progress');
//         ProgressDialog.SetTotalSteps('Process', BufferRef.Count);
//         ProgressDialog.AppendTextLine(ProgressBarTitle);
//         ProgressDialog.AppendText('\Filter:');
//         ProgressDialog.AddField(42, 'Filter');
//         ProgressDialog.AppendTextLine('');
//         ProgressDialog.AppendText('\Record:');
//         ProgressDialog.AddField(42, 'NoofRecord');
//         ProgressDialog.AppendTextLine('');
//         ProgressDialog.AppendText('\' + DurationLbl + ':');
//         ProgressDialog.AddField(42, 'Duration');
//         ProgressDialog.AppendTextLine('');
//         ProgressDialog.AppendText('\Progress:');
//         ProgressDialog.AddBar(42, 'Progress');
//         ProgressDialog.AppendTextLine('');
//         ProgressDialog.AppendText('\' + TimeRemainingLbl + ':');
//         ProgressDialog.AddField(42, 'TimeRemaining');
//         ProgressDialog.AppendTextLine('');
//     end;

//     procedure UpdateProgress(var DMTImportSettings: Codeunit DMTImportSettings; var ProgressDialog: Codeunit DMTProgressDialog; ResultType: Enum DMTProcessingResultType)
//     begin
//         ProgressDialog.NextStep('Process');
//         case ResultType of
//             ResultType::Error:
//                 ProgressDialog.NextStep('ResultError');
//             ResultType::Ignored:
//                 begin
//                     if DMTImportSettings.UpdateFieldsFilter() = '' then
//                         ProgressDialog.NextStep(('Ignored'));
//                     //Field Update
//                     if DMTImportSettings.UpdateFieldsFilter() <> '' then begin
//                         //Log.IncNoOfSuccessfullyProcessedRecords();
//                     end;
//                 end;
//             ResultType::ChangesApplied:
//                 ProgressDialog.NextStep('ResultOK');
//             else begin
//                 Error('Unhandled Case %1', ResultType::" ");
//             end;
//         end;
//         ProgressDialog.UpdateFieldControl('NoofRecord', StrSubstNo('%1 / %2', ProgressDialog.GetStep('Process'), ProgressDialog.GetTotalStep('Process')));
//         ProgressDialog.UpdateControlWithCustomDuration('Duration', 'Progress');
//         ProgressDialog.UpdateProgressBar('Progress', 'Process');
//         ProgressDialog.UpdateFieldControl('TimeRemaining', ProgressDialog.GetRemainingTime('Progress', 'Process'));
//     end;

//     procedure FindCollationProblems(RecordMapping: Dictionary of [RecordId, RecordId]) CollationProblems: Dictionary of [RecordId, RecordId]
//     var
//         TargetRecID: RecordId;
//         LastIndex, ListIndex : Integer;
//     begin
//         for ListIndex := 1 to RecordMapping.Values.Count do begin
//             TargetRecID := RecordMapping.Values.Get(ListIndex);
//             LastIndex := RecordMapping.Values.LastIndexOf(TargetRecID);
//             if LastIndex <> ListIndex then begin
//                 CollationProblems.Add(RecordMapping.Keys.Get(ListIndex), RecordMapping.Values.Get(ListIndex));
//                 CollationProblems.Add(RecordMapping.Keys.Get(LastIndex), RecordMapping.Values.Get(LastIndex));
//             end;
//         end;
//     end;

//     procedure CheckMappedFieldsExist(ImportConfigHeader: Record DMTImportConfigHeader)
//     var
//         ImportConfigLine: Record DMTImportConfigLine;
//         ImportConfigLineEmptyErr: Label 'No field mapping found for import configuration "%1"',
//                         Comment = 'de-DE=Importkonfiguration "%1" enthält keine Feldzuordnung.';
//     begin
//         // Key Fields Mapping Exists
//         ImportConfigHeader.FilterRelated(ImportConfigLine);
//         ImportConfigLine.SetFilter("Processing Action", '<>%1', ImportConfigLine."Processing Action"::Ignore);
//         ImportConfigLine.SetRange("Is Key Field(Target)", true);
//         ImportConfigLine.SetFilter("Source Field No.", '<>0');

//         if ImportConfigLine.IsEmpty then
//             Error(ImportConfigLineEmptyErr, ImportConfigHeader.ID);
//     end;

//     procedure ListOfBufferRecIDsInner(var recIdToProcessList: List of [RecordId]; var Log: Codeunit DMTLog; importSettings: Codeunit DMTImportSettings) IsFullyProcessed: Boolean
//     var
//         // DMTErrorLog: Record DMTErrorLog;
//         importConfigHeader: Record DMTImportConfigHeader;
//         DMTSetup: Record DMTSetup;
//         progressDialog: Codeunit DMTProgressDialog;
//         ID: RecordId;
//         bufferRef: RecordRef;
//         bufferRef2: RecordRef;
//         ResultType: Enum DMTProcessingResultType;
//         iReplacementHandler: Interface IReplacementHandler;
//         iTriggerLog: Interface ITriggerLog;
//     begin
//         if recIdToProcessList.Count = 0 then
//             Error('Keine Daten zum Verarbeiten');

//         importConfigHeader := importSettings.ImportConfigHeader();
//         // init replacement handler
//         DMTSetup.getDefaultReplacementImplementation(iReplacementHandler);
//         iReplacementHandler.InitBatchProcess(importConfigHeader);

//         DMTSetup.getDefaultTriggerLogImplementation(iTriggerLog);

//         // Buffer loop
//         importConfigHeader.BufferTableMgt().InitBufferRef(bufferRef);
//         // bufferRef.Open(importConfigHeader."Buffer Table ID");
//         ID := recIdToProcessList.Get(1);
//         bufferRef.Get(ID);

//         IsFullyProcessed := true;
//         PrepareProgressBar(progressDialog, importConfigHeader, bufferRef);
//         progressDialog.Open();
//         foreach ID in recIdToProcessList do begin
//             bufferRef.Get(ID);
//             bufferRef2 := bufferRef.Duplicate(); // Variant + Events = Call By Reference 
//             ProcessSingleBufferRecord(bufferRef2, importSettings, Log, iTriggerLog, ResultType);
//             Log.IncNoOfProcessedRecords();
//             if ResultType = ResultType::ChangesApplied then begin
//                 Log.IncNoOfSuccessfullyProcessedRecords();
//             end;
//             if ResultType = ResultType::Error then begin
//                 Log.IncNoOfRecordsWithErrors();
//                 if importSettings.StopProcessingRecIDListAfterError() then begin
//                     exit(false); // break;
//                 end;
//             end;
//             UpdateProgress(importSettings, progressDialog, ResultType);
//         end;
//     end;

//     procedure AssignFieldWithoutValidate(var TargetRef: RecordRef; SourceRef: RecordRef; var importConfigLine: Record DMTImportConfigLine; DoModify: Boolean)
//     var
//         RefHelper: Codeunit DMTRefHelper;
//         FromField: FieldRef;
//         ToField: FieldRef;
//         EvaluateOptionValueAsNumber: Boolean;
//     begin
//         // Check - Don't copy from or to timestamp
//         if (importConfigLine."Source Field No." = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter FromFieldNo = 0');
//         if (importConfigLine."Target Field No." = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter ToFieldNo = 0');
//         EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRef.Number);
//         FromField := SourceRef.Field(importConfigLine."Source Field No.");
//         ToField := TargetRef.Field(importConfigLine."Target Field No.");
//         if ToField.Type = FromField.Type then
//             ToField.Value := FromField.Value
//         else
//             if not RefHelper.EvaluateFieldRef(ToField, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
//                 Error('Evaluating "%1" into "%2" failed', FromField.Value, ToField.Caption);
//         // ApplyReplacements(ImportConfigLine, ToField);
//         if DoModify then
//             TargetRef.Modify();
//     end;
// }