codeunit 91020 DMTImportCSVImpl implements ISourceFileImport
{
    procedure ImportToBufferTable(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        genBuffTable: Record DMTGenBuffTable;
        SourceFileStorage: Record DMTSourceFileStorage;
        dataLayout: Record DMTDataLayout;
        TempBlob: Codeunit "Temp Blob";
        CSVReader: XmlPort DMTCSVReader;
        InStr: InStream;
    begin
        // Delete existing lines
        if genBuffTable.FilterBy(ImportConfigHeader) then
            genBuffTable.DeleteAll();

        // Read File Blob
        SourceFileStorage.Get(ImportConfigHeader."Source File ID");
        SourceFileStorage.TestField(Name);
        SourceFileStorage.GetFileAsTempBlob(TempBlob);
        TempBlob.CreateInStream(InStr);

        dataLayout := ImportConfigHeader.GetDataLayout();
        dataLayout.TestField(CSVFieldDelimiter);
        dataLayout.TestField(CSVFieldSeparator);
        dataLayout.TestField(CSVLineSeparator);

        CSVReader.FieldDelimiter := dataLayout.CSVFieldDelimiter;
        CSVReader.FieldSeparator := dataLayout.CSVFieldSeparator;
        CSVReader.RecordSeparator := dataLayout.CSVLineSeparator;
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
        CSVReader.InitImportToGenBuffer(SourceFileStorage, dataLayout.HeadingRowNo);
        CSVReader.SetSource(InStr);
        CSVReader.Import();
        ImportConfigHeader.UpdateBufferRecordCount();
    end;
}