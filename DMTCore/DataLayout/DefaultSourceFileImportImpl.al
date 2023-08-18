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

    procedure ShowTooLargeValuesHaveBeenCutOffWarningIfRequired(sourceFileStorage: Record DMTSourceFileStorage; largeTextColCaptions: Dictionary of [Integer, Text])
    var
        TooLargeValuesHaveBeenCutOffMsg: Label 'too large field values have been cut off. Max. string length is 250 chars.\Filename: "%1"\Columns: "%2."',
                               Comment = 'de-DE=Zu lange Feldwerte wurden abgeschnitten. Max. Textlänge ist 250 Zeichen.\Dateiname: "%1"\Betroffene Spalten: "%2."';
        ColCaption, ColCaptionsList : Text;
    begin
        foreach ColCaption in largeTextColCaptions.Values do begin
            ColCaptionsList += ',' + ColCaption;
        end;
        ColCaptionsList := ColCaptionsList.TrimStart(',');
        if ColCaptionsList <> '' then
            Message(TooLargeValuesHaveBeenCutOffMsg, sourceFileStorage.Name, ColCaptionsList);
    end;
}