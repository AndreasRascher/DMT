codeunit 50010 DMTImportSettings
{
    procedure SourceTableView(SourceTableViewNEW: Text)
    begin
        SourceTableViewGlobal := SourceTableViewNEW;
    end;

    procedure SourceTableView() SourceTableView: Text
    begin
        exit(SourceTableViewGlobal);
    end;

    procedure SetImportConfigLine(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    begin
        TempImportConfigLineGlobal.Copy(TempImportConfigLine, true);
    end;

    procedure GetImportConfigLine(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    begin
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
    begin

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

    var
        TempImportConfigLineGlobal: Record DMTImportConfigLine temporary;
        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        ProcessingPlanGlobal: Record DMTProcessingPlan;
        SourceTableViewGlobal, UpdateFieldsFilterGlobal : Text;
        StopProcessingRecIDListAfterErrorGlobal, NoUserInteractionGlobal, UpdateExistingRecordsOnlyGlobal, UpdateUnchangedSinceLastImportOnlyGlobal : Boolean;
        RecIdToProcessListGlobal: List of [RecordId];
}