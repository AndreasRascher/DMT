codeunit 91020 DMTImportCSVImpl implements ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        DMTLogEntry: Record DMTLogEntry;
        DMTTriggerLogEntry: Record DMTTriggerLogEntry;
        SourceFileStorage: Record DMTSourceFileStorage;
        defaultSourceFileImportImpl: Codeunit DMTDefaultSourceFileImportImpl;
        sessionStorage: Codeunit DMTSessionStorage;
        CSVReader: XmlPort DMTCSVReader;
        largeTextColCaptions: Dictionary of [Integer, Text];
    begin
        sessionStorage.LastLineRead(0);
        ImportConfigHeader.BufferTableMgt().DeleteAllBufferData(); // Delete existing lines
        if DMTLogEntry.FilterFor(ImportConfigHeader) then // Delete Error Log because it references the old autoincr. Line IDs
            DMTLogEntry.DeleteAll();
        if DMTTriggerLogEntry.FilterFor(ImportConfigHeader) then // Delete Trigger Log because it references the old autoincr. Line IDs
            DMTTriggerLogEntry.DeleteAll();
        if not ImportViaSeparateXMLPort(ImportConfigHeader) then begin
            SourceFileStorage.Get(ImportConfigHeader."Source File ID");
            PrepareXMLPortWithCSVOptionsAndSourceFile(SourceFileStorage, ImportConfigHeader.GetDataLayout(), CSVReader);
            CSVReader.InitImportToGenBuffer(SourceFileStorage, ImportConfigHeader);
            CSVReader.Import();
            largeTextColCaptions := CSVReader.LargeTextColCaptions();
            defaultSourceFileImportImpl.ShowTooLargeValuesHaveBeenCutOffWarningIfRequired(SourceFileStorage, largeTextColCaptions);
        end;
        ImportConfigHeader.UpdateBufferRecordCount();
    end;

    local procedure ImportViaSeparateXMLPort(importConfigHeader: Record DMTImportConfigHeader) HasBeenImported: Boolean
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        AllObjWithCaption: Record AllObjWithCaption;
        xmlPortNotFoundErr: Label 'XMLPort %1 not found', Comment = 'de-DE=XMLPort %1 ist nicht vorhanden.';
    begin
        if not importConfigHeader.UseSeparateXMLPort() then exit(false);
        if importConfigHeader."Import XMLPort ID" = 0 then exit(false);
        // Validate XMLPort exists
        if not AllObjWithCaption.get(AllObjWithCaption."Object Type"::XMLport, importConfigHeader."Import XMLPort ID") then
            Error(xmlPortNotFoundErr, importConfigHeader."Import XMLPort ID");
        sourceFileStorage.Get(ImportConfigHeader."Source File ID");
        sourceFileStorage.TestField(Name);
        sourceFileStorage.GetFileAsTempBlob(FileBlobGlobal);
        FileBlobGlobal.CreateInStream(FileStreamGlobal);
        Xmlport.Import(importConfigHeader."Import XMLPort ID", FileStreamGlobal);
        HasBeenImported := true;
    end;

    procedure ReadHeadline(sourceFileStorage: Record DMTSourceFileStorage; dataLayout: Record DMTDataLayout; var FirstRowWithValues: Integer; var HeaderLine: List of [Text]);
    var
        CSVReader: XmlPort DMTCSVReader;
    begin
        PrepareXMLPortWithCSVOptionsAndSourceFile(sourceFileStorage, dataLayout, CSVReader);
        // read top 5 rows if undefined
        if dataLayout.HeadingRowNo = 0 then
            CSVReader.InitReadRows(1, 5)
        else
            CSVReader.InitReadRows(dataLayout.HeadingRowNo, dataLayout.HeadingRowNo);
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

    var
        FileBlobGlobal: Codeunit "Temp Blob";
        FileStreamGlobal: InStream;
}