codeunit 90001 DMTSourceFileMgt
{
    internal procedure UploadFileIntoFileStorage()
    var
        Setup: Record DMTSetup;
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        UploadFileMsg: Label 'Select a file to upload', comment = 'de-DE=Wählen Sie eine Datei zum Hochladen aus';
        ImportFinishedMsg: Label 'Import finished', comment = 'de-DE=Import abgeschlossen';
        OuStr: OutStream;
        FileName: Text;
        ServerFilePath: Text;
    begin
        TempBlob.CreateInStream(InStr);
        if not UploadIntoStream(UploadFileMsg, '', Format(Enum::DMTFileFilter::All), FileName, InStr) then
            exit;
        if not GetFilesFromZipFile(FileName, InStr) then begin
            AddFileToStorage(FileName, TempBlob);
        end;
        Message(ImportFinishedMsg);
    end;

    local procedure AddFileToStorage(FileName: Text; var TempBlob: Codeunit "Temp Blob")
    var
        FileManagement: Codeunit "File Management";
        SourceFileStorage: Record DMTSourceFileStorage;
        NextFileID: Integer;
        BlobRef: FieldRef;
        OStr: OutStream;
        IStr: InStream;
    begin
        NextFileID := 1;
        if SourceFileStorage.FindLast() then
            NextFileID += SourceFileStorage."File ID";

        Clear(SourceFileStorage);
        SourceFileStorage."File ID" := NextFileID;
        SourceFileStorage.Calcfields("File Blob");
        SourceFileStorage."File Blob".CreateOutStream(OStr);
        TempBlob.CreateInStream(IStr);
        CopyStream(OStr, IStr);
        SourceFileStorage.Name := FileManagement.GetFileName(FileName);
        SourceFileStorage.Path := FileManagement.GetDirectoryName(FileName);
        SourceFileStorage.Extension := FileManagement.GetExtension(FileName);
        SourceFileStorage.Size := TempBlob.Length();
        SourceFileStorage.UploadDateTime := CurrentDateTime;
        SourceFileStorage.Insert();
    end;

    procedure GetFilesFromZipFile(FileName: Text; var InStr: InStream) OK: Boolean
    var
        CompressedFiles: List of [Text];
        FileNameInArchive: Text;
        FilenamesFound: Text;
        Choice: Integer;
        EntryList: List of [Text];
        TempTenantMedia: Record "Tenant Media" temporary;
        OStream: OutStream;
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
    begin
        If not FileName.ToLower().EndsWith('zip') then
            exit(false);
        DataCompression.OpenZipArchive(InStr, false);
        DataCompression.GetEntryList(EntryList);
        foreach FileNameInArchive in EntryList do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OStream);
            DataCompression.ExtractEntry(FileNameInArchive, OStream);
            AddFileToStorage(FileNameInArchive, TempBlob);
        end;
        exit(true);
    end;



}