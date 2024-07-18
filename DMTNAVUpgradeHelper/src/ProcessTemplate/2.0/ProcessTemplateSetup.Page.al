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
                field("Template Code"; Rec."Template Code") { StyleExpr = lineStyleExpr; }
                field("Line No."; Rec."Line No.") { StyleExpr = lineStyleExpr; }
                field("Source File Name"; Rec."Source File Name") { StyleExpr = lineStyleExpr; }
                field("PrPl Type"; Rec."PrPl Type") { StyleExpr = lineStyleExpr; }
                field("PrPl Indentation"; Rec."PrPl Indentation") { StyleExpr = lineStyleExpr; }
                field("PrPl Description"; Rec."PrPl Description") { StyleExpr = lineStyleExpr; }
                field("NAV Source Table No."; Rec."NAV Source Table No.") { StyleExpr = lineStyleExpr; }
                field("PrPl Default Target Table ID"; Rec."PrPl Default Target Table ID") { }
                field("PrPl Run Codeunit"; Rec."PrPl Run Codeunit") { StyleExpr = lineStyleExpr; }
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

    //templateCode, 5050, 'Kontakt.csv','Personenkontakte','Type','1'
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

    trigger OnAfterGetRecord()
    begin
        case true of
            (Rec."PrPl Type" = Rec."PrPl Type"::Group):
                lineStyleExpr := Format(Enum::DMTFieldStyle::Bold);
            else
                lineStyleExpr := Format(Enum::DMTFieldStyle::None);
        end;

    end;

    var
        lineStyleExpr: Text;
}