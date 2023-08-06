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
            AddFileToStorage(FileName, IStr, true);
        end;
        Message(ImportFinishedMsg);
    end;

    local procedure AddFileToStorage(FileName: Text; IStr: InStream; ReplaceFilesWithSameName: Boolean)
    var
        SourceFileStorage, SourceFileStorageExisting : Record DMTSourceFileStorage;
        FileManagement: Codeunit "File Management";
        NextFileID: Integer;
        OStr: OutStream;
        fileBaseName, fileExtension : Text;
    begin
        NextFileID := 1;
        if SourceFileStorage.FindLast() then
            NextFileID += SourceFileStorage."File ID";

        fileBaseName := FileManagement.GetFileName(FileName);
        fileExtension := FileManagement.GetExtension(FileName);

        if ReplaceFilesWithSameName then begin
            Clear(SourceFileStorageExisting);
            SourceFileStorageExisting.SetRange(Name, fileBaseName);
            SourceFileStorageExisting.SetRange(Extension, fileExtension);
            if not SourceFileStorageExisting.IsEmpty then
                SourceFileStorageExisting.DeleteAll();
        end;

        Clear(SourceFileStorage);
        SourceFileStorage."File ID" := NextFileID;
        SourceFileStorage."File Blob".CreateOutStream(OStr);
        CopyStream(OStr, IStr);
        SourceFileStorage.Name := CopyStr(fileBaseName, 1, MaxStrLen(SourceFileStorage.Name));
        SourceFileStorage.Extension := CopyStr(fileExtension, 1, MaxStrLen(SourceFileStorage.Extension));
        SourceFileStorage.UploadDateTime := CurrentDateTime;
        SourceFileStorage.Size := SourceFileStorage."File Blob".Length;
        AssignSourceFileFormat(SourceFileStorage);
        SourceFileStorage.Insert();
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
        foreach FileNameInArchive in EntryList do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OStream);
            DataCompression.ExtractEntry(FileNameInArchive, OStream);
            TempBlob.CreateInStream(IStr);
            AddFileToStorage(FileNameInArchive, IStr, true);
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



}