codeunit 91015 DMTProcessingPlanMgt
{
    internal procedure ImportWithProcessingPlanParams(ProcessingPlan: Record DMTProcessingPlan)
    var
        Migrate: Codeunit DMTMigrate;
    begin
        Migrate.BufferFor(ProcessingPlan);
    end;

    internal procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader; HideDialog: Boolean)
    var
        SourceFileImport: Interface ISourceFileImport;
    begin
        SourceFileImport := ImportConfigHeader.GetDataLayout().SourceFileFormat;
        SourceFileImport.ImportToBufferTable(ImportConfigHeader);
    end;
}