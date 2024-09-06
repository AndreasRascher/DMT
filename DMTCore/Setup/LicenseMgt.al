TODO: Ausführbar pro App mit Überschrift

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
        createBatchReplacerFile(RIMDXObjectFilter, appList, '50000..99999');
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
                RIMDXPermission.AddRange(mapObjectTypeText(objectType), quantity, rangeFrom, rangeTo, permissions);
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

    local procedure createBatchReplacerFile(RIMDXObjectFilter: Dictionary of [Text, Text]; appList: JsonArray; preferedRange: Text)
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        AllObjWithCaption: Record AllObjWithCaption;
        integer: Record Integer;
        JToken, JToken2 : JsonToken;
        packageIDFilter: Text;
        usedObjects: Dictionary of [Text, list of [Integer]];
        usedObjectIDs: List of [Integer];
        LicensedObjects: Dictionary of [Text, list of [Integer]];
        LicensedObjectIDs: List of [Integer];
        // Infos to collect: Object Type, Object ID, New Object ID
        ObjectIDMappingDict: Dictionary of [Text/*<objectType><oldId>*/, Text/*<objectType><newId>*/];
        ObjectIDMapping: List of [Integer/*1-Old ID 2-New ID*/];
        objectType: Text;
        oldGroup, CurrentID, NewID : Integer;
        batchReplacerFileContent: TextBuilder;
        object: Text;
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
        AllObjWithCaption.SetFilter("Object Type", '<>%1&<>%2&<>%3&<>%4&<>%5', AllObjWithCaption."Object Type"::TableData,
                                                                AllObjWithCaption."Object Type"::"TableExtension",
                                                                AllObjWithCaption."Object Type"::"PageExtension",
                                                                AllObjWithCaption."Object Type"::Enum,
                                                                AllObjWithCaption."Object Type"::PermissionSet);
        if AllObjWithCaption.FindSet() then
            repeat
                if not usedObjects.Get(mapObjectTypeText(AllObjWithCaption), usedObjectIDs) then begin
                    Clear(usedObjectIDs);
                    usedObjectIDs.Add(AllObjWithCaption."Object ID");
                    usedObjects.Add(mapObjectTypeText(AllObjWithCaption), usedObjectIDs);
                end else begin
                    usedObjectIDs.Add(AllObjWithCaption."Object ID");
                    usedObjects.Set(mapObjectTypeText(AllObjWithCaption), usedObjectIDs);
                end;
            until AllObjWithCaption.Next() = 0;
        // Create Lists of free object IDs in License
        foreach objectType in RIMDXObjectFilter.Keys() do begin
            integer.SetFilter(Number, RIMDXObjectFilter.Get(objectType));
            // use prefered range
            if preferedRange <> '' then begin
                oldGroup := integer.FilterGroup();
                integer.FilterGroup(2);
                integer.SetFilter(Number, preferedRange);
                integer.FilterGroup(oldGroup);
            end;
            if integer.FindSet() then
                repeat
                    if not LicensedObjects.Get(objectType, LicensedObjectIDs) then begin
                        Clear(LicensedObjectIDs);
                        LicensedObjectIDs.Add(integer.Number);
                        LicensedObjects.Add(objectType, LicensedObjectIDs);
                    end else begin
                        LicensedObjectIDs.Add(integer.Number);
                        LicensedObjects.Set(objectType, LicensedObjectIDs);
                    end;
                until integer.Next() = 0;
        end;
        // find a licensed object ID for each used object
        foreach objectType in usedObjects.Keys() do begin
            // check if current object is in the licensed objects
            usedObjectIDs := usedObjects.Get(objectType);
            LicensedObjectIDs := LicensedObjects.Get(objectType);
            foreach CurrentID in usedObjectIDs do begin
                if LicensedObjectIDs.Count() = 0 then
                    error('No free object ID found for object type %1', objectType);
                if not LicensedObjectIDs.Contains(CurrentID) then begin
                    NewID := LicensedObjectIDs.Get(1);
                    LicensedObjectIDs.RemoveAt(1);
                    Clear(ObjectIDMapping);
                    ObjectIDMapping.AddRange(CurrentID, NewID);
                    ObjectIDMappingDict.Add(StrSubstNo('%1 %2', objectType, CurrentID), StrSubstNo('%1 %2', objectType, NewID));
                end;
            end;
        end;
        // create a batch replacer file
        foreach object in ObjectIDMappingDict.Keys() do begin
            batchReplacerFileContent.AppendLine(StrSubstNo('replace "%1"', object));
            batchReplacerFileContent.AppendLine(StrSubstNo('with "%1"', ObjectIDMappingDict.Get(object)));
        end;
        // replace "xmlport 91001" 
        // with "xmlport 50000"

    end;

    local procedure mapObjectTypeText(objectType: Text) objectType2: Text
    begin
        case objectType of
            'TableData':
                objectType2 := 'Table';
            'Report':
                objectType2 := 'Report';
            'Codeunit':
                objectType2 := 'Codeunit';
            'Page':
                objectType2 := 'Page';
            'Query':
                objectType2 := 'Query';
            'XMLPort':
                objectType2 := 'xmlport';
            else
                Error('Unknown object type %1', objectType);
        end;
    end;

    local procedure mapObjectTypeText(AllObjWithCaption: Record AllObjWithCaption) objectTypeText: Text
    begin
        case AllObjWithCaption."Object Type" of
            AllObjWithCaption."Object Type"::Table:
                objectTypeText := 'Table';
            AllObjWithCaption."Object Type"::Report:
                objectTypeText := 'Report';
            AllObjWithCaption."Object Type"::Codeunit:
                objectTypeText := 'Codeunit';
            AllObjWithCaption."Object Type"::Page:
                objectTypeText := 'Page';
            AllObjWithCaption."Object Type"::Query:
                objectTypeText := 'Query';
            AllObjWithCaption."Object Type"::XmlPort:
                objectTypeText := 'xmlport';
            else
                Error('Unknown object type %1', AllObjWithCaption."Object Type");
        end;
    end;
}