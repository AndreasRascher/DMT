codeunit 90013 DMTProcessTemplateLib
{

    internal procedure TransferToProcessingPlan(templateCode: Code[150])
    var
        processingPlan: Record DMTProcessingPlan;
        processTemplateSetup: Record DMTProcessTemplateSetup;
        nextLineNo: Integer;
        templateAlreadyTransferedErr: Label 'Process Template %1 already transferred to Processing Plan', Comment = 'de-DE=Vorlage %1 wurde bereits übertragen';
    begin
        processingPlan.SetRange("Process Template Code", templateCode);
        if not processingPlan.IsEmpty() then
            Error(templateAlreadyTransferedErr, templateCode);

        processingPlan.Reset();
        if not processingPlan.FindLast() then;
        nextLineNo := processingPlan."Line No." + 10000;

        processTemplateSetup.SetRange("Template Code", templateCode);
        processTemplateSetup.FindSet();
        repeat
            AddToProcessingPlan(processTemplateSetup, nextLineNo);
            nextLineNo += 10000;
        until processTemplateSetup.Next() = 0;
    end;

    local procedure AddToProcessingPlan(processTemplateSetup: Record DMTProcessTemplateSetup; nextLineNo: Integer)
    var
        processingPlan: Record DMTProcessingPlan;
    begin
        if IsNAVSourceTableEmpty(processTemplateSetup."NAV Source Table No.") then
            exit;

        processingPlan.Init();
        processingPlan."Process Template Code" := processTemplateSetup."Template Code";
        processingPlan."Line No." := nextLineNo;
        processingPlan.Type := processTemplateSetup.getMappedProcessingPlanType();
        processingPlan.Description := processTemplateSetup."Description";
        processingPlan.Insert();

        case processingPlan."Type" of
            processingPlan."Type"::"Import To Buffer",
            processingPlan."Type"::"Buffer + Target",
            processingPlan."Type"::"Import To Target",
            processingPlan."Type"::"Update Field",
            processingPlan."Type"::"Run Codeunit":
                begin
                    processingPlan.ID := findOrCreateProcessingPlanID(processTemplateSetup);
                    addFilterAndDefaults(processingPlan, processTemplateSetup);
                    if processingPlan.Description = '' then
                        processingPlan.Description := processTemplateSetup."Source File Name";
                    processingPlan.Modify();
                end;
            processingPlan."Type"::Group,
            processingPlan."Type"::" ":
                ;
            else
                Error('Processing Plan Type "%1" not supported', processingPlan."Type");
        end;
    end;

    local procedure findOrCreateProcessingPlanID(processTemplateSetup: Record DMTProcessTemplateSetup): Integer
    var
        importConfigHeader: Record DMTImportConfigHeader;
        sourceFileStorage: Record DMTSourceFileStorage;
        tempSourceFileStorage: Record DMTSourceFileStorage temporary;
        importConfigMgt: Codeunit DMTImportConfigMgt;
        ISourceFileImport: Interface ISourceFileImport;
        noImportConfigExitsForSourceFileErr: Label 'No Import Configuration exits for Source File %1', Comment = 'de-DE=Keine Importkonfiguration für Quelldatei %1 vorhanden';
        notSupportedProcessingPlanTypeErr: Label 'Processing Plan Type "%1" not supported', Comment = 'de-DE=Verarbeitungsplan Typ "%1" wird nicht unterstützt';
        sourceFileNotFoundErr: Label 'Source File %1 not found', Comment = 'de-DE=Quelldatei %1 nicht gefunden';
    begin
        case processTemplateSetup."Type" of
            processTemplateSetup."Type"::" ",
            processTemplateSetup."Type"::Group:
                exit(0);
            processTemplateSetup."Type"::"Import Buffer",
            processTemplateSetup."Type"::"Import Buffer+Target",
            processTemplateSetup."Type"::"Import Target",
            processTemplateSetup."Type"::"Update Field":
                begin
                    // find source file
                    processTemplateSetup.TestField(processTemplateSetup."Source File Name");
                    if not findSourceFile(sourceFileStorage, processTemplateSetup."Source File Name") then
                        Error(sourceFileNotFoundErr, processTemplateSetup."Source File Name");

                    // find import configuration
                    importConfigHeader.SetRange("Source File ID", sourceFileStorage."File ID");
                    if not importConfigHeader.FindFirst() then begin
                        // try create import configuration with field mapping
                        tempSourceFileStorage := sourceFileStorage;
                        tempSourceFileStorage.Insert();
                        importConfigMgt.addImportConfigForSelectedSourceFiles(tempSourceFileStorage);
                        importConfigHeader.Reset();
                        importConfigHeader.SetRange("Source File ID", sourceFileStorage."File ID");
                        if not importConfigHeader.FindFirst() then
                            Error(noImportConfigExitsForSourceFileErr, processTemplateSetup."Source File Name")
                        else begin
                            ISourceFileImport := importConfigHeader.GetSourceFileStorage().SourceFileFormat;
                            ISourceFileImport.ImportSelectedRows(importConfigHeader, importConfigHeader.GetDataLayout().HeadingRowNo, importConfigHeader.GetDataLayout().HeadingRowNo);
                            importConfigMgt.PageAction_ProposeMatchingFields(importConfigHeader.ID);
                        end;
                    end;
                    exit(importConfigHeader."ID")
                end;
            processTemplateSetup."Type"::"Run Codeunit":
                begin
                    processTemplateSetup.TestField("Run Codeunit");
                    exit(processTemplateSetup."Run Codeunit");
                end;
            else
                Error(notSupportedProcessingPlanTypeErr, processTemplateSetup."Type");
        end;
    end;

    local procedure translateTargetFilterToSourceFilter(var filteredView: Text; processingPlan: Record DMTProcessingPlan; filter: Dictionary of [Text, Text]) OK: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        fieldFilters: List of [Text];
        index: Integer;
    begin
        if not processingPlan.findImportConfigHeader(importConfigHeader) then
            exit(false);
        importConfigHeader.TestField(ID);
        importConfigHeader.TestField("Source File Name");

        for index := 1 to filter.Count do begin
            importConfigLine.SetRange("Source Field Caption", filter.Keys.Get(index));
            importConfigHeader.FilterRelated(importConfigLine);
            if importConfigLine.FindFirst() then begin
                fieldFilters.Add(StrSubstNo('Field%1=1(%2)', importConfigLine."Source Field No.", filter.Values.Get(index)));
            end;
        end;

        for index := 1 to fieldFilters.Count do begin
            filteredView += fieldFilters.Get(index);
            if index < fieldFilters.Count then
                filteredView += ',';
        end;
        filteredView := 'VERSION(1) SORTING(Field1) WHERE(' + filteredView + ')';
        OK := fieldFilters.Count > 0;
    end;

    local procedure addFilterAndDefaults(var processingPlan: Record DMTProcessingPlan; processTemplateSetup: Record DMTProcessTemplateSetup) OK: Boolean
    var
        processTemplateSetup2: Record DMTProcessTemplateSetup;
        filter: Dictionary of [Text, Text];
        defaults: Dictionary of [Text, Text];
        filteredView: Text;
    begin
        OK := true;
        processTemplateSetup2 := processTemplateSetup;
        processTemplateSetup2.setrange("Template Code", processTemplateSetup."Template Code");
        while processTemplateSetup2.Next() <> 0 do begin
            if not (processTemplateSetup2.Type in [processTemplateSetup2.Type::"Default Value", processTemplateSetup2.Type::Filter]) then
                break;
            if processTemplateSetup2.Type = processTemplateSetup2.Type::Filter then
                filter.Add(processTemplateSetup2."Field Name", processTemplateSetup2."Filter Expression");
            if processTemplateSetup2.Type = processTemplateSetup2.Type::"Default Value" then
                filter.Add(processTemplateSetup2."Field Name", processTemplateSetup2."Default Value");
        end;

        if (filter.Count = 0) and (defaults.Count = 0) then
            exit(false);

        if translateTargetFilterToSourceFilter(filteredView, processingPlan, filter) then
            processingPlan.SaveSourceTableFilter(filteredView);
        if translateTargetFilterToSourceFilter(filteredView, processingPlan, defaults) then
            processingPlan.SaveDefaultValuesView(filteredView);
    end;

    /// <summary>
    /// checks if a table has data (nav schema file has to be imported) 
    /// </summary>
    procedure IsNAVSourceTableEmpty(NAVSourceTableID: Integer) isEmpty: Boolean
    var
        fieldBuffer: Record DMTFieldBuffer;
    begin
        isEmpty := false;
        if NAVSourceTableID = 0 then
            exit(false);
        fieldBuffer.SetRange(TableNo, NAVSourceTableID);
        if fieldBuffer.FindFirst() then
            if fieldBuffer."No. of Records" = 0 then
                exit(true);
    end;

    procedure IsSourceFileAvailable(sourceFileName: Text) OK: Boolean
    var
        sourceFileStorage: Record DMTSourceFileStorage;
    begin
        OK := findSourceFile(sourceFileStorage, sourceFileName);
    end;

    procedure findSourceFile(var sourceFileStorage: Record DMTSourceFileStorage; sourceFileName: Text) Found: Boolean
    begin
        if sourceFileName = '' then
            exit(false);
        sourceFileStorage.SetRange(Name, sourceFileName);
        Found := sourceFileStorage.FindFirst();
    end;

    procedure InitDefaults()
    var
        templateCode: code[150];
        indentation: Integer;
        CustContVendorLbl: Label 'Contact, Customer, Vendor', Comment = 'de-DE=Kontakt, Kunde, Lieferant';
    begin
        templateCode := 'Dimensions';
        indentation := 0;
        deleteTemplateLines(templateCode);
        addGroup(templateCode, 'Dimensionen');
        indentation += 1;
        addComment(templateCode, 'Hinweise:');
        addComment(templateCode, 'Fi-Bu Einrichtung der glob. Dimensionen erforderlich');
        addComment(templateCode, 'Nicht mehr importieren wenn neue Dimensionen hinzugefügt wurden.');
        // prüfung ob erforderliche Felder gefüllt sind (via Tabellen-ID und Feld-ID)
        addFieldRequirement(templateCode, indentation, Database::"General Ledger Setup", 'Global Dimension 1 Code');

        addImportBufferAndTargetNAVFile(templateCode, indentation, 348, 'Dimension.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 349, 'Dimensionswert.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 350, 'Dimensionskombination.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 351, 'Dimensionswertkombination.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 352, 'Vorgabedimension.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 388, 'Dimensionsübersetzung.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 480, 'Dimensionssatzposten.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 481, 'Dimensionssatz-Strukturknoten.csv');

        templateCode := CustContVendorLbl;
        indentation := 0;
        deleteTemplateLines(templateCode);
        addGroup(templateCode, CustContVendorLbl);
        addImportBufferAndTargetNAVFile(templateCode, indentation, 13, 'Verkäufer_Einkäufer.csv');
        addImportToBufferNAVFile(templateCode, indentation, 5050, 'Kontakt.csv');
        addImportTargetNAVFile(templateCode, indentation, 5050, 'Kontakt.csv', 'Unternehmenskontakte');
        addFilter(templateCode, 'Type', '0');
        addImportTargetNAVFile(templateCode, indentation, 5050, 'Kontakt.csv', 'Personenkontakte');
        addFilter(templateCode, 'Type', '1');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 18, 'Debitor.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 27, 'Kreditor.csv');

        templateCode := 'Sachmerkmale';
        deleteTemplateLines(templateCode);
        addGroup(templateCode, 'Sachmerkmale');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022730, 'Objekte für Formeln u. Regeln.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022748, 'Formeln Variablen Einrichtung.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022705, 'Sachmerkmalsgruppen.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022736, 'Instruktionen.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022714, 'Globale Auspr.-Kopf.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022728, 'Sachmerkmal.csv');
        addRunCodeunit(templateCode, indentation, 5278008, 'M365 CMD Update Attribute');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022715, 'Globale Auspr.-Pos..csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022704, 'Sachmerkmal Übersetzung.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5022716, 'Ausprägung Übersetzung.csv');
    end;

    local procedure addGroup(templateCode: Code[150]; Groupname: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::Group;
        processTemplateSetup."Description" := Groupname;
        processTemplateSetup.Insert(true);
    end;

    local procedure addComment(templateCode: Code[150]; comment: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::" ";
        processTemplateSetup."Description" := comment;
        processTemplateSetup.Insert(true);
    end;

    local procedure addImportBufferAndTargetNAVFile(templateCode: Code[150]; indentation: Integer; NAVSourceTableNo: Integer; SourceFileName: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::"Import Buffer+Target";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Source File Name" := SourceFileName;
        processTemplateSetup."Indentation" := indentation;
        processTemplateSetup.Insert(true);
    end;

    local procedure addImportToBufferNAVFile(templateCode: Code[150]; indentation: Integer; NAVSourceTableNo: Integer; SourceFileName: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::"Import Buffer";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Source File Name" := SourceFileName;
        processTemplateSetup."Indentation" := indentation;
        processTemplateSetup.Insert(true);
    end;

    local procedure addImportTargetNAVFile(templateCode: Code[150]; indentation: Integer; NAVSourceTableNo: Integer; SourceFileName: Text[250]; description: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::"Import Target";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Source File Name" := SourceFileName;
        processTemplateSetup."Description" := description;
        processTemplateSetup."Indentation" := indentation;
        processTemplateSetup.Insert(true);
    end;

    local procedure addRunCodeunit(templateCode: Code[150]; indentation: Integer; NAVSourceTableNo: Integer; description: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::"Run Codeunit";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Description" := description;
        processTemplateSetup."Indentation" := indentation;
        processTemplateSetup.Insert(true);
    end;

    local procedure deleteTemplateLines(templateCode: Code[150])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.SetRange("Template Code", templateCode);
        if not processTemplateSetup.IsEmpty then
            processTemplateSetup.DeleteAll();
    end;

    local procedure addFieldRequirement(templateCode: Code[150]; indentation: Integer; TableId: Integer; fieldName: Text[30])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup.type := processTemplateSetup."Type"::"Req. Setup";
        processTemplateSetup."Target Table ID" := TableId;
        processTemplateSetup."Field Name" := fieldName;
        processTemplateSetup."Indentation" := indentation;
        processTemplateSetup.Insert(true);
    end;

    local procedure addFilter(templateCode: Code[150]; fieldName: Text[30]; filterExpr: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup.type := processTemplateSetup."Type"::"Filter";
        processTemplateSetup."Field Name" := fieldName;
        processTemplateSetup."Filter Expression" := filterExpr;
        processTemplateSetup.Insert(true);
    end;
}