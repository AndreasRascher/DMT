codeunit 91020 DMTImportCSVImpl implements ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        genBuffTable: Record DMTGenBuffTable;
        SourceFileStorage: Record DMTSourceFileStorage;
        CSVReader: XmlPort DMTCSVReader;
    begin
        // Delete existing lines
        if genBuffTable.FilterBy(ImportConfigHeader) then
            genBuffTable.DeleteAll();

        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        PrepareXMLPortWithCSVOptionsAndSourceFile(SourceFileStorage, ImportConfigHeader.GetDataLayout(), CSVReader);
        CSVReader.InitImportToGenBuffer(SourceFileStorage, ImportConfigHeader);
        CSVReader.Import();
        HasToLargeTextValuesGlobal := CSVReader.HasTooLargeTextValues();
        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text]);
    var
        CSVReader: XmlPort DMTCSVReader;
    begin
        PrepareXMLPortWithCSVOptionsAndSourceFile(sourceFileStorage, dataLayout, CSVReader);
        // read top 5 rows if undefined
        if dataLayout."HeadingRowNo" = 0 then
            CSVReader.InitReadRows(1, 5)
        else
            CSVReader.InitReadRows(dataLayout."HeadingRowNo", dataLayout."HeadingRowNo");
        CSVReader.Import();
        HeaderLine := CSVReader.GetHeadlineColumnValues(FirstRowWithValues);
    end;

    local procedure PrepareXMLPortWithCSVOptionsAndSourceFile(SourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var CSVReader: XmlPort DMTCSVReader)
    begin
        SourceFileStorage.TestField(Name);
        SourceFileStorage.GetFileAsTempBlob(FileBlobGlobal);
        FileBlobGlobal.CreateInStream(FileStreamGlobal);

        dataLayout.TestField(CSVFieldDelimiter);
        dataLayout.TestField(CSVFieldSeparator);
        dataLayout.TestField(CSVLineSeparator);

        CSVReader.FieldDelimiter := dataLayout.CSVFieldDelimiter;
        CSVReader.FieldSeparator := ReplacePlaceHolder(dataLayout.CSVFieldSeparator);
        CSVReader.RecordSeparator := ReplacePlaceHolder(dataLayout.CSVLineSeparator);
        case dataLayout.CSVTextEncoding of
            dataLayout.CSVTextEncoding::MSDos:
                CSVReader.TextEncoding := TextEncoding::MSDos;
            dataLayout.CSVTextEncoding::UTF8:
                CSVReader.TextEncoding := TextEncoding::UTF8;
            dataLayout.CSVTextEncoding::UTF16:
                CSVReader.TextEncoding := TextEncoding::UTF16;
            dataLayout.CSVTextEncoding::Windows:
                CSVReader.TextEncoding := TextEncoding::Windows;
        end;
        CSVReader.SetSource(FileStreamGlobal);
    end;

    local procedure ReplacePlaceHolder(textWithPlaceholders: text) Result: Text
    var
        CRLF: Text[2];
        TAB: Text[1];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        TAB[1] := 9;
        //<None>,<CR/LF>,<CR>,<LF>,<TAB>
        Result := textWithPlaceholders;
        Result := Result.Replace('<CR>', CRLF[1]);
        Result := Result.Replace('<LF>', CRLF[2]);
        Result := Result.Replace('<CR/LF>', CRLF);
        Result := Result.Replace('<TAB>', TAB);
        Result := Result.Replace('<None>', '');
    end;

    procedure TooLargeValuesHaveBeenCutOffWarningIfRequired()
    var
        TooLargeValuesHaveBeenCutOffMsg: Label 'too large field values have been cut off. Max. string length is 250 chars',
                                           Comment = 'de-DE=Achtung, beim Import wurden zu lange Feldwerte abgeschnitten. Max. Textlänge ist 250 Zeichen';
    begin
        if HasToLargeTextValuesGlobal then
            Message(TooLargeValuesHaveBeenCutOffMsg);
    end;

    var
        FileStreamGlobal: InStream;
        FileBlobGlobal: Codeunit "Temp Blob";
        HasToLargeTextValuesGlobal: Boolean;
}