codeunit 90013 DMTProcessTemplateLib
{
    procedure InsertProcessTemplateData()
    var
        processTemplate: Record DMTProcessTemplate;
    begin
        processTemplate.DeleteAll(true);

        Insert_Sachmerkmale();
    end;

    local procedure Insert_Sachmerkmale()
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        processTemplate: Record DMTProcessTemplate;
    begin
        processTemplate.Code := 'Sachmerkmale';
        processTemplate.Description := 'Sachmerkmale';
        processTemplate.Insert();

        addSrcFileRequirement(processTemplate, 'Sachmerkmale.csv');
        addSrcFileRequirement(processTemplate, 'Objekte für Formeln u. Regeln.csv');
        addSrcFileRequirement(processTemplate, 'Formeln Variablen Einrichtung.csv');
        addSrcFileRequirement(processTemplate, 'Sachmerkmalsgruppen.csv');
        addSrcFileRequirement(processTemplate, 'Instruktionen.csv');
        addSrcFileRequirement(processTemplate, 'Globale Auspr.-Kopf.csv');
        addSrcFileRequirement(processTemplate, 'Sachmerkmal.csv');
        addCodeunitRequirement(processTemplate, 5278008, 'M365 CMD Update Attribute');
        addSrcFileRequirement(processTemplate, 'Globale Auspr.-Pos..csv');
        addSrcFileRequirement(processTemplate, 'Sachmerkmal Übersetzung.csv');
        addSrcFileRequirement(processTemplate, 'Ausprägung Übersetzung.csv');
    end;

    local procedure addSrcFileRequirement(processTemplate: Record DMTProcessTemplate; NAVSourceTableID: Integer; fileName: Text[100])
    var
        processTemplateDetails: Record DMTProcessTemplateDetails;
    begin
        processTemplateDetails.Init();
        processTemplateDetails."Process Template Code" := processTemplate.Code;
        processTemplateDetails."Line No." := processTemplateDetails.getNextLineNo();
        processTemplateDetails.Type := processTemplateDetails.Type::Requirement;
        processTemplateDetails."Requirement Type" := processTemplateDetails."Requirement Type"::SourceFile;
        processTemplateDetails."Req. Src.Filename" := fileName;
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
        processTemplateDetails."Requirement Type" := processTemplateDetails."Requirement Type"::MigrationCodeunit;
        processTemplateDetails."Object Type (Req.)" := processTemplateDetails."Object Type (Req.)"::Codeunit;
        processTemplateDetails."Object ID (Req.)" := objectID;
        processTemplateDetails."Object Name (Req.)" := objectName;
        processTemplateDetails.Insert();
    end;


}