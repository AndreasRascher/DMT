page 90015 DMTProcessTemplateSetup
{
    Caption = 'DMT Process Template Setup', Comment = 'de-DE=DMT Prozessvorlagen Einrichtung';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcessTemplateSetup;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Template Code"; Rec."Template Code") { }
                field("Line No."; Rec."Line No.") { }
                field("Source File Name"; Rec."Source File Name") { }
                field("PrPl Type"; Rec."PrPl Type") { }
                field("PrPl Indentation"; Rec."PrPl Indentation") { }
                field("PrPl Description"; Rec."PrPl Description") { }
                field("NAV Source Table No."; Rec."NAV Source Table No.") { }
                field("PrPl Default Target Table ID"; Rec."PrPl Default Target Table ID") { }
                field("PrPl Run Codeunit"; Rec."PrPl Run Codeunit") { }
                field("PrPl Default Field 1"; Rec."PrPl Default Field 1") { }
                field("PrPl Default Field 2"; Rec."PrPl Default Field 2") { }
                field("PrPl Default Value 1"; Rec."PrPl Default Value 1") { }
                field("PrPl Default Value 2"; Rec."PrPl Default Value 2") { }
                field("PrPl Filter Field 1"; Rec."PrPl Filter Field 1") { }
                field("PrPl Filter Field 2"; Rec."PrPl Filter Field 2") { }
                field("PrPl Filter Value 1"; Rec."PrPl Filter Value 1") { }
                field("PrPl Filter Value 2"; Rec."PrPl Filter Value 2") { }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
    trigger OnOpenPage()
    var
        templateCode: code[150];
        CustContVendorLbl: Label 'Contact, Customer, Vendor', Comment = 'de-DE=Kontakt, Kunde, Lieferant';
    begin
        templateCode := 'Dimensions';
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
        addGroup(templateCode, CustContVendorLbl);
        addImportBufferAndTargetNAVFile(templateCode, 13, 'Verkäufer_Einkäufer.csv');
        // addImportBufferAndTargetNAVFile(templateCode, 5050, 'Kontakt.csv');
        // addImportBufferAndTargetNAVFile(templateCode, 18, 'Debitor.csv');
        // addImportBufferAndTargetNAVFile(templateCode, 27, 'Kreditor.csv');


        addStep_ImportToBufferAndTarget(processTemplateDetail, processTemplate, 13, 'Verkäufer_Einkäufer.csv');
        addStep_ImportToBuffer(processTemplateDetail, processTemplate, 'Kontakt.csv');

        addStep_ImportToTarget(processTemplateDetail, processTemplate, 'Kontakt.csv');
        addFilterForImport(processTemplateDetail, 'Type', '0');

        addStep_ImportToTarget(processTemplateDetail, processTemplate, 'Kontakt.csv');
        addFilterForImport(processTemplateDetail, 'Type', '1');

        addStep_ImportToBuffer(processTemplateDetail, processTemplate, 'Debitor.csv');
        addStep_ImportToTarget(processTemplateDetail, processTemplate, 'Debitor.csv');
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
}