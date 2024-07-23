
table 90012 DMTProcTemplSelection
{
    DataClassification = ToBeClassified;
    Caption = 'DMT Process Template', Comment = 'de-DE=DMT Prozessvorlage';
    LookupPageId = DMTProcessTemplateList;
    DrillDownPageId = DMTProcessTemplateList;

    fields
    {
        field(1; "Template Code"; Code[150]) { Caption = 'Code', Comment = 'de-DE=Code'; }
        field(2; Description; Text[250]) { Caption = 'Description', Comment = 'de-DE=Beschreibung'; }
        field(10; "Required Files Ratio"; Text[10]) { Caption = 'Required Files', Comment = 'de-DE=Benötigte Dateien'; }
        field(11; RequiredFilesStyle; Text[15]) { Caption = 'RequiredFilesStyle', Locked = true; Editable = false; }
        field(12; "Required Objects Ratio"; Text[10]) { Caption = 'Required Objects', Comment = 'de-DE=Benötigte Objekte'; }
        field(13; RequiredObjectsStyle; Text[15]) { Caption = 'RequiredObjectsStyle', Locked = true; Editable = false; }
        field(14; "Required Data Ratio"; Text[10]) { Caption = 'Required Data', Comment = 'de-DE=Erforderliche Daten'; }
        field(15; RequiredDataStyle; Text[15]) { Caption = 'RequiredDataStyle', Locked = true; Editable = false; }
    }

    keys
    {
        key(PK; "Template Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }


    procedure UpdateIndicators()
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        noOfRequiredEntities, noOfEntitiesFound : Integer;
    begin
        processTemplateSetup.initTemplateSetupFor(Rec."Template Code");
        // Ratio Source Files required to available
        noOfRequiredEntities := processTemplateSetup.getTemplateSourceFileNames().Count;
        noOfEntitiesFound := processTemplateSetup.getTemplateSourceFileNames().Count - processTemplateSetup.getMissingSourceFileNames().Count;
        Rec."Required Files Ratio" := StrSubstNo('%1/%2', noOfEntitiesFound, noOfRequiredEntities);

        // Required Objects required to available
        noOfRequiredEntities := processTemplateSetup.getTemplateCodeunits().Count + processTemplateSetup.getTargetTables().Count;
        noOfEntitiesFound := (processTemplateSetup.getTemplateCodeunits().Count - processTemplateSetup.getMissingCodeunits().Count) +
                             (processTemplateSetup.getTargetTables().Count - processTemplateSetup.getMissingTargetTables().Count);
        Rec."Required Objects Ratio" := StrSubstNo('%1/%2', noOfEntitiesFound, noOfRequiredEntities);
        // Required Data required to available

        // checkRequirementStatusByType(Rec.RequiredObjectsStyle, Rec."Required Objects Ratio", Rec,
        //                             StrSubstNo('%1|%2', processTemplateDetails."Requirement Sub Type"::"Codeunit",
        //                                                 processTemplateDetails."Requirement Sub Type"::"Table"));
        // checkRequirementStatusByType(Rec.RequiredFilesStyle, Rec."Required Files Ratio", Rec,
        //                             StrSubstNo('%1', processTemplateDetails."Requirement Sub Type"::SourceFile));
    end;

    // local procedure checkRequirementStatusByType(var styleExprNew: Text[15]; var requiredEntityRation: text[10]; processTemplate: Record DMTProcessTemplate; requirementSubTypeFilter: Text)
    // var
    //     processTemplateDetails: Record DMTProcessTemplateDetail;
    //     sourceFileStorage: Record DMTSourceFileStorage;
    //     allObjWithCaption: Record AllObjWithCaption;
    //     noOfRequiredEntities, noOfEntitiesFound : Integer;
    // begin
    //     styleExprNew := format(Enum::DMTFieldStyle::None);
    //     processTemplateDetails.SetRange(Type, processTemplateDetails.Type::Requirement);
    //     processTemplateDetails.SetFilter("Requirement Sub Type", requirementSubTypeFilter);
    //     processTemplateDetails.filterFor(processTemplate);
    //     if processTemplateDetails.FindSet() then
    //         repeat
    //             noOfRequiredEntities += 1;
    //             case processTemplateDetails."Requirement Sub Type" of
    //                 processTemplateDetails."Requirement Sub Type"::SourceFile:
    //                     begin
    //                         sourceFileStorage.SetFilter(Name, processTemplateDetails."Name");
    //                         if not sourceFileStorage.IsEmpty() then
    //                             noOfEntitiesFound += 1;
    //                     end;
    //                 processTemplateDetails."Requirement Sub Type"::"Codeunit":
    //                     begin
    //                         if allObjWithCaption.get(allObjWithCaption."Object Type"::Codeunit, processTemplateDetails."Object ID (Req.)") then
    //                             noOfEntitiesFound += 1;
    //                     end;
    //                 processTemplateDetails."Requirement Sub Type"::"Table":
    //                     begin
    //                         if allObjWithCaption.get(allObjWithCaption."Object Type"::Table, processTemplateDetails."Object ID (Req.)") then
    //                             noOfEntitiesFound += 1;
    //                     end;
    //             end;
    //         until processTemplateDetails.Next() = 0;
    //     requiredEntityRation := StrSubstNo('%1/%2', noOfEntitiesFound, noOfRequiredEntities);
    //     case true of
    //         (noOfRequiredEntities = 0):
    //             styleExprNew := format(Enum::DMTFieldStyle::None);
    //         (noOfEntitiesFound < noOfRequiredEntities):
    //             styleExprNew := format(Enum::DMTFieldStyle::"Bold + Italic + Red");
    //         (noOfEntitiesFound = noOfRequiredEntities):
    //             styleExprNew := format(Enum::DMTFieldStyle::"Bold + Green");
    //     end;
    // end;


}