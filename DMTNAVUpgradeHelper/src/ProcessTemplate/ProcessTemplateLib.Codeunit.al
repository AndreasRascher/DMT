codeunit 90013 DMTProcessTemplateLib
{
    procedure InsertProcessTemplateData()
    var
        processTemplate: Record DMTProcessTemplate;
    begin
        processTemplate.DeleteAll(true);
        Insert_Dimensions();
        Insert_Contact_Customer_Vendor();
        Insert_Sachmerkmale();
        // Anforderungen:
        //   Zieltabelle ist vorhanden
        //   Quelltabelle
        //   Quelldateien sind vorhanden
        //   Codeunit ist vorhanden
        //   Quelltabelle hat Daten

        // Reihenfolge:
        //  Import in Puffertabelle
        //  Import in Zieltabelle
        //      Eigenschaften: Filter, spez. Felder

        // Wenn
        // - Sind Vorraussetzungen erfüllt
        // Dann
        // - Anbieten des Migrationspakets

        // Wenn
        // - Migrationspaket wird angenommen
        // - Migrationspaket ist noch nicht übernommen worden
        // Dann
        // - Migrationspaket in Verarbeitungsplan aufnehmen
    end;

    internal procedure TransferToProcessingPlan(processTemplate: Record DMTProcessTemplate)
    var
        processingPlan: Record DMTProcessingPlan;
        processTemplateDetail: Record DMTProcessTemplateDetail;
        nextLineNo: Integer;
        templateAlreadyTransferedErr: Label 'Process Template %1 already transferred to Processing Plan', Comment = 'de-DE=Vorlage %1 wurde bereits übertragen';
    begin
        processingPlan.SetRange("Process Template Code", processTemplate.Code);
        if not processingPlan.IsEmpty() then
            Error(templateAlreadyTransferedErr, processTemplate.Code);

        processingPlan.Reset();
        if not processingPlan.FindLast() then;
        nextLineNo := processingPlan."Line No." + 10000;

        processTemplateDetail.SetRange(Type, processTemplateDetail.Type::Step);
        if not processTemplateDetail.filterFor(processTemplate) then
            exit;
        processTemplateDetail.FindSet();
        repeat
            AddTemplateDetailToProcessingPlan(processingPlan, processTemplate, processTemplateDetail, nextLineNo);
            nextLineNo += 10000;
        until processTemplateDetail.Next() = 0;
    end;

    local procedure AddTemplateDetailToProcessingPlan(var processingPlan: Record DMTProcessingPlan; var processTemplate: Record DMTProcessTemplate; var processTemplateDetail: Record DMTProcessTemplateDetail; var nextLineNo: Integer)
    begin
        // only add needed Tables
        if processTemplateDetail."Requirement Sub Type" = processTemplateDetail."Requirement Sub Type"::SourceFile then
            if IsNAVSourceTableEmpty(processTemplateDetail."NAV Source Table No.(Req.)") then
                exit;

        processingPlan."Line No." := nextLineNo;
        processingPlan.Insert();

        processingPlan.Type := processTemplateDetail."PrPl Type";
        processingPlan.ID := findOrCreateProcessingPlanID(processTemplateDetail);
        processingPlan."Process Template Code" := processTemplate.Code;
        processingPlan.Description := processTemplateDetail.Name;
        processingPlan.Indentation := processTemplateDetail."PrPl Indentation";
        addSourceFilter(processingPlan, processTemplateDetail);
        processingPlan.Modify();
    end;

    local procedure Insert_Dimensions()
    var
        processTemplate: Record DMTProcessTemplate;
        processTemplateDetail: Record DMTProcessTemplateDetail;
        dimensionsLbl: Label 'Dimensions', Comment = 'de-DE=Dimensionen';
    begin
        processTemplate.addTemplate(dimensionsLbl);
        addSrcFileRequirement(processTemplate, 348, 'Dimension.csv');
        addSrcFileRequirement(processTemplate, 349, 'Dimensionswert.csv');
        addSrcFileRequirement(processTemplate, 350, 'Dimensionskombination.csv');
        addSrcFileRequirement(processTemplate, 351, 'Dimensionswertkombination.csv');
        addSrcFileRequirement(processTemplate, 352, 'Vorgabedimension.csv');
        addSrcFileRequirement(processTemplate, 388, 'Dimensionsübersetzung.csv');
        addSrcFileRequirement(processTemplate, 480, 'Dimensionssatzposten.csv');
        addSrcFileRequirement(processTemplate, 481, 'Dimensionssatz-Strukturknoten.csv');

        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 348, 'Dimension.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 349, 'Dimensionswert.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 350, 'Dimensionskombination.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 351, 'Dimensionswertkombination.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 352, 'Vorgabedimension.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 388, 'Dimensionsübersetzung.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 480, 'Dimensionssatzposten.csv');
        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 481, 'Dimensionssatz-Strukturknoten.csv');
    end;

    local procedure Insert_Contact_Customer_Vendor()
    var
        processTemplate: Record DMTProcessTemplate;
        processTemplateDetail: Record DMTProcessTemplateDetail;
        CustContVendorLbl: Label 'Contact, Customer, Vendor', Comment = 'de-DE=Kontakt, Kunde, Lieferant';
    begin
        processTemplate.addTemplate(CustContVendorLbl);
        addSrcFileRequirement(processTemplate, 13, 'Verkäufer_Einkäufer.csv');
        addSrcFileRequirement(processTemplate, 5050, 'Kontakt.csv');
        addSrcFileRequirement(processTemplate, 18, 'Debitor.csv');
        addSrcFileRequirement(processTemplate, 27, 'Kreditor.csv');


        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 13, 'Verkäufer_Einkäufer.csv');
        addStep_ImportToBuffer(processTemplateDetail, processTemplate, 'Kontakt.csv');

        addStep_ImportToTarget(processTemplateDetail, processTemplate, 'Kontakt.csv');
        addFilterForImport(processTemplateDetail, 'Type', '0');

        addStep_ImportToTarget(processTemplateDetail, processTemplate, 'Kontakt.csv');
        addFilterForImport(processTemplateDetail, 'Type', '1');

        addStep_ImportToBuffer(processTemplateDetail, processTemplate, 'Debitor.csv');
        addStep_ImportToTarget(processTemplateDetail, processTemplate, 'Debitor.csv');
    end;

    local procedure Insert_Sachmerkmale()
    var
        processTemplate: Record DMTProcessTemplate;
    begin
        processTemplate.addTemplate('Sachmerkmale');
        addSrcFileRequirement(processTemplate, 5022730, 'Objekte für Formeln u. Regeln.csv');
        addSrcFileRequirement(processTemplate, 5022748, 'Formeln Variablen Einrichtung.csv');
        addSrcFileRequirement(processTemplate, 5022705, 'Sachmerkmalsgruppen.csv');
        addSrcFileRequirement(processTemplate, 5022736, 'Instruktionen.csv');
        addSrcFileRequirement(processTemplate, 5022714, 'Globale Auspr.-Kopf.csv');
        addSrcFileRequirement(processTemplate, 5022728, 'Sachmerkmal.csv');
        addCodeunitRequirement(processTemplate, 5278008, 'M365 CMD Update Attribute');
        addSrcFileRequirement(processTemplate, 5022715, 'Globale Auspr.-Pos..csv');
        addSrcFileRequirement(processTemplate, 5022704, 'Sachmerkmal Übersetzung.csv');
        addSrcFileRequirement(processTemplate, 5022716, 'Ausprägung Übersetzung.csv');
    end;

    local procedure addSrcFileRequirement(processTemplate: Record DMTProcessTemplate; NAVSourceTableID: Integer; fileName: Text[100])
    var
        processTemplateDetails: Record DMTProcessTemplateDetail;
    begin
        // only used tables
        processTemplateDetails.Init();
        processTemplateDetails."Process Template Code" := processTemplate.Code;
        processTemplateDetails."Line No." := processTemplateDetails.getNextLineNo();
        processTemplateDetails.Type := processTemplateDetails.Type::Requirement;
        processTemplateDetails."Requirement Sub Type" := processTemplateDetails."Requirement Sub Type"::SourceFile;
        processTemplateDetails."Name" := fileName;
        processTemplateDetails."NAV Source Table No.(Req.)" := NAVSourceTableID;
        processTemplateDetails.Insert();
    end;

    local procedure addCodeunitRequirement(processTemplate: Record DMTProcessTemplate; objectID: Integer; objectName: Text[249])
    var
        processTemplateDetails: Record DMTProcessTemplateDetail;
    begin
        processTemplateDetails.Init();
        processTemplateDetails."Process Template Code" := processTemplate.Code;
        processTemplateDetails."Line No." := processTemplateDetails.getNextLineNo();
        processTemplateDetails.Type := processTemplateDetails.Type::Requirement;
        processTemplateDetails."Requirement Sub Type" := processTemplateDetails."Requirement Sub Type"::"Codeunit";
        processTemplateDetails."Object Type (Req.)" := processTemplateDetails."Object Type (Req.)"::Codeunit;
        processTemplateDetails."Object ID (Req.)" := objectID;
        processTemplateDetails.Name := objectName;
        processTemplateDetails.Insert();
    end;

    local procedure addStep_ImportToBuffer(var processTemplateDetails_NEW: Record DMTProcessTemplateDetail; processTemplate: Record DMTProcessTemplate; importFileName: Text[250])
    begin
        Clear(processTemplateDetails_NEW);
        processTemplateDetails_NEW."Process Template Code" := processTemplate.Code;
        processTemplateDetails_NEW."Line No." := processTemplateDetails_NEW.getNextLineNo();
        processTemplateDetails_NEW.Type := processTemplateDetails_NEW.Type::Step;
        processTemplateDetails_NEW.Name := importFileName;
        processTemplateDetails_NEW."PrPl Type" := processTemplateDetails_NEW."PrPl Type"::"Import To Buffer";
        processTemplateDetails_NEW.Insert();
    end;

    local procedure addStep_ImportToTarget(var processTemplateDetails_NEW: Record DMTProcessTemplateDetail; processTemplate: Record DMTProcessTemplate; importFileName: Text[250])
    begin
        processTemplateDetails_NEW.Init();
        processTemplateDetails_NEW."Process Template Code" := processTemplate.Code;
        processTemplateDetails_NEW."Line No." := processTemplateDetails_NEW.getNextLineNo();
        processTemplateDetails_NEW.Type := processTemplateDetails_NEW.Type::Step;
        processTemplateDetails_NEW.Name := importFileName;
        processTemplateDetails_NEW."PrPl Type" := processTemplateDetails_NEW."PrPl Type"::"Import To Target";
        processTemplateDetails_NEW.Insert();
    end;

    local procedure addStep_ImportToBufferAndTarget(var processTemplateDetails_NEW: Record DMTProcessTemplateDetail; processTemplate: Record DMTProcessTemplate; NAVSourceTableID: Integer; importFileName: Text[250])
    begin
        processTemplateDetails_NEW.Init();
        processTemplateDetails_NEW."Process Template Code" := processTemplate.Code;
        processTemplateDetails_NEW."Line No." := processTemplateDetails_NEW.getNextLineNo();
        processTemplateDetails_NEW.Type := processTemplateDetails_NEW.Type::Step;
        processTemplateDetails_NEW.Name := importFileName;
        processTemplateDetails_NEW."NAV Source Table No.(Req.)" := NAVSourceTableID;
        processTemplateDetails_NEW."PrPl Type" := processTemplateDetails_NEW."PrPl Type"::"Buffer + Target";
        processTemplateDetails_NEW.Insert();
    end;

    local procedure findOrCreateProcessingPlanID(processTemplateDetails: Record DMTProcessTemplateDetail): Integer
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
        case processTemplateDetails."PrPl Type" of
            processTemplateDetails."PrPl Type"::" ",
            processTemplateDetails."PrPl Type"::Group:
                exit(0);
            processTemplateDetails."PrPl Type"::"Import To Buffer",
            processTemplateDetails."PrPl Type"::"Buffer + Target",
            processTemplateDetails."PrPl Type"::"Import To Target",
            processTemplateDetails."PrPl Type"::"Update Field":
                begin
                    // find source file
                    processTemplateDetails.TestField(processTemplateDetails.Name);
                    sourceFileStorage.SetRange(Name, processTemplateDetails.Name);
                    if not sourceFileStorage.FindFirst() then
                        Error(sourceFileNotFoundErr, processTemplateDetails.Name);

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
                            Error(noImportConfigExitsForSourceFileErr, processTemplateDetails.Name)
                        else begin
                            ISourceFileImport := importConfigHeader.GetSourceFileStorage().SourceFileFormat;
                            ISourceFileImport.ImportSelectedRows(importConfigHeader, importConfigHeader.GetDataLayout().HeadingRowNo, importConfigHeader.GetDataLayout().HeadingRowNo);
                            importConfigMgt.PageAction_ProposeMatchingFields(importConfigHeader.ID);
                        end;
                    end;
                    exit(importConfigHeader."ID")
                end;
            processTemplateDetails."PrPl Type"::"Run Codeunit":
                begin
                    processTemplateDetails.TestField("Object Type (Req.)", processTemplateDetails."Object Type (Req.)"::Codeunit);
                    processTemplateDetails.TestField("Object ID (Req.)");
                    exit(processTemplateDetails."Object ID (Req.)");
                end;
            else
                Error(notSupportedProcessingPlanTypeErr, processTemplateDetails."PrPl Type");
        end;
    end;

    local procedure addFilterForImport(var processTemplateDetail: Record DMTProcessTemplateDetail; fieldName: Text[30]; filterValue: Text[250])
    begin
        case true of
            (processTemplateDetail."PrPl Filter Field 1" = ''):
                begin
                    processTemplateDetail."PrPl Filter Field 1" := fieldName;
                    processTemplateDetail."PrPl Filter Value 1" := filterValue;
                end;
            (processTemplateDetail."PrPl Filter Field 2" = ''):
                begin
                    processTemplateDetail."PrPl Filter Field 2" := fieldName;
                    processTemplateDetail."PrPl Filter Value 2" := filterValue;
                end;
            else
                Error('Filter fields are already set');
        end;
        processTemplateDetail.Modify();
    end;

    local procedure translateTargetFilterToSourceFilter(var filteredView: Text; processTemplateDetail: Record DMTProcessTemplateDetail; importConfigHeader: Record DMTImportConfigHeader) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
        index: Integer;
        filterFieldName: List of [Text[30]];
        filterFieldValue: List of [Text[250]];
        filters: List of [Text];
    begin
        importConfigHeader.TestField(ID);
        importConfigHeader.TestField("Source File Name");
        if (processTemplateDetail."PrPl Filter Field 1" <> '') and
           (processTemplateDetail."PrPl Filter Value 1" <> '') then begin
            filterFieldName.Add(processTemplateDetail."PrPl Filter Field 1");
            filterFieldValue.Add(processTemplateDetail."PrPl Filter Value 1");
        end;

        if (processTemplateDetail."PrPl Filter Field 2" <> '') and
           (processTemplateDetail."PrPl Filter Value 2" <> '') then begin
            filterFieldName.Add(processTemplateDetail."PrPl Filter Field 2");
            filterFieldValue.Add(processTemplateDetail."PrPl Filter Value 2");
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

    local procedure addSourceFilter(var processingPlan: Record DMTProcessingPlan; processTemplateDetail: Record DMTProcessTemplateDetail) OK: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        filteredView: Text;
    begin
        OK := true;
        if not processingPlan.findImportConfigHeader(importConfigHeader) then
            exit(false);
        importConfigHeader.TestField(ID);
        importConfigHeader.TestField("Source File Name");
        if not translateTargetFilterToSourceFilter(filteredView, processTemplateDetail, importConfigHeader)
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
        fieldBuffer.SetRange(TableNo, NAVSourceTableID);
        if fieldBuffer.FindFirst() then
            if fieldBuffer."No. of Records" = 0 then
                exit(true);
    end;

    procedure IsSourceFileAvailable(processTemplateDetail: Record DMTProcessTemplateDetail) OK: Boolean
    var
        sourceFileStorage: Record DMTSourceFileStorage;
    begin
        // find source file
        processTemplateDetail.TestField(processTemplateDetail.Name);
        sourceFileStorage.SetRange(Name, processTemplateDetail.Name);
        OK := sourceFileStorage.FindFirst();
    end;

}