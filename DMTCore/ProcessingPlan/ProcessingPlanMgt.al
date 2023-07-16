codeunit 91015 DMTProcessingPlanMgt
{
    internal procedure ImportWithProcessingPlanParams(ProcessingPlan: Record DMTProcessingPlan)
    begin
        Error('Procedure ImportWithProcessingPlanParams not implemented.');
    end;

    internal procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader; HideDialog: Boolean)
    var
        SourceFileImport: Interface ISourceFileImport;
    begin
        SourceFileImport := ImportConfigHeader.GetDataLayout().SourceFileFormat;
        SourceFileImport.ImportToBufferTable(ImportConfigHeader);
    end;
}