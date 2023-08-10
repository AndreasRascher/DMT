interface ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text])
    procedure TooLargeValuesHaveBeenCutOffWarningIfRequired();
}