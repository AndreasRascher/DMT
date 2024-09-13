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
        ReadLicensedObjectsFromImportedPemissionsReport(LicensedObjects, RIMDXObjectFilter, '50000..50166');

        // insert instructions
        batchReplacerFileContent.AppendLine('// Apply all commands only to .al files');
        batchReplacerFileContent.AppendLine('filter "**/*.al"');

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

    /// <summary>
    /// Read the licensed objects from the imported permissions report and create a list of free object IDs for each object type
    /// </summary>
    /// <param name="LicensedObjects">Result: licensed object ids </param>
    /// <param name="RIMDXObjectFilter">objects in license filter</param>
    /// <param name="preferedRange">lower and/or upper bound for proposed object IDs</param>
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
        i, oldGroup : Integer;
        startPos_ObjectAssignment, endPos_ObjectAssignment : Integer;
        startPos_ModulePermissions, endPos_ModulePermissions : Integer;
        objectType, quantity, rangeFrom, rangeTo, permissions, moduleName : Text;
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
                    startPos_ObjectAssignment := lines.Count;

            if currentLineText = '**************************************************************************************************************' then
                if lastLineText = 'Module Objects and Permissions' then
                    endPos_ObjectAssignment := lines.Count;

            if currentLineText = '**************************************************************************************************************' then
                if lastLineText = 'Module Objects and Permissions' then
                    startPos_ModulePermissions := lines.Count;

            if currentLineText = '**************************************************************************************************************' then
                if lastLineText = 'Limited Usage Ranges' then
                    endPos_ModulePermissions := lines.Count;

            lastLineText := currentLineText;
        end;

        for i := startPos_ObjectAssignment + 5 to endPos_ObjectAssignment - 4 do begin
            objectType := CopyStr(lines.get(i), 1, 30).Trim().ToLower();
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

        for i := startPos_ModulePermissions + 4 to endPos_ModulePermissions - 4 do begin
            moduleName := CopyStr(lines.get(i), 1, 30).Trim();
            rangeFrom := CopyStr(lines.get(i), 60, 15).Trim();
            rangeTo := CopyStr(lines.get(i), 75, 15).Trim();
            objectType := CopyStr(lines.get(i), 90, 20).Trim().ToLower();
            permissions := CopyStr(lines.get(i), 110, 15).Trim();
            //350 Starter Pack
            if (permissions = 'RIMDX') and not (objectType in ['menusuite', 'dataport', 'tabledescription', 'form']) then begin
                Clear(RIMDXPermission);
                RIMDXPermission.AddRange(mapObjectTypeText(objectType), '0', rangeFrom, rangeTo, permissions);
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
        // Add all objects that are not restricted by license but should respect the prefered range
        if preferedRange <> '' then begin
            RIMDXObjectFilter.Add('enum', preferedRange);
            RIMDXObjectFilter.Add('permissionset', preferedRange);
            RIMDXObjectFilter.Add('pageextension', preferedRange);
            RIMDXObjectFilter.Add('tableextension', preferedRange);
        end;
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


    local procedure mapObjectTypeText(objectType: Text) objectType2: Text
    begin
        case objectType of
            'tabledata':
                objectType2 := 'table';
            'report':
                objectType2 := 'report';
            'codeunit':
                objectType2 := 'codeunit';
            'page':
                objectType2 := 'page';
            'query':
                objectType2 := 'query';
            'xmlport':
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
            AllObjWithCaption."Object Type"::Enum:
                objectTypeText := 'enum';
            AllObjWithCaption."Object Type"::PermissionSet:
                objectTypeText := 'permissionset';
            AllObjWithCaption."Object Type"::PageExtension:
                objectTypeText := 'pageextension';
            AllObjWithCaption."Object Type"::TableExtension:
                objectTypeText := 'tableextension';
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
        AllObjWithCaption.SetFilter("Object Type", '<>%1', AllObjWithCaption."Object Type"::TableData);
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
    //        AllObjWithCaption."Object Type"::"TableExtension",
    // AllObjWithCaption."Object Type"::"PageExtension",
    // AllObjWithCaption."Object Type"::Enum,
    // AllObjWithCaption."Object Type"::PermissionSet
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
        objectTypeWithIDText, last : Text;
    begin

        // create title lines
        getInstalledApp(NAVAppInstalledApp, installedAppId);
        batchReplacerFileContent.AppendLine('');
        batchReplacerFileContent.AppendLine(StrSubstNo('// App: %1', NAVAppInstalledApp.Name));
        batchReplacerFileContent.AppendLine('');
        foreach objectTypeWithIDText in ObjectIDMappingDict.Keys() do begin
            // insert empty line between different object types
            if (last <> '') then
                if CopyStr(last, 1, 3) <> CopyStr(objectTypeWithIDText, 1, 3) then
                    batchReplacerFileContent.AppendLine('');
            batchReplacerFileContent.AppendLine(StrSubstNo('replace "%1"', objectTypeWithIDText));
            batchReplacerFileContent.AppendLine(StrSubstNo('with "%1"', ObjectIDMappingDict.Get(objectTypeWithIDText)));
            last := objectTypeWithIDText;
        end;
        // replace "xmlport 50000" 
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