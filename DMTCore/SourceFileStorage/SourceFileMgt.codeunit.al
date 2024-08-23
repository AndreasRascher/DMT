codeunit 91001 DMTSourceFileMgt
{
    internal procedure UploadFileIntoFileStorage()
    var
        TempBlob: Codeunit "Temp Blob";
        IStr: InStream;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
        UploadFileMsg: Label 'Select a file to upload', Comment = 'de-DE=Wählen Sie eine Datei zum Hochladen aus';
        FileName: Text;
    begin
        TempBlob.CreateInStream(IStr);
        if not UploadIntoStream(UploadFileMsg, '', Format(Enum::DMTFileFilter::All), FileName, IStr) then
            exit;

        if not GetFilesFromZipFile(FileName, IStr) then begin
            AddFileToStorage(FileName, IStr);
        end;
        Message(ImportFinishedMsg);
    end;

    internal procedure DownloadSourceFile(Rec: Record DMTSourceFileStorage)
    var
        IStream: InStream;
        toFileName: Text;
    begin
        Rec.CalcFields("File Blob");
        if not Rec."File Blob".HasValue then
            exit;
        rec."File Blob".CreateInStream(IStream);
        toFileName := rec.Name;
        DownloadFromStream(IStream, 'Download', 'Download', Format(Enum::DMTFileFilter::All), toFileName);
    end;

    procedure AddFileToStorage(FileName: Text; IStr: InStream) fileID: Integer
    var
        SourceFileStorage, SourceFileStorageExisting : Record DMTSourceFileStorage;
        FileManagement: Codeunit "File Management";
        NextFileID: Integer;
        OStr: OutStream;
        fileBaseName, fileExtension : Text;
        IsUpdate: Boolean;
    begin
        NextFileID := 1;
        if SourceFileStorage.FindLast() then
            NextFileID += SourceFileStorage."File ID";

        fileBaseName := FileManagement.GetFileName(FileName);
        fileExtension := FileManagement.GetExtension(FileName);

        IsUpdate := findFileByName(SourceFileStorageExisting, fileBaseName, fileExtension);

        if IsUpdate then begin
            SourceFileStorage := SourceFileStorageExisting;
            Clear(SourceFileStorage."File Blob");
        end else begin
            Clear(SourceFileStorage);
            SourceFileStorage."File ID" := NextFileID;
            SourceFileStorage.Insert();
        end;

        // Save Filestream
        SourceFileStorage."File Blob".CreateOutStream(OStr);
        CopyStream(OStr, IStr);

        // Save / Update File Properties
        SourceFileStorage.Name := CopyStr(fileBaseName, 1, MaxStrLen(SourceFileStorage.Name));
        SourceFileStorage.Extension := CopyStr(fileExtension, 1, MaxStrLen(SourceFileStorage.Extension));
        SourceFileStorage.UploadDateTime := CurrentDateTime;
        SourceFileStorage.Validate(Size, SourceFileStorage."File Blob".Length);
        if not IsUpdate then begin
            AssignSourceFileFormat(SourceFileStorage);
            AssignDefaultDataLayout(SourceFileStorage);
        end;
        SourceFileStorage.Modify();
        fileID := SourceFileStorage."File ID";
    end;

    local procedure GetFilesFromZipFile(FileName: Text; var InStr: InStream) OK: Boolean
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        EntryList: List of [Text];
        OStream: OutStream;
        IStr: InStream;
        FileNameInArchive: Text;
    begin
        OK := true;
        if not FileName.ToLower().EndsWith('zip') then
            exit(false);
        DataCompression.OpenZipArchive(InStr, false, 850); // Codepage 850 - Umlaute in Dateinamem werden sonst nicht richtig dargestellt 
        DataCompression.GetEntryList(EntryList);
        // TODO: Zeichensatzfehler bei Umlauten in Dateinamen("ä" = "├ñ")
        // foreach FileNameInArchive in EntryList do begin
        //     if FileNameInArchive.Contains('├ñ') then begin
        //         DataCompression.OpenZipArchive(InStr, false);
        //         DataCompression.GetEntryList(EntryList);
        //     end;
        // end;
        foreach FileNameInArchive in EntryList do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OStream);
            DataCompression.ExtractEntry(FileNameInArchive, OStream);
            TempBlob.CreateInStream(IStr);
            AddFileToStorage(FileNameInArchive, IStr);
        end;
    end;

    local procedure AssignSourceFileFormat(var sourceFileStorage: Record DMTSourceFileStorage)
    begin
        if sourceFileStorage.Name.EndsWith('.xlsx') and (sourceFileStorage.SourceFileFormat = sourceFileStorage.SourceFileFormat::" ") then begin
            sourceFileStorage.SourceFileFormat := sourceFileStorage.SourceFileFormat::Excel;
        end;

        if sourceFileStorage.Name.EndsWith('.csv') and (sourceFileStorage.SourceFileFormat = sourceFileStorage.SourceFileFormat::" ") then
            sourceFileStorage.SourceFileFormat := sourceFileStorage.SourceFileFormat::"Custom CSV";
    end;

    local procedure findFileByName(var SourceFileStorageExisting: Record DMTSourceFileStorage; fileBaseName: Text; fileExtension: Text) hasFileWithTheSameName: Boolean;
    begin
        Clear(SourceFileStorageExisting);
        SourceFileStorageExisting.SetRange(Name, fileBaseName);
        SourceFileStorageExisting.SetRange(Extension, fileExtension);
        hasFileWithTheSameName := SourceFileStorageExisting.FindFirst();
    end;

    procedure AssignDefaultDataLayout(var sourceFileStorage: Record DMTSourceFileStorage)
    var
        dataLayout: Record DMTDataLayout;
    begin
        if SourceFileStorage.SourceFileFormat = SourceFileStorage.SourceFileFormat::" " then
            exit;
        dataLayout.SetRange(SourceFileFormat, SourceFileStorage.SourceFileFormat);
        dataLayout.SetRange(Default, true);
        if dataLayout.FindFirst() then
            SourceFileStorage.Validate("Data Layout ID", dataLayout.ID);
    end;

    procedure ShowSourceFileStorageWithErrorInfo(ErrorInfoDataLayout: ErrorInfo)
    var
        sourceFileStorage: Record DMTSourceFileStorage;
    begin
        sourceFileStorage.Get(ErrorInfoDataLayout.RecordId);
        sourceFileStorage.SetRecFilter();
        page.RunModal(0, sourceFileStorage);
    end;



}