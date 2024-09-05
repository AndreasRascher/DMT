codeunit 91027 DMTLicenseMgt
{
    trigger OnRun()
    var
        RIMDXObjectFilter: Dictionary of [Text, Text];
        appList: JsonArray;
        coreAppId, navUpgradeHelperAppId : JsonObject;
    begin
        importFromPemissionsReport(RIMDXObjectFilter);
        coreAppId.Add('id', '4698691e-c550-4026-9fac-05f90572a975');
        coreAppId.Add('name', 'DMT Core');
        coreAppId.Add('publisher', 'Andreas Rascher');
        navUpgradeHelperAppId.Add('id', '9f7ca7e4-6acb-4f40-b403-bbbdcb288ada');
        navUpgradeHelperAppId.Add('name', 'DMT NAV Upgrade Helper');
        navUpgradeHelperAppId.Add('publisher', 'Andreas Rascher');
        appList.Add(coreAppId);
        appList.Add(navUpgradeHelperAppId);
        createBatchReplacerFile(RIMDXObjectFilter, appList);
    end;

    procedure importFromPemissionsReport(var RIMDXObjectFilter: Dictionary of [Text, Text])
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

    local procedure createBatchReplacerFile(RIMDXObjectFilter: Dictionary of [Text, Text]; appList: JsonArray)
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        AllObjWithCaption: Record AllObjWithCaption;
        JToken, JToken2 : JsonToken;
        packageIDFilter: Text;
        usedObjects: Dictionary of [Text, list of [Integer]];
        usedObjectIDs: List of [Integer];
    begin
        // Create a filter for all objects that are used by the DMT Core and DMT NAV Upgrade Helper
        foreach JToken in appList do begin
            JToken.AsObject().Get('id', JToken2);
            NAVAppInstalledApp.SetFilter("App ID", JToken2.AsValue().AsText());

            JToken.AsObject().Get('name', JToken2);
            NAVAppInstalledApp.SetRange(Name, JToken2.AsValue().AsText());

            JToken.AsObject().Get('publisher', JToken2);
            NAVAppInstalledApp.SetRange(Publisher, JToken2.AsValue().AsText());

            NAVAppInstalledApp.FindFirst();
            if packageIDFilter = '' then
                packageIDFilter := NAVAppInstalledApp."Package ID"
            else
                packageIDFilter += '|' + NAVAppInstalledApp."Package ID";
        end;
        // Get all objects that are used by the DMT Core and DMT NAV Upgrade Helper
        AllObjWithCaption.SetFilter("App Package ID", packageIDFilter);
        if AllObjWithCaption.FindSet() then
            repeat
                if not usedObjects.Get(Format(AllObjWithCaption."Object Type"), usedObjectIDs) then begin
                    usedObjectIDs.Add(AllObjWithCaption."Object ID");
                    usedObjects.Add(Format(AllObjWithCaption."Object Type"), usedObjectIDs);
                end else begin
                    usedObjectIDs.Add(AllObjWithCaption."Object ID");
                    usedObjects.Set(Format(AllObjWithCaption."Object Type"), usedObjectIDs);
                end;
            until AllObjWithCaption.Next() = 0;
        // Check if the object is in the license filter
    end;
}