codeunit 91001 DMTSourceFileMgt
{
    internal procedure UploadFileIntoFileStorage()
    var
        uploadedFile: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
        UploadFileMsg: Label 'Select a file to upload', Comment = 'de-DE=Wählen Sie eine Datei zum Hochladen aus';
        FileName: Text;
        length: Integer;
    begin
        uploadedFile.CreateInStream(IStr);
        if not UploadIntoStream(UploadFileMsg, '', Format(Enum::DMTFileFilter::All), FileName, IStr) then
            exit;
        uploadedFile.CreateOutStream(OStr);
        CopyStream(OStr, IStr);
        length := uploadedFile.Length;

        if not GetFilesFromZipFile(FileName, uploadedFile) then begin
            AddFileToStorage(FileName, uploadedFile);
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

    procedure AddFileToStorage(FileName: Text; uploadedFile: Codeunit "Temp Blob") fileID: Integer
    var
        SourceFileStorage, SourceFileStorageExisting : Record DMTSourceFileStorage;
        FileManagement: Codeunit "File Management";
        NextFileID: Integer;
        IStr: InStream;
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
        uploadedFile.CreateInStream(IStr);
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

    local procedure GetFilesFromZipFile(FileName: Text; var uploadedFile: Codeunit "Temp Blob") OK: Boolean
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        EntryList: List of [Text];
        OStream: OutStream;
        IStr: InStream;
        FileNameInArchive: Text;
        codepageIndex: Integer;
        codepages: List of [Integer];
        invalidFileNameChars: List of [Text];
    begin
        // codepages.AddRange(37, 437, 500, 708, 720, 737, 775, 850, 852, 855, 857, 858, 860, 861, 862, 863, 864, 865, 866, 869, 870, 874, 875, 932, 936, 949, 950, 1026, 1047, 1140, 1141, 1142, 1143, 1144, 1145, 1146, 1147, 1148, 1149, /*1200, 1201,*/ 1250, 1251, 1252, 1253, 1254, 1255, 1256, 1257, 1258, 1361, 10000, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10010, 10017, 10021, 10029, 10079, 10081, 10082, 12000, 12001, 20000, 20001, 20002, 20003, 20004, 20005, 20105, 20106, 20107, 20108, 20127, 20261, 20269, 20273, 20277, 20278, 20280, 20284, 20285, 20290, 20297, 20420, 20423, 20424, 20833, 20838, 20866, 20871, 20880, 20905, 20924, 20932, 20936, 20949, 21025, 21866, 28591, 28592, 28593, 28594, 28595, 28596, 28597, 28598, 28599, 28603, 28605, 29001, 38598, 50220, 50221, 50222, 50225, 50227, 51932, 51936, 51949, 52936, 54936, 57002, 57003, 57004, 57005, 57006, 57007, 57008, 57009, 57010, 57011, 65001);
        //List of codepages: https://learn.microsoft.com/de-de/dotnet/api/system.text.encoding.getencodings?view=net-8.0
        // Umlaute in Dateinamem werden sonst nicht richtig dargestellt 
        codepages.AddRange(850/*ibm850*/, 65001/*UTF-8*/);
        invalidFileNameChars.AddRange('├ñ'/*ä*/);

        OK := true;
        if not FileName.ToLower().EndsWith('zip') then
            exit(false);

        repeat
            Clear(IStr);
            Clear(EntryList);
            codepageIndex += 1;
            if codepageIndex <= codepages.Count then begin
                uploadedFile.CreateInStream(IStr);
                DataCompression.OpenZipArchive(IStr, false, codepages.Get(codepageIndex));
                DataCompression.GetEntryList(EntryList);
            end else begin
                break;
            end;
        until not fileNamesContainInvalidChars(EntryList, invalidFileNameChars, codepages);

        foreach FileNameInArchive in EntryList do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OStream);
            DataCompression.ExtractEntry(FileNameInArchive, OStream);
            AddFileToStorage(FileNameInArchive, TempBlob);
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

    local procedure fileNamesContainInvalidChars(EntryList: List of [Text]; invalidFileNameChars: List of [Text]; codepages: List of [Integer]) hasInvalidChars: Boolean
    var
        FileNameInArchive, invalidFileNameChar : Text;
    begin
        hasInvalidChars := false;
        foreach fileNameInArchive in EntryList do
            foreach invalidFileNameChar in invalidFileNameChars do
                if fileNameInArchive.Contains(invalidFileNameChar) then
                    exit(true);
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