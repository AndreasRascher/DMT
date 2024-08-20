
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
        processTemplateLib: Codeunit DMTProcessTemplateLib;
        noOfRequiredObjects, noOfRequiredData, noOfRequiredSourceFiles : Integer;
        noOfFoundObjects, noOfFoundData, noOfFoundSourceFiles : Integer;
    begin
        processTemplateLib.calcRequirementRatios(Rec."Template Code", noOfRequiredObjects, noOfRequiredData, noOfRequiredSourceFiles, noOfFoundObjects, noOfFoundData, noOfFoundSourceFiles);
        setEntityStyleAndRatio(Rec.RequiredDataStyle, Rec."Required Data Ratio", noOfFoundData, noOfRequiredData);
        setEntityStyleAndRatio(Rec.RequiredObjectsStyle, Rec."Required Objects Ratio", noOfFoundObjects, noOfRequiredObjects);
        setEntityStyleAndRatio(Rec.RequiredFilesStyle, Rec."Required Files Ratio", noOfFoundSourceFiles, noOfRequiredSourceFiles);
    end;

    local procedure setEntityStyleAndRatio(var style: Text[15]; var ratio: Text[10]; noOfEntitiesFound: Integer; noOfRequiredEntities: Integer)
    begin
        style := Format(Enum::DMTFieldStyle::"Bold + Green");
        if noOfEntitiesFound < noOfRequiredEntities then
            Style := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
        ratio := StrSubstNo('%1/%2', noOfEntitiesFound, noOfRequiredEntities)
    end;


}