// TODO: Ausführbar pro App mit Überschrift

codeunit 91027 DMTLicenseMgt
{
    trigger OnRun()
    var
        RIMDXObjectFilter: Dictionary of [Text, Text];
        LicensedObjects: Dictionary of [Text, List of [Integer]];
        coreAppId, navUpgradeHelperAppId : JsonObject;
        usedObjects: Dictionary of [Text, list of [Integer]];
        batchReplacerFileContent: TextBuilder;
        ObjectIDMappingDict: Dictionary of [Text/*<objectType><oldId>*/, Text/*<objectType><newId>*/];
    begin
        ReadLicensedObjectsFromImportedPemissionsReport(LicensedObjects, RIMDXObjectFilter, '50000..99999');

        coreAppId.Add('id', '4698691e-c550-4026-9fac-05f90572a975');
        coreAppId.Add('name', 'DMT Core');
        coreAppId.Add('publisher', 'Andreas Rascher');
        readInstalledAppObjectIDs(usedObjects, coreAppId);
        RenumberAppId(ObjectIDMappingDict, usedObjects, LicensedObjects);
        AddObjectIDMappingToBatchReplacerFile(batchReplacerFileContent, ObjectIDMappingDict, coreAppId);

        navUpgradeHelperAppId.Add('id', '9f7ca7e4-6acb-4f40-b403-bbbdcb288ada');
        navUpgradeHelperAppId.Add('name', 'DMT NAV Upgrade Helper');
        navUpgradeHelperAppId.Add('publisher', 'Andreas Rascher');
        readInstalledAppObjectIDs(usedObjects, navUpgradeHelperAppId);
        RenumberAppId(ObjectIDMappingDict, usedObjects, LicensedObjects);
        AddObjectIDMappingToBatchReplacerFile(batchReplacerFileContent, ObjectIDMappingDict, navUpgradeHelperAppId);

        DownloadFile(batchReplacerFileContent, 'BatchReplacerFile.txt');
    end;

    procedure ReadLicensedObjectsFromImportedPemissionsReport(var LicensedObjects: Dictionary of [Text, list of [Integer]]; var RIMDXObjectFilter: Dictionary of [Text, Text]; preferedRange: Text)
    var
        integer: Record Integer;
        uploadedFile: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
        UploadFileMsg: Label 'Upload Permission Report Detailed', Comment = 'de-DE=Permission Report Detailed hochladen';
        FileName: Text;
        length: Integer;
        lines: List of [Text];
        currentLineText, lastLineText : Text;
        startPos, i, endPos, oldGroup : Integer;
        objectType, quantity, rangeFrom, rangeTo, permissions : Text;
        RIMDXPermissions: List of [List of [Text]];
        RIMDXPermission: List of [Text];
        LicensedObjectIDs: List of [Integer];
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

        // Create Lists of free object IDs in License
        Clear(LicensedObjects);
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


        Message(ImportFinishedMsg);
    end;

    procedure DownloadFile(Content: TextBuilder; toFileName: Text)
    var
        tempBlob: Codeunit "Temp Blob";
        iStr: InStream;
        oStr: OutStream;
    begin
        tempBlob.CreateOutStream(oStr, TextEncoding::UTF8);  // Import / Export as UTF-8
        oStr.WriteText(Content.ToText());
        tempBlob.CreateInStream(iStr);
        toFileName := DelChr(toFileName, '=', '#&-%/\(), ');
        DownloadFromStream(iStr, 'Download', 'ToFolder', Format(Enum::DMTFileFilter::All), toFileName);
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
                objectType2 := 'table';
            'Report':
                objectType2 := 'report';
            'Codeunit':
                objectType2 := 'codeunit';
            'Page':
                objectType2 := 'page';
            'Query':
                objectType2 := 'query';
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
                objectTypeText := 'table';
            AllObjWithCaption."Object Type"::Report:
                objectTypeText := 'report';
            AllObjWithCaption."Object Type"::Codeunit:
                objectTypeText := 'codeunit';
            AllObjWithCaption."Object Type"::Page:
                objectTypeText := 'page';
            AllObjWithCaption."Object Type"::Query:
                objectTypeText := 'query';
            AllObjWithCaption."Object Type"::XmlPort:
                objectTypeText := 'xmlport';
            else
                Error('Unknown object type %1', AllObjWithCaption."Object Type");
        end;
    end;

    local procedure readInstalledAppObjectIDs(var usedObjects: Dictionary of [Text, List of [Integer]]; installedAppID: JsonObject)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        NAVAppInstalledApp: Record "NAV App Installed App";
        packageIDFilter: Text;
        usedObjectIDs: List of [Integer];
    begin
        Clear(usedObjects);
        getInstalledApp(NAVAppInstalledApp, installedAppID);
        if packageIDFilter = '' then
            packageIDFilter := NAVAppInstalledApp."Package ID"
        else
            packageIDFilter += '|' + NAVAppInstalledApp."Package ID";

        // Get all objects that are used by the given app identity, excludint types without license restrictions
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
    end;

    local procedure RenumberAppId(ObjectIDMappingDict: Dictionary of [Text/*<objectType><oldId>*/, Text/*<objectType><newId>*/]; usedObjects: Dictionary of [Text, List of [Integer]]; var LicensedObjects: Dictionary of [Text, List of [Integer]])
    var
        objectType: Text;
        usedObjectIDs: List of [Integer];
        LicensedObjectIDs: List of [Integer];
        CurrentID, NewID : Integer;
        ObjectIDMapping: List of [Integer];
    begin
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
        end
    end;

    local procedure AddObjectIDMappingToBatchReplacerFile(batchReplacerFileContent: TextBuilder; ObjectIDMappingDict: Dictionary of [Text, Text]; installedAppId: JsonObject)
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        objectTypeWithIDText: Text;
    begin
        // create title lines
        getInstalledApp(NAVAppInstalledApp, installedAppId);
        batchReplacerFileContent.AppendLine('');
        batchReplacerFileContent.AppendLine(StrSubstNo('// App: %1', NAVAppInstalledApp.Name));
        batchReplacerFileContent.AppendLine('');
        foreach objectTypeWithIDText in ObjectIDMappingDict.Keys() do begin
            batchReplacerFileContent.AppendLine(StrSubstNo('replace "%1"', objectTypeWithIDText));
            batchReplacerFileContent.AppendLine(StrSubstNo('with "%1"', ObjectIDMappingDict.Get(objectTypeWithIDText)));
        end;
        // replace "xmlport 91001" 
        // with "xmlport 50000"
    end;

    local procedure getInstalledApp(var NAVAppInstalledApp: Record "NAV App Installed App"; installedAppID: JsonObject)
    var
        jToken: JsonToken;
    begin
        Clear(NAVAppInstalledApp);
        installedAppID.Get('id', jToken);
        NAVAppInstalledApp.SetFilter("App ID", jToken.AsValue().AsText());

        installedAppID.Get('name', jToken);
        NAVAppInstalledApp.SetRange(Name, jToken.AsValue().AsText());

        installedAppID.Get('publisher', jToken);
        NAVAppInstalledApp.SetRange(Publisher, jToken.AsValue().AsText());

        NAVAppInstalledApp.FindFirst();
    end;
}