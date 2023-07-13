codeunit 91010 DMTImportSettings
{
    procedure SourceTableView(SourceTableViewNEW: Text)
    begin
        SourceTableViewGlobal := SourceTableViewNEW;
    end;

    procedure SourceTableView() SourceTableView: Text
    begin
        exit(SourceTableViewGlobal);
    end;

    procedure SetFieldMapping(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    begin
        TempFieldMappingGlobal.Copy(TempImportConfigLine, true);
    end;

    procedure GetFieldMapping(var TempImportConfigLine: Record DMTImportConfigLine temporary)
    begin
        if TempFieldMappingGlobal.IsEmpty then
            Error('FieldMapping empty');
        TempImportConfigLine.Copy(TempFieldMappingGlobal, true);
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
        ImportConfigHeader.CalcFields("Target Table Caption");
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

    var
        TempFieldMappingGlobal: Record DMTFieldMapping temporary;
        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        ProcessingPlanGlobal: Record DMTProcessingPlan;
        SourceTableViewGlobal, UpdateFieldsFilterGlobal : Text;
        StopProcessingRecIDListAfterErrorGlobal, NoUserInteractionGlobal, UpdateExistingRecordsOnlyGlobal : Boolean;
        RecIdToProcessListGlobal: List of [RecordId];
}