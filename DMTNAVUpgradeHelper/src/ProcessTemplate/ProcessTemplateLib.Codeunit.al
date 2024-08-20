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
        processTemplateLib: Codeunit DMTProcessTemplateLib;
        noOfRequiredObjects, noOfRequiredData, noOfRequiredSourceFiles, noOfFoundObjects, noOfFoundData, noOfFoundSourceFiles : Integer;
        dataReqNotFulfilledErr: Label 'Required setup data is not available for %1', Comment = 'de-DE=Benötigte Einrichtungen sind nicht vorhanden für %1';
        reqObjectsAreMissingErr: Label 'Required objects are missing for %1', Comment = 'de-DE=Benötigte Objekte fehlen für %1';
        sourceFilesAreMissingErr: Label 'Required source files are missing for %1', Comment = 'de-DE=Benötigte Quelldateien fehlen für %1';
    begin
        if processTemplateSetup.IsNAVSourceTableEmpty() then
            exit;
        if processTemplateSetup.Type = processTemplateSetup.Type::Filter then
            exit;
        if processTemplateSetup.Type = processTemplateSetup.Type::"Default Value" then
            exit;
        if processTemplateSetup.Type = processTemplateSetup.Type::"Update Field" then
            exit;

        processTemplateLib.calcRequirementRatios(processTemplateSetup."Template Code", noOfRequiredObjects, noOfRequiredData, noOfRequiredSourceFiles, noOfFoundObjects, noOfFoundData, noOfFoundSourceFiles);
        if noOfFoundData < noOfRequiredData then
            Error(dataReqNotFulfilledErr, processTemplateSetup."Template Code");
        if noOfFoundObjects < noOfRequiredObjects then
            Error(reqObjectsAreMissingErr, processTemplateSetup."Template Code");
        if noOfFoundSourceFiles < noOfRequiredSourceFiles then
            Error(sourceFilesAreMissingErr, processTemplateSetup."Template Code");

        processingPlan.Init();
        processingPlan."Process Template Code" := processTemplateSetup."Template Code";
        processingPlan."Line No." := nextLineNo;
        if not processTemplateSetup.tryFindMappedProcessingPlanType(processingPlan.Type) then
            exit;
        processingPlan.Description := processTemplateSetup."Description";
        processingPlan.Indentation := processTemplateSetup."Indentation";
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
                    if not sourceFileStorage.findByFileName(processTemplateSetup."Source File Name") then
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
        //TODO: Update Field
    end;

    /// <summary>
    /// checks if a table has data (nav schema file has to be imported) 
    /// </summary>


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
        addComment(templateCode, indentation, 'Hinweise:');
        addComment(templateCode, indentation, 'Fi-Bu Einrichtung der glob. Dimensionen erforderlich');
        addComment(templateCode, indentation, 'Nicht mehr importieren wenn neue Dimensionen hinzugefügt wurden.');
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
        indentation := 1;
        addImportBufferAndTargetNAVFile(templateCode, indentation, 9, 'Land_Region.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 4, 'Währung.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 8, 'Sprache.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5068, 'Anrede.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5069, 'Anredeformel.csv'); // benötigt Sprachen
        addImportBufferAndTargetNAVFile(templateCode, indentation, 308, 'Nummernserie.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 13, 'Verkäufer_Einkäufer.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 5070, 'Position.csv');
        addImportToBufferNAVFile(templateCode, indentation, 5050, 'Kontakt.csv');
        addImportTargetNAVFile(templateCode, indentation, 5050, 'Kontakt.csv', 'Unternehmenskontakte');
        addFilter(templateCode, 'Type', '0');
        addImportTargetNAVFile(templateCode, indentation, 5050, 'Kontakt.csv', 'Personenkontakte');
        addFilter(templateCode, 'Type', '1');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 18, 'Debitor.csv');
        addImportBufferAndTargetNAVFile(templateCode, indentation, 27, 'Kreditor.csv');

        templateCode := 'Sachmerkmale';
        indentation := 0;
        deleteTemplateLines(templateCode);
        addGroup(templateCode, 'Sachmerkmale');
        indentation := 1;
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

    local procedure addComment(templateCode: Code[150]; indentation: Integer; comment: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::" ";
        processTemplateSetup."Description" := comment;
        processTemplateSetup."Indentation" := indentation;
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

    local procedure addRunCodeunit(templateCode: Code[150]; indentation: Integer; CodeunitID: Integer; description: Text[250])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.New(templateCode);
        processTemplateSetup."Type" := processTemplateSetup."Type"::"Run Codeunit";
        processTemplateSetup."Run Codeunit" := CodeunitID;
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

    procedure calcRequirementRatios(templateCode: Code[150]; var noOfRequiredObjects: Integer; var noOfRequiredData: Integer; var noOfRequiredSourceFiles: Integer; var noOfFoundObjects: Integer; var noOfFoundData: Integer; var noOfFoundSourceFiles: Integer)
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.Reset();
        processTemplateSetup.SetRange("Template Code", templateCode);
        processTemplateSetup.FindSet();
        repeat
            if processTemplateSetup.IsDataRequiremt() then begin
                noOfRequiredData += 1;
                if processTemplateSetup.IsDataRequirementFulfilled() then
                    noOfFoundData += 1;
            end;
            if processTemplateSetup.IsCodeunitRequirement() then begin
                noOfRequiredObjects += 1;
                if processTemplateSetup.IsCodeunitRequirementFulfilled() then
                    noOfFoundObjects += 1;
            end;
            if processTemplateSetup.IsSourceFileRequirement() then begin
                noOfRequiredSourceFiles += 1;
                if processTemplateSetup.IsSourceFileRequirementFulfilled() then
                    noOfFoundSourceFiles += 1;
            end;
            if processTemplateSetup.IsTableRequirement() then begin
                noOfRequiredObjects += 1;
                if processTemplateSetup.IsTableRequirementFulfilled() then
                    noOfFoundObjects += 1;
            end;
        until processTemplateSetup.Next() = 0;
    end;

    procedure downloadProcessTemplateXLSFromGitHub(var downloadedFile: Codeunit "Temp Blob")
    var

        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        InStr: InStream;
        ResponseText: Text;
        downloadURLTok: Label 'https://github.com/AndreasRascher/DMT/raw/NAV-Upgrade-Helper/DMTNAVUpgradeHelper/ProcessTemplates/DefaultProcessTemplateSetup.xlsx', Locked = true;
        OutStr: OutStream;
    begin
        downloadedFile.CreateInStream(InStr);
        if not Client.Get(downloadURLTok, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            Error('The call to the web service failed.');
        end;
        ResponseMessage.Content.ReadAs(InStr);
        downloadedFile.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    procedure createListEntry(var exportSchema: Dictionary of [Integer/*field No.*/, List of [Text] /*Caption, CellType*/]; fieldNo: Integer)
    var
        dmyExcelBuffer: Record "Excel Buffer";
        processTemplateSetup: Record DMTProcessTemplateSetup;
        recRef: RecordRef;
        fieldProps: List of [Text];
    begin
        recRef.GetTable(processTemplateSetup);
        fieldProps.Add(recRef.Field(fieldNo).Caption);
        case recRef.Field(fieldNo).Type of
            FieldType::Code, FieldType::Text, FieldType::Option:
                fieldProps.Add(format(dmyExcelBuffer."Cell Type"::Text));
            FieldType::Integer:
                fieldProps.Add(format(dmyExcelBuffer."Cell Type"::Number));
            else
                Error('Field type %1 not supported', recRef.Field(fieldNo).Type);
        end;
        exportSchema.Add(fieldNo, fieldProps);
    end;

    procedure ExportTemplateSetupToExcel()
    var
        tempExcelBuffer: Record "Excel Buffer" temporary;
        processTemplateSetup: Record DMTProcessTemplateSetup;
        recRef: RecordRef;
        exportSchema: Dictionary of [Integer/*field No.*/, List of [Text] /*Caption, CellType*/];
        fieldNo: Integer;
        fieldProps: List of [Text];
    begin

        // if not processTemplateSetup.FindSet(false) then
        //     exit;
        exportSchema := loadExportSchema();

        // create headline
        foreach fieldNo in exportSchema.Keys do begin
            fieldProps := exportSchema.Get(fieldNo);
            addTitleColumn(tempExcelBuffer, fieldProps.Get(1));
        end;
        tempExcelBuffer.NewRow();
        if processTemplateSetup.FindSet(false) then
            repeat
                // add line
                recRef.GetTable(processTemplateSetup);
                foreach fieldNo in exportSchema.Keys do begin
                    fieldProps := exportSchema.Get(fieldNo);
                    case true of
                        fieldProps.Get(2) = format(tempExcelBuffer."Cell Type"::Text):
                            tempExcelBuffer.AddColumn(recRef.Field(fieldNo).Value, false, '', false, false, false, '', tempExcelBuffer."Cell Type"::Text);
                        fieldProps.Get(2) = format(tempExcelBuffer."Cell Type"::Number):
                            tempExcelBuffer.AddColumn(recRef.Field(fieldNo).Value, false, '', false, false, false, '', tempExcelBuffer."Cell Type"::Number);
                        else
                            Error('Cell type %1 not supported', fieldProps.Get(1));
                    end;
                end;
                tempExcelBuffer.NewRow();
            until processTemplateSetup.Next() = 0;
        tempExcelBuffer.CreateNewBook(CopyStr(processTemplateSetup.TableCaption, 1, 250));
        tempExcelBuffer.WriteSheet(processTemplateSetup.TableCaption, CompanyName, UserId);
        tempExcelBuffer.CloseBook();

        tempExcelBuffer.SetFriendlyFilename(StrSubstNo('%1-%2', processTemplateSetup.TableCaption, Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2>_<Seconds,2>')));
        tempExcelBuffer.OpenExcel();
    end;

    local procedure addTitleColumn(var tempExcelBuffer: Record "Excel Buffer" temporary; content: Text)
    begin
        tempExcelBuffer.AddColumn(content, false, '', true, false, false, '', tempExcelBuffer."Cell Type"::Text);
    end;

    procedure ImportTemplateSetupFromExcel()
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
        selectExcelFileLbl: Label 'Select Excel File', Comment = 'de-DE=Excel Datei auswählen';
        debug: Integer;
    begin
        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);
        UploadIntoStream(selectExcelFileLbl, '', Format(Enum::DMTFileFilter::Excel), FileName, InStr);
        CopyStream(OutStr, InStr);
        debug := TempBlob.Length();

        ImportTemplateSetupFromExcel(TempBlob);
    end;


    procedure ImportTemplateSetupFromExcel(var TempBlob: Codeunit "Temp Blob")
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        tempProcessTemplateSetup: Record DMTProcessTemplateSetup temporary;
        tempExcelBuffer: Record "Excel Buffer" temporary;
        TempNameValueBufferOut: Record "Name/Value Buffer" temporary;
        recRef: RecordRef;
        exportSchema: Dictionary of [Integer, List of [Text]];
        FileStream: InStream;
        fieldNo: Integer;
        maxRowNo, rowNo : Integer;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
    begin
        TempBlob.CreateInStream(FileStream);
        tempExcelBuffer.GetSheetsNameListFromStream(FileStream, TempNameValueBufferOut);
        TempNameValueBufferOut.FindFirst();
        tempExcelBuffer.OpenBookStream(FileStream, TempNameValueBufferOut.Value);
        tempExcelBuffer.ReadSheet();

        if not tempExcelBuffer.FindLast() then
            exit;
        maxRowNo := tempExcelBuffer."Row No.";

        exportSchema := loadExportSchema();
        for rowNo := 2 to maxRowNo do begin
            Clear(processTemplateSetup);
            recRef.GetTable(processTemplateSetup);
            foreach fieldNo in exportSchema.Keys do begin
                if tempExcelBuffer.Get(rowNo, exportSchema.Keys.IndexOf(fieldNo)) then
                    AssignFieldValue(recRef, fieldNo, tempExcelBuffer);
            end;
            recRef.SetTable(processTemplateSetup);
            tempProcessTemplateSetup := processTemplateSetup;
            tempProcessTemplateSetup."Line No." := tempProcessTemplateSetup.getNextLineNo(tempProcessTemplateSetup."Template Code");
            tempProcessTemplateSetup.Insert(false);
        end;
        // Replace
        if tempProcessTemplateSetup.FindSet() then begin
            processTemplateSetup.DeleteAll();
            repeat
                processTemplateSetup := tempProcessTemplateSetup;
                processTemplateSetup.Insert();
            until tempProcessTemplateSetup.Next() = 0;
        end;
        Message(ImportFinishedMsg);
    end;

    local procedure loadExportSchema() exportSchema: Dictionary of [Integer/*field No.*/, List of [Text] /*Caption, CellType*/]
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Template Code"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Type"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Source File Name"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo(Indentation));
        createListEntry(exportSchema, processTemplateSetup.FieldNo(Description));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Field Name"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Filter Expression"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Default Value"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("NAV Source Table No."));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Run Codeunit"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Target Table ID"));
    end;

    local procedure AssignFieldValue(var recRef: RecordRef; fieldNo: Integer; var tempExcelBuffer: Record "Excel Buffer" temporary)
    var
        refHelper: Codeunit DMTRefHelper;
        fieldRef: FieldRef;
        InvalidValueErr: Label 'Invalid cell value "%1" in cell %2%3', Comment = 'de-DE=Ungültiger Zellwert %1 in Zelle %2%3';
    begin
        fieldRef := recRef.Field(fieldNo);
        if not refHelper.EvaluateFieldRef(fieldRef, tempExcelBuffer."Cell Value as Text", false, false) then begin
            Error(InvalidValueErr, tempExcelBuffer."Cell Value as Text", tempExcelBuffer.xlColID, tempExcelBuffer.xlRowID);
        end;
    end;


}