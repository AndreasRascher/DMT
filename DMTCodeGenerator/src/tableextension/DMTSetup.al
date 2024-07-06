tableextension 90012 DMTSetup extends DMTSetup
{
    fields
    {
        field(90011; "Obj. ID Range Buffer Tables"; Text[250]) { Caption = 'Obj. ID Range Buffer Tables', Comment = 'de-DE=Objekt ID Bereich für Puffertabellen'; }
        field(90012; "Obj. ID Range XMLPorts"; Text[250]) { Caption = 'Obj. ID Range XMLPorts (Import)', Comment = 'de-DE=Objekt ID Bereich für XMLPorts (Import)'; }
    }

    procedure ProposeObjectIDs(var ImportConfigHeaderRec: Record DMTImportConfigHeader; IsRenumberObjectsIntent: Boolean)
    var
        importConfigHeader: Record DMTImportConfigHeader;
        DMTSetup: Record DMTSetup;
        Numbers: Record Integer;
        AllObjWithCaption: Record AllObjWithCaption;
        NoAvailableObjectIDsErr: Label 'No free object IDs of type %1 could be found. Defined ID range in setup: %2',
                                comment = 'de-DE=Es konnten keine freien Objekt-IDs vom Typ %1 gefunden werden. Definierter ID Bereich in der Einrichtung: %2';
        AvailableTables: List of [Integer];
        AvailableXMLPorts: List of [Integer];
    begin
        if ImportConfigHeaderRec."Separate Buffer Table Objects" = ImportConfigHeaderRec."Separate Buffer Table Objects"::None then
            exit;

        // Get Setup
        if not DMTSetup.Get() then
            DMTSetup.InsertWhenEmpty();
        DMTSetup.Get();

        // Collect available numbers
        if DMTSetup."Obj. ID Range Buffer Tables" <> '' then begin
            Numbers.SetFilter(Number, DMTSetup."Obj. ID Range Buffer Tables");
            if Numbers.FindSet() then
                repeat
                    if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Numbers.Number) then
                        AvailableTables.Add(Numbers.Number);
                until Numbers.Next() = 0
        end;
        if DMTSetup."Obj. ID Range XMLPorts" <> '' then begin
            Numbers.SetFilter(Number, DMTSetup."Obj. ID Range XMLPorts");
            if Numbers.FindSet() then
                repeat
                    if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::XMLport, Numbers.Number) then
                        AvailableXMLPorts.Add(Numbers.Number);
                until Numbers.Next() = 0
        end;
        // Remove used numbers
        importConfigHeader.SetFilter("Separate Buffer Table Objects", '<>%1', importConfigHeader."Separate Buffer Table Objects"::None);
        if importConfigHeader.FindSet(false) then
            repeat
                if importConfigHeader."Buffer Table ID" <> 0 then
                    if AvailableTables.Contains(importConfigHeader."Buffer Table ID") then
                        AvailableTables.Remove(importConfigHeader."Buffer Table ID");
                if importConfigHeader."Import XMLPort ID" <> 0 then
                    if AvailableXMLPorts.Contains(importConfigHeader."Import XMLPort ID") then
                        AvailableXMLPorts.Remove(importConfigHeader."Import XMLPort ID");
            until importConfigHeader.Next() = 0;

        if DMTSetup."Obj. ID Range Buffer Tables" <> '' then
            if AvailableTables.Count = 0 then
                Error(NoAvailableObjectIDsErr, format(AllObjWithCaption."Object Type"::Table), DMTSetup."Obj. ID Range Buffer Tables");
        if DMTSetup."Obj. ID Range XMLPorts" <> '' then
            if AvailableXMLPorts.Count = 0 then
                Error(NoAvailableObjectIDsErr, format(AllObjWithCaption."Object Type"::XMLport), DMTSetup."Obj. ID Range Buffer Tables");


        // Buffer Table ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range Buffer Tables" <> '' then
        if ImportConfigHeaderRec."Separate Buffer Table Objects"
        if (ImportConfigHeaderRec."Buffer Table ID" = 0) and (AvailableTables.Count > 0) then begin
                ImportConfigHeaderRec."Buffer Table ID" := AvailableTables.Get(1);
                AvailableTables.Remove(ImportConfigHeaderRec."Buffer Table ID");
            end;
        // Import XMLPort ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range XMLPorts" <> '' then
        if (ImportConfigHeaderRec."Import XMLPort ID" = 0) and (AvailableXMLPorts.Count > 0) then begin
            ImportConfigHeaderRec."Import XMLPort ID" := AvailableXMLPorts.Get(1);
            AvailableXMLPorts.Remove(ImportConfigHeaderRec."Import XMLPort ID");
        end;
        if not IsRenumberObjectsIntent then begin
            TryFindBufferTableID(ImportConfigHeaderRec, false);
            TryFindXMLPortID(ImportConfigHeaderRec, false);
        end
    end;

    procedure TryFindBufferTableID(var importConfigHeader: Record DMTImportConfigHeader; DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        // AllObjWithCaption.SetRange("App Package ID", importConfigHeader.GetCurrentAppPackageID());
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Buffer', importConfigHeader."NAV Src.Table No."));
        if AllObjWithCaption.FindFirst() then begin
            importConfigHeader."Buffer Table ID" := AllObjWithCaption."Object ID";
            if DoModify then
                importConfigHeader.Modify();
        end;
    end;

    procedure TryFindXMLPortID(var importConfigHeader: Record DMTImportConfigHeader; DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::XMLport);
        // AllObjWithCaption.SetRange("App Package ID", importConfigHeader.GetCurrentAppPackageID());
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Import', importConfigHeader."NAV Src.Table No."));
        if AllObjWithCaption.FindFirst() then begin
            importConfigHeader."Import XMLPort ID" := AllObjWithCaption."Object ID";
            if DoModify then
                importConfigHeader.Modify();
        end;
    end;

}