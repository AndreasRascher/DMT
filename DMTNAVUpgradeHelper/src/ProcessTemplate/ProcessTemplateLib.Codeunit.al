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
        processingPlan.Type := processTemplateSetup."PrPl Type";
        processingPlan.Description := processTemplateSetup."PrPl Description";
        processingPlan.Insert();

        case processTemplateSetup."PrPl Type" of
            processTemplateSetup."PrPl Type"::"Import To Buffer",
            processTemplateSetup."PrPl Type"::"Buffer + Target",
            processTemplateSetup."PrPl Type"::"Import To Target",
            processTemplateSetup."PrPl Type"::"Update Field",
            processTemplateSetup."PrPl Type"::"Run Codeunit":
                begin
                    processingPlan.ID := findOrCreateProcessingPlanID(processTemplateSetup);
                    addSourceFilter(processingPlan, processTemplateSetup);
                    if processingPlan.Description = '' then
                        processingPlan.Description := processTemplateSetup."Source File Name";
                    processingPlan.Modify();
                end;
            processTemplateSetup."PrPl Type"::Group,
            processTemplateSetup."PrPl Type"::" ":
                ;
            else
                Error('Processing Plan Type "%1" not supported', processTemplateSetup."PrPl Type");
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
        case processTemplateSetup."PrPl Type" of
            processTemplateSetup."PrPl Type"::" ",
            processTemplateSetup."PrPl Type"::Group:
                exit(0);
            processTemplateSetup."PrPl Type"::"Import To Buffer",
            processTemplateSetup."PrPl Type"::"Buffer + Target",
            processTemplateSetup."PrPl Type"::"Import To Target",
            processTemplateSetup."PrPl Type"::"Update Field":
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
            processTemplateSetup."PrPl Type"::"Run Codeunit":
                begin
                    processTemplateSetup.TestField("PrPl Run Codeunit");
                    exit(processTemplateSetup."PrPl Run Codeunit");
                end;
            else
                Error(notSupportedProcessingPlanTypeErr, processTemplateSetup."PrPl Type");
        end;
    end;

    local procedure translateTargetFilterToSourceFilter(var filteredView: Text; processTemplateSetup: Record DMTProcessTemplateSetup; importConfigHeader: Record DMTImportConfigHeader) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
        index: Integer;
        filterFieldName: List of [Text[30]];
        filterFieldValue: List of [Text[250]];
        filters: List of [Text];
    begin
        importConfigHeader.TestField(ID);
        importConfigHeader.TestField("Source File Name");
        if (processTemplateSetup."PrPl Filter Field 1" <> '') and
           (processTemplateSetup."PrPl Filter Value 1" <> '') then begin
            filterFieldName.Add(processTemplateSetup."PrPl Filter Field 1");
            filterFieldValue.Add(processTemplateSetup."PrPl Filter Value 1");
        end;

        if (processTemplateSetup."PrPl Filter Field 2" <> '') and
           (processTemplateSetup."PrPl Filter Value 2" <> '') then begin
            filterFieldName.Add(processTemplateSetup."PrPl Filter Field 2");
            filterFieldValue.Add(processTemplateSetup."PrPl Filter Value 2");
        end;

        for index := 1 to filterFieldName.Count do begin
            importConfigLine.SetRange("Source Field Caption", filterFieldName.Get(index));
            importConfigHeader.FilterRelated(importConfigLine);
            if importConfigLine.FindFirst() then begin
                filters.Add(StrSubstNo('Field%1=1(%2)', importConfigLine."Source Field No.", filterFieldValue.Get(index)));
            end;
        end;

        for index := 1 to filters.Count do begin
            filteredView += filters.Get(index);
            if index < filters.Count then
                filteredView += ',';
        end;
        filteredView := 'VERSION(1) SORTING(Field1) WHERE(' + filteredView + ')';
        OK := filters.Count > 0;
    end;

    local procedure addSourceFilter(var processingPlan: Record DMTProcessingPlan; processTemplateSetup: Record DMTProcessTemplateSetup) OK: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        filteredView: Text;
    begin
        OK := true;
        if not processingPlan.findImportConfigHeader(importConfigHeader) then
            exit(false);
        importConfigHeader.TestField(ID);
        importConfigHeader.TestField("Source File Name");
        if not translateTargetFilterToSourceFilter(filteredView, processTemplateSetup, importConfigHeader)
            then
            exit(false);
        processingPlan.SaveSourceTableFilter(filteredView);
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
        CustContVendorLbl: Label 'Contact, Customer, Vendor', Comment = 'de-DE=Kontakt, Kunde, Lieferant';
    begin
        templateCode := 'Dimensions';
        deleteTemplateLines(templateCode);
        addGroup(templateCode, 'Dimensionen');
        addImportBufferAndTargetNAVFile(templateCode, 348, 'Dimension.csv');
        addImportBufferAndTargetNAVFile(templateCode, 349, 'Dimensionswert.csv');
        addImportBufferAndTargetNAVFile(templateCode, 350, 'Dimensionskombination.csv');
        addImportBufferAndTargetNAVFile(templateCode, 351, 'Dimensionswertkombination.csv');
        addImportBufferAndTargetNAVFile(templateCode, 352, 'Vorgabedimension.csv');
        addImportBufferAndTargetNAVFile(templateCode, 388, 'Dimensionsübersetzung.csv');
        addImportBufferAndTargetNAVFile(templateCode, 480, 'Dimensionssatzposten.csv');
        addImportBufferAndTargetNAVFile(templateCode, 481, 'Dimensionssatz-Strukturknoten.csv');

        templateCode := CustContVendorLbl;
        deleteTemplateLines(templateCode);
        addGroup(templateCode, CustContVendorLbl);
        addImportBufferAndTargetNAVFile(templateCode, 13, 'Verkäufer_Einkäufer.csv');
        addImportToBufferNAVFile(templateCode, 5050, 'Kontakt.csv');
        addImportTargetNAVFile(templateCode, 5050, 'Kontakt.csv', 'Unternehmenskontakte', 'Type', '0');
        addImportTargetNAVFile(templateCode, 5050, 'Kontakt.csv', 'Personenkontakte', 'Type', '1');
        addImportBufferAndTargetNAVFile(templateCode, 18, 'Debitor.csv');
        addImportBufferAndTargetNAVFile(templateCode, 27, 'Kreditor.csv');

        templateCode := 'Sachmerkmale';
        deleteTemplateLines(templateCode);
        addGroup(templateCode, 'Sachmerkmale');
        addImportBufferAndTargetNAVFile(templateCode, 5022730, 'Objekte für Formeln u. Regeln.csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022748, 'Formeln Variablen Einrichtung.csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022705, 'Sachmerkmalsgruppen.csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022736, 'Instruktionen.csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022714, 'Globale Auspr.-Kopf.csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022728, 'Sachmerkmal.csv');
        addRunCodeunit(templateCode, 5278008, 'M365 CMD Update Attribute');
        addImportBufferAndTargetNAVFile(templateCode, 5022715, 'Globale Auspr.-Pos..csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022704, 'Sachmerkmal Übersetzung.csv');
        addImportBufferAndTargetNAVFile(templateCode, 5022716, 'Ausprägung Übersetzung.csv');
    end;

    local procedure addGroup(templateCode: Code[150]; Groupname: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup.New(templateCode);
        processTemplateSetup."PrPl Type" := processTemplateSetup."PrPl Type"::Group;
        processTemplateSetup."PrPl Description" := Groupname;
        processTemplateSetup.Insert(true);
    end;

    local procedure addImportBufferAndTargetNAVFile(templateCode: Code[150]; NAVSourceTableNo: Integer; SourceFileName: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."PrPl Type" := processTemplateSetup."PrPl Type"::"Buffer + Target";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Source File Name" := SourceFileName;
        processTemplateSetup.Insert(true);
    end;

    local procedure addImportToBufferNAVFile(templateCode: Code[150]; NAVSourceTableNo: Integer; SourceFileName: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."PrPl Type" := processTemplateSetup."PrPl Type"::"Import To Buffer";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Source File Name" := SourceFileName;
        processTemplateSetup.Insert(true);
    end;

    local procedure addImportTargetNAVFile(templateCode: Code[150]; NAVSourceTableNo: Integer; SourceFileName: Text[250]; description: Text[250]; filterFieldName: Text[30]; filterFieldValue: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."PrPl Type" := processTemplateSetup."PrPl Type"::"Import To Buffer";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."Source File Name" := SourceFileName;
        processTemplateSetup."PrPl Description" := description;
        processTemplateSetup."PrPl Filter Field 1" := filterFieldName;
        processTemplateSetup."PrPl Filter Value 1" := filterFieldValue;
        processTemplateSetup.Insert(true);
    end;

    local procedure addRunCodeunit(templateCode: Code[150]; NAVSourceTableNo: Integer; description: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."PrPl Type" := processTemplateSetup."PrPl Type"::"Run Codeunit";
        processTemplateSetup."NAV Source Table No." := NAVSourceTableNo;
        processTemplateSetup."PrPl Description" := description;
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
}