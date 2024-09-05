codeunit 91027 DMTLicenseMgt
{
    trigger OnRun()
    begin
        importFromPemissionsReport();
    end;

    procedure importFromPemissionsReport()
    var
        uploadedFile: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
        UploadFileMsg: Label 'Upload Permission Report Detailed', Comment = 'de-DE=Permission Report Detailed hochladen';
        FileName: Text;
        length: Integer;
        lines: List of [Text];
        currentLineText, lastLineText : Text;
        startPos, i, endPos : Integer;
        objectType, quantity, rangeFrom, rangeTo, permissions : Text;
        RIMDXPermissions: List of [List of [Text]];
        RIMDXPermission: List of [Text];
        RIMDXObjectFilter: Dictionary of [Text, Text];
        ObjectFilter: Text;
    begin
        uploadedFile.CreateInStream(IStr, TextEncoding::Windows);
        if not UploadIntoStream(UploadFileMsg, '', Format(Enum::DMTFileFilter::Txt), FileName, IStr) then
            exit;
        uploadedFile.CreateOutStream(OStr);
        CopyStream(OStr, IStr);
        length := uploadedFile.Length();

        uploadedFile.CreateInStream(IStr, TextEncoding::Windows);
        while not IStr.EOS do begin
            IStr.ReadText(currentLineText);
            lines.Add(currentLineText);

            if currentLineText = '**************************************************************************************************************' then
                if lastLineText = 'Object Assignment' then
                    startPos := lines.Count;

            if lastLineText = 'Module Objects and Permissions' then
                if currentLineText = '**************************************************************************************************************' then
                    endPos := lines.Count;

            lastLineText := currentLineText;
        end;

        for i := startPos + 5 to endPos - 4 do begin
            objectType := CopyStr(lines.get(i), 1, 30).Trim();
            quantity := CopyStr(lines.get(i), 31, 15).Trim();
            rangeFrom := CopyStr(lines.get(i), 46, 15).Trim();
            rangeTo := CopyStr(lines.get(i), 61, 15).Trim();
            permissions := CopyStr(lines.get(i), 76, 15).Trim();
            if permissions = 'RIMDX' then begin
                Clear(RIMDXPermission);
                RIMDXPermission.AddRange(objectType, quantity, rangeFrom, rangeTo, permissions);
                RIMDXPermissions.Add(RIMDXPermission);
            end;
        end;

        foreach RIMDXPermission in RIMDXPermissions do begin
            if not RIMDXObjectFilter.Get(RIMDXPermission.Get(1), ObjectFilter) then
                RIMDXObjectFilter.Add(RIMDXPermission.Get(1), StrSubstNo('%1..%2', RIMDXPermission.Get(3), RIMDXPermission.Get(4)))
            else begin
                ObjectFilter += '|' + StrSubstNo('%1..%2', RIMDXPermission.Get(3), RIMDXPermission.Get(4));
                RIMDXObjectFilter.Set(RIMDXPermission.Get(1), ObjectFilter);
            end;
        end;

        Message(ImportFinishedMsg);
    end;
}