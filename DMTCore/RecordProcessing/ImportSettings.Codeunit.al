codeunit 91010 DMTImportSettings
{
    procedure init(importConfigHeaderNEW: Record DMTImportConfigHeader; migrationType: Enum DMTMigrationType)
    begin
        ImportConfigHeaderGlobal.Copy(importConfigHeaderNEW);
        SourceTableView(importConfigHeaderNEW.ReadLastUsedSourceTableView());
        case migrationType of
            migrationType::MigrateRecords:
                begin
                    UpdateExistingRecordsOnlyGlobal := false;
                end;
            migrationType::MigrateSelectsFields:
                begin
                    UpdateExistingRecordsOnlyGlobal := true;
                    UpdateFieldsFilter(importConfigHeaderNEW.ReadLastFieldUpdateSelection());
                end;
            migrationType::ApplyFixValuesToTarget:
                begin
                    UpdateExistingRecordsOnlyGlobal := true;
                end;
        end;
    end;

    procedure init(processingPlanNEW: Record DMTProcessingPlan; migrationType: Enum DMTMigrationType)
    var
        importConfigHeaderNEW: Record DMTImportConfigHeader;
    begin
        ProcessingPlanGlobal.Copy(processingPlanNEW);
        SourceTableView(processingPlanNEW.ReadSourceTableView());
        if processingPlanNEW.findImportConfigHeader(importConfigHeaderNEW) then
            ImportConfigHeaderGlobal.Copy(importConfigHeaderNEW);

        case processingPlanNEW.Type of
            processingPlanNEW.Type::"Group", processingPlanNEW.Type::"Run Codeunit":
                begin
                    Error('ProcessingPlan Type %1 not supported', processingPlanNEW.Type);
                end;
            processingPlanNEW.Type::"Buffer + Target", processingPlanNEW.Type::"Import To Target":
                begin
                    UpdateExistingRecordsOnlyGlobal := false;
                end;
            processingPlanNEW.Type::"Update Field", processingPlanNEW.Type::"Enter default values in target table":
                begin
                    UpdateExistingRecordsOnlyGlobal := true;
                end;
            else begin
                Error('unhandled ProcessingPlan Type %1', processingPlanNEW.Type);
            end;
        end;
    end;

    procedure SourceTableView(sourceTableViewNew: Text)
    begin
        IsSourceTableViewSet := true;
        SourceTableViewGlobal := sourceTableViewNew;
    end;

    procedure SourceTableView(): Text
    begin
        if not IsSourceTableViewSet then
            Error('SourceTableView not set');
        exit(SourceTableViewGlobal);
    end;

    procedure SetImportConfigLine(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    begin
        TempImportConfigLineGlobal.Copy(TempImportConfigLine, true);
        IsImportConfigLineSet := true;
    end;

    procedure GetImportConfigLine(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    begin
        if not IsImportConfigLineSet then
            Error('ImportConfigLine not set');
        if TempImportConfigLineGlobal.IsEmpty then
            Error('ImportConfigLine empty');
        TempImportConfigLine.Copy(TempImportConfigLineGlobal, true);
    end;

    procedure NoUserInteraction(NoUserInteractionNew: Boolean)
    begin
        NoUserInteractionGlobal := NoUserInteractionNew;
    end;

    procedure NoUserInteraction() NoUserInteraction: Boolean
    begin
        exit(NoUserInteractionGlobal);
    end;

    procedure StopProcessingRecIDListAfterError(StopProcessingRecIDListAfterErrorNew: Boolean)
    begin
        StopProcessingRecIDListAfterErrorGlobal := StopProcessingRecIDListAfterErrorNew;
    end;

    procedure StopProcessingRecIDListAfterError() StopProcessingRecIDListAfterError: Boolean
    begin
        exit(StopProcessingRecIDListAfterErrorGlobal);
    end;

    procedure ImportConfigHeader(var ImportConfigHeaderNew: Record DMTImportConfigHeader)
    begin
        ImportConfigHeaderGlobal.Copy(ImportConfigHeaderNew);
    end;

    procedure ImportConfigHeader() ImportConfigHeader: Record DMTImportConfigHeader
    var
        notInitializedErr: Label '%1 is not initialized', Comment = 'de-DE=%1 ist nicht initialisiert';
    begin
        if ImportConfigHeaderGlobal.ID = 0 then
            Error(notInitializedErr, ImportConfigHeaderGlobal.TableCaption);
        exit(ImportConfigHeaderGlobal);
    end;

    procedure ProcessingPlan(var ProcessingPlanNew: Record DMTProcessingPlan)
    begin
        ProcessingPlanGlobal.Copy(ProcessingPlanNew);
    end;

    procedure ProcessingPlan() ProcessingPlan: Record DMTProcessingPlan
    begin
        exit(ProcessingPlanGlobal);
    end;

    procedure UpdateFieldsFilter(UpdateFieldsFilterNew: Text)
    begin
        UpdateFieldsFilterGlobal := UpdateFieldsFilterNew;
    end;

    procedure UpdateFieldsFilter() UpdateFieldsFilter: Text
    begin
        exit(UpdateFieldsFilterGlobal);
    end;

    procedure RecIdToProcessList(var RecIdToProcessListNew: List of [RecordId])
    begin
        RecIdToProcessListGlobal := RecIdToProcessListNew;
    end;

    procedure RecIdToProcessList(): List of [RecordId]
    begin
        exit(RecIdToProcessListGlobal);
    end;

    procedure UpdateExistingRecordsOnly(UpdateExistingRecordsOnlyNew: Boolean)
    begin
        UpdateExistingRecordsOnlyGlobal := UpdateExistingRecordsOnlyNew;
    end;

    procedure UpdateExistingRecordsOnly(): Boolean
    begin
        exit(UpdateExistingRecordsOnlyGlobal);
    end;

    procedure UpdateUnchangedSinceLastImportOnly(UpdateUnchangedSinceLastImportOnlyNew: Boolean)
    begin
        UpdateUnchangedSinceLastImportOnlyGlobal := UpdateUnchangedSinceLastImportOnlyNew;
    end;

    procedure UpdateUnchangedSinceLastImportOnly(): Boolean
    begin
        exit(UpdateUnchangedSinceLastImportOnlyGlobal);
    end;

    internal procedure UseTriggerLog(useTriggerLogNew: Boolean)
    begin
        UseTriggerLogGlobal := useTriggerLogNew;
    end;

    internal procedure UseTriggerLog(): Boolean
    begin
        exit(UseTriggerLogGlobal);
    end;

    procedure EvaluateOptionValueAsNumber(EvaluateOptionValueAsNumberNew: Boolean)
    begin
        EvaluateOptionValueAsNumberGlobal := EvaluateOptionValueAsNumberNew;
    end;

    procedure EvaluateOptionValueAsNumber(): Boolean
    begin
        exit(EvaluateOptionValueAsNumberGlobal);
    end;

    var
        TempImportConfigLineGlobal: Record DMTImportConfigLine temporary;
        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        ProcessingPlanGlobal: Record DMTProcessingPlan;
        SourceTableViewGlobal, UpdateFieldsFilterGlobal : Text;
        StopProcessingRecIDListAfterErrorGlobal, NoUserInteractionGlobal, UpdateExistingRecordsOnlyGlobal, UpdateUnchangedSinceLastImportOnlyGlobal : Boolean;
        UseTriggerLogGlobal: Boolean;
        IsSourceTableViewSet, IsImportConfigLineSet : Boolean;
        EvaluateOptionValueAsNumberGlobal: Boolean;
        RecIdToProcessListGlobal: List of [RecordId];
}