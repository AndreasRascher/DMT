codeunit 90013 DMTProcessTemplateLib
{
    procedure InsertProcessTemplateData()
    var
        processTemplate: Record DMTProcessTemplate;
    begin
        processTemplate.DeleteAll(true);

        Insert_Sachmerkmale();
        Insert_Contact_Customer_Vendor();
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
        processTemplateDetails: Record DMTProcessTemplateDetail;
        nextLineNo: Integer;
        templateAlreadyTransferedErr: Label 'Process Template %1 already transferred to Processing Plan', Comment = 'de-DE=Vorlage %1 wurde bereits übertragen';
    begin
        processingPlan.SetRange("Process Template Code", processTemplate.Code);
        if not processingPlan.IsEmpty() then
            Error(templateAlreadyTransferedErr, processTemplate.Code);

        processingPlan.Reset();
        if not processingPlan.FindLast() then;
        nextLineNo := processingPlan."Line No." + 10000;

        processTemplateDetails.SetRange(Type, processTemplateDetails.Type::Step);
        if not processTemplateDetails.filterFor(processTemplate) then
            exit;
        processTemplateDetails.FindSet();
        repeat
            processingPlan.Init();
            processingPlan."Line No." := nextLineNo;
            processingPlan.Type := processTemplateDetails."Processing Plan Type";
            processingPlan.ID := findOrCreateProcessingPlanID(processTemplateDetails);
            processingPlan."Process Template Code" := processTemplate.Code;
            processingPlan.Description := processTemplateDetails.Name;
            processingPlan.Indentation := processTemplateDetails."Proc.Plan Indentation";
            processingPlan.Insert();
            nextLineNo += 10000;
        until processTemplateDetails.Next() = 0;
    end;

    local procedure Insert_Contact_Customer_Vendor()
    var
        processTemplate: Record DMTProcessTemplate;
        processTemplateDetail: Record DMTProcessTemplateDetail;
        CustContVendorLbl: Label 'Contact, Customer, Vendor', Comment = 'de-DE=Kontakt, Kunde, Lieferant';
    begin
        processTemplate.addTemplate(CustContVendorLbl);
        addSrcFileRequirement(processTemplate, 5050, 'Kontakt.csv');
        addSrcFileRequirement(processTemplate, 18, 'Debitor.csv');
        addSrcFileRequirement(processTemplate, 27, 'Kreditor.csv');
        addStep_ImportToBuffer(processTemplateDetail, processTemplate, 'Kontakt.csv');
        addFilterForImport(processTemplateDetail, 'Kontakt.csv', 'Type', '0');
        addStep_ImportToTarget(processTemplate, 'Kontakt.csv');
        addStep_ImportToBuffer(processTemplateDetail, processTemplate, 'Debitor.csv');
        addStep_ImportToTarget(processTemplate, 'Debitor.csv');
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
        processTemplateDetails_NEW."Processing Plan Type" := processTemplateDetails_NEW."Processing Plan Type"::"Import To Buffer";
        processTemplateDetails_NEW.Insert();
    end;

    local procedure addStep_ImportToTarget(processTemplate: Record DMTProcessTemplate; importFileName: Text[250])
    var
        processTemplateDetails: Record DMTProcessTemplateDetail;
    begin
        processTemplateDetails.Init();
        processTemplateDetails."Process Template Code" := processTemplate.Code;
        processTemplateDetails."Line No." := processTemplateDetails.getNextLineNo();
        processTemplateDetails.Type := processTemplateDetails.Type::Step;
        processTemplateDetails.Name := importFileName;
        processTemplateDetails."Processing Plan Type" := processTemplateDetails."Processing Plan Type"::"Import To Target";
        processTemplateDetails.Insert();
    end;

    local procedure findOrCreateProcessingPlanID(processTemplateDetails: Record DMTProcessTemplateDetail): Integer
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        tempSourceFileStorage: Record DMTSourceFileStorage temporary;
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigMgt: Codeunit DMTImportConfigMgt;
        sourceFileNotFoundErr: Label 'Source File %1 not found', Comment = 'de-DE=Quelldatei %1 nicht gefunden';
        noImportConfigExitsForSourceFileErr: Label 'No Import Configuration exits for Source File %1', Comment = 'de-DE=Keine Importkonfiguration für Quelldatei %1 vorhanden';
        notSupportedProcessingPlanTypeErr: Label 'Processing Plan Type "%1" not supported', Comment = 'de-DE=Verarbeitungsplan Typ "%1" wird nicht unterstützt';
    begin
        case processTemplateDetails."Processing Plan Type" of
            processTemplateDetails."Processing Plan Type"::" ",
            processTemplateDetails."Processing Plan Type"::Group:
                exit(0);
            processTemplateDetails."Processing Plan Type"::"Import To Buffer",
            processTemplateDetails."Processing Plan Type"::"Buffer + Target",
            processTemplateDetails."Processing Plan Type"::"Import To Target",
            processTemplateDetails."Processing Plan Type"::"Update Field":
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
                            if importConfigHeader.UseGenericBufferTable() then
                                importConfigHeader.ImportFileToBuffer();
                            importConfigMgt.PageAction_ProposeMatchingFields(importConfigHeader.ID);
                        end;
                    end;
                    exit(importConfigHeader."ID")
                end;
            processTemplateDetails."Processing Plan Type"::"Run Codeunit":
                begin
                    processTemplateDetails.TestField("Object Type (Req.)", processTemplateDetails."Object Type (Req.)"::Codeunit);
                    processTemplateDetails.TestField("Object ID (Req.)");
                    exit(processTemplateDetails."Object ID (Req.)");
                end;
            else
                Error(notSupportedProcessingPlanTypeErr, processTemplateDetails."Processing Plan Type");
        end;
    end;

    local procedure addFilterForImport(processTemplateDetail: Record DMTProcessTemplateDetail; fileName: Text; fieldName: Text; filterValue: Text)
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        filteredView: Text;
    begin
        importConfigHeader.SetRange("Source File Name", fileName);
        if not importConfigHeader.FindFirst() then
            exit;
        importConfigLine.SetRange("Source Field Caption", fieldName);
        importConfigHeader.FilterRelated(importConfigLine);
        if not importConfigLine.FindFirst() then
            exit;
        //'VERSION(1) SORTING(Field1) WHERE(Field1027=1(0))'
        filteredView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%=1(0))');
        hier weiter machen: filter in Detail speichern, übernahme in Verarbeitungsplan
    end;

}