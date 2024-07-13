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
        processTemplateDetails: Record DMTProcessTemplateDetails;
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
            processingPlan."Process Template Code" := processTemplate.Code;
            processingPlan.Description := processTemplateDetails.Name;
            processingPlan.Insert();
            nextLineNo += 10000;
        until processTemplateDetails.Next() = 0;
    end;

    local procedure Insert_Contact_Customer_Vendor()
    var
        processTemplate: Record DMTProcessTemplate;
        CustContVendorLbl: Label 'Contact, Customer, Vendor', Comment = 'de-DE=Kontakt, Kunde, Lieferant';
    begin
        processTemplate.addTemplate(CustContVendorLbl);
        addSrcFileRequirement(processTemplate, 5050, 'Contact.csv');
        addSrcFileRequirement(processTemplate, 18, 'Customer.csv');
        addSrcFileRequirement(processTemplate, 27, 'Vendor.csv');
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
        processTemplateDetails: Record DMTProcessTemplateDetails;
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
        processTemplateDetails: Record DMTProcessTemplateDetails;
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


}