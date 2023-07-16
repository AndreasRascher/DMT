codeunit 91004 DMTDefaultSourceFileImportImpl implements ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    begin
        Error('ISourceFileImport "ImportToBufferTable" not implemented. Data Layout Type "%1"', ImportConfigHeader.GetDataLayout().SourceFileFormat);
    end;
}