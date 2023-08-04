codeunit 91004 DMTDefaultSourceFileImportImpl implements ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    begin
        Error('ISourceFileImport "ImportToBufferTable" not implemented. Data Layout Type "%1"', ImportConfigHeader.GetDataLayout().SourceFileFormat);
    end;

    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text]);
    begin
        Error('ISourceFileImport "ReadHeadline" not implemented. Data Layout Type "%1"', dataLayout.SourceFileFormat);
    end;
}