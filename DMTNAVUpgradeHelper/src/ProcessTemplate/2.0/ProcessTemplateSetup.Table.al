table 90014 DMTProcessTemplateSetup
{
    fields
    {
        field(1; "Template Code"; Code[150]) { Caption = 'Template Code', Comment = 'de-DE=Vorlagencode'; }
        field(2; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennummer'; }
        #region SourceInfo
        field(10; Type; Option)
        {
            Caption = 'Type', Comment = 'de-DE=Art';
            OptionMembers = " ",Group,"Import Buffer","Import Target","Import Buffer+Target","Update Field","Default Value","Filter","Req. Setup","Run Codeunit";
            OptionCaption = ' ,Group,Import Buffer,Import Target,Import Buffer+Target,Update Field,Default Value,Filter,Req. Setup,Run Codeunit',
            Comment = 'de-DE= ,Gruppe,In Puffertabelle einlesen,In Zieltabelle einlesen,Puffer- und Zieltab. importieren,Felder aktualisieren,Vorgaberwert,Filter,benötigte Einrichtung,Codeunit ausführen';
        }
        field(11; "NAV Source Table No."; Integer) { Caption = 'NAV Source Table No.', Comment = 'de-DE=NAV Quelltabelle Nr.'; BlankZero = true; }
        field(12; "Source File Name"; Text[250]) { Caption = 'Source File Name', Comment = 'de-DE=Quelldatei Name'; }
        #endregion SourceInfo
        #region ProcessingPlan
        field(21; "Description"; Text[250]) { Caption = 'Description (Processing Plan)', Comment = 'de-DE=Beschreibung (Verarbeitungsplan)'; }
        field(22; "Indentation"; Integer) { Caption = 'Indentation (Processing Plan)', Comment = 'de-DE=Einrückung (Verarbeitungsplan)'; Editable = false; }
        field(23; "Run Codeunit"; Integer) { Caption = 'Run Codeunit ID (Processing Plan)', Comment = 'de-DE=Codeunit ID ausführen (Verarbeitungsplan)'; BlankZero = true; }
        field(30; "Field Name"; Text[30]) { Caption = 'Field Name', Comment = 'de-DE=Feldname'; }
        field(31; "Default Value"; Text[250]) { Caption = 'Default Value', Comment = 'de-DE=Vorgabewert'; }
        field(32; "Filter Expression"; Text[250]) { Caption = 'Filter', Comment = 'de-DE=Filter'; }
        field(24; "Target Table ID"; Integer) { Caption = 'Target Table ID', Comment = 'de-DE=Zieltabelle ID'; BlankZero = true; }
        field(25; "Target Table Caption"; Text[249])
        {
            Caption = 'Target Table Caption', Comment = 'de-DE=Zieltabellen Bezeichnung';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
        }
        #endregion ProcessingPlan
    }

    keys
    {
        key(Key1; "Template Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }


    internal procedure New(templateCode: Code[150])
    var
        ProcessTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup."Template Code" := templateCode;
        ProcessTemplateSetup."Line No." := getNextLineNo(templateCode);
        Rec.Copy(ProcessTemplateSetup);
    end;

    local procedure TargetTableExists(TargetTableID: Integer) exists: Boolean
    var
        allObjWithCaption: Record allObjWithCaption;
    begin
        exists := allObjWithCaption.get(allObjWithCaption."Object Type"::Table, TargetTableID);
    end;

    local procedure TargetCodenitExists(TargetCodeunitID: Integer) exists: Boolean
    var
        allObjWithCaption: Record allObjWithCaption;
    begin
        exists := allObjWithCaption.get(allObjWithCaption."Object Type"::Codeunit, TargetCodeunitID);
    end;

    procedure tryFindMappedProcessingPlanType(var processingPlanType: Enum DMTProcessingPlanType) OK: Boolean
    begin
        ok := true;
        case Rec."Type" of
            Rec."Type"::" ":
                processingPlanType := processingPlanType::" ";
            Rec."Type"::Group:
                processingPlanType := processingPlanType::Group;
            Rec."Type"::"Import Buffer":
                processingPlanType := processingPlanType::"Import To Buffer";
            Rec."Type"::"Import Target":
                processingPlanType := processingPlanType::"Import To Target";
            Rec."Type"::"Import Buffer+Target":
                processingPlanType := processingPlanType::"Buffer + Target";
            Rec."Type"::"Update Field":
                processingPlanType := processingPlanType::"Update Field";
            Rec.Type::"Run Codeunit":
                processingPlanType := processingPlanType::"Run Codeunit";
            else
                OK := false;
        end;
    end;

    procedure getNextLineNo(templateCode: Code[150]) NextLineNo: Integer
    var
        ProcessTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup.SetRange("Template Code", templateCode);
        if ProcessTemplateSetup.FindLast() then;
        NextLineNo += ProcessTemplateSetup."Line No." + 10000;
    end;

    procedure initTemplateSetupFor(templateCode: Code[150])
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        debug: Integer;
    begin
        if InitializedTemplateCode = templateCode then
            exit;

        Clear(TemplateSourceFileNamesGlobal);
        Clear(TemplateCodeunitsGlobal);
        Clear(TemplateSourceFileNamesGlobal);
        Clear(TargetTablesGlobal);
        ProcessTemplateDetailGlobal.DeleteAll();
        debug := ProcessTemplateDetailGlobal.Count;
        processTemplateSetup.Reset();
        processTemplateSetup.SetRange("Template Code", templateCode);
        if processTemplateSetup.FindSet() then
            repeat
                // Steps
                if processTemplateSetup.tryFindMappedProcessingPlanType(ProcessTemplateDetailGlobal."PrPl Type") then begin
                    ProcessTemplateDetailGlobal.InsertNew(templateCode);
                    processTemplateSetup.tryFindMappedProcessingPlanType(ProcessTemplateDetailGlobal."PrPl Type");
                    ProcessTemplateDetailGlobal."NAV Source Table No.(Req.)" := processTemplateSetup."NAV Source Table No.";
                    if processTemplateSetup."Description" <> '' then
                        ProcessTemplateDetailGlobal.Name := processTemplateSetup."Description"
                    else
                        ProcessTemplateDetailGlobal.Name := processTemplateSetup."Source File Name";
                    ProcessTemplateDetailGlobal.Modify();
                    // Source file names
                    if processTemplateSetup."Source File Name" <> '' then
                        if not TemplateSourceFileNamesGlobal.Keys.Contains(processTemplateSetup."Source File Name") then
                            TemplateSourceFileNamesGlobal.Add(processTemplateSetup."Source File Name", processTemplateSetup."NAV Source Table No.");
                    // Codenunits to run 
                    if processTemplateSetup."Run Codeunit" <> 0 then begin
                        if not TemplateCodeunitsGlobal.Contains(processTemplateSetup."Run Codeunit") then
                            TemplateCodeunitsGlobal.Add(processTemplateSetup."Run Codeunit");
                        if not TargetCodeunitsMissingGlobal.Contains(processTemplateSetup."Run Codeunit") then
                            if TargetCodenitExists(processTemplateSetup."Run Codeunit") then
                                TargetCodeunitsMissingGlobal.Add(processTemplateSetup."Run Codeunit");

                    end;
                    // target tables
                    if processTemplateSetup.Type <> processTemplateSetup.Type::"Req. Setup" then
                        if processTemplateSetup."Target Table ID" <> 0 then begin
                            if not TargetTablesGlobal.Contains(processTemplateSetup."Target Table ID") then
                                TargetTablesGlobal.Add(processTemplateSetup."Target Table ID");
                            if not TargetTablesMissingGlobal.Contains(processTemplateSetup."Target Table ID") then
                                if TargetTableExists(processTemplateSetup."Target Table ID") then
                                    TargetTablesMissingGlobal.Add(processTemplateSetup."Target Table ID");
                        end;

                    //                         if allObjWithCaption.get(allObjWithCaption."Object Type"::Codeunit, processTemplateDetails."Object ID (Req.)") then
                    //                             noOfEntitiesFound += 1;
                    //                     end;
                    //                 processTemplateDetails."Requirement Sub Type"::"Table":
                    //                     begin
                    //                         if allObjWithCaption.get(allObjWithCaption."Object Type"::Table, processTemplateDetails."Object ID (Req.)") then
                    //                             noOfEntitiesFound += 1;
                end;
            until processTemplateSetup.Next() = 0;
        InitializedTemplateCode := templateCode;
    end;

    procedure getTemplateSourceFileNames() SourceFileNames: Dictionary of [Text/*Filename*/, Integer/*NAVTableNo*/]
    begin
        if InitializedTemplateCode = '' then
            Error(TemplateNotInitializedErr);
        SourceFileNames := TemplateSourceFileNamesGlobal;
    end;

    procedure getTemplateCodeunits() Codeunits: List of [Integer]
    begin
        if InitializedTemplateCode = '' then
            Error(TemplateNotInitializedErr);
        Codeunits := TemplateCodeunitsGlobal;
    end;

    procedure getTargetTables() TargetTables: List of [Integer]
    begin
        if InitializedTemplateCode = '' then
            Error(TemplateNotInitializedErr);
        TargetTables := TargetTablesGlobal;
    end;

    procedure getSteps(var processTemplateDetail: Record DMTProcessTemplateDetail temporary)
    var
        debug: Integer;
    begin
        debug := processTemplateDetail.Count;
        processTemplateDetail.Copy(ProcessTemplateDetailGlobal, true);
        debug := processTemplateDetail.Count;
    end;

    procedure getInitializedTemplateCode() TemplateCode: Code[150]
    begin
        TemplateCode := InitializedTemplateCode;
    end;


    var
        ProcessTemplateDetailGlobal: Record DMTProcessTemplateDetail;
        InitializedTemplateCode: Code[150];
        TemplateSourceFileNamesGlobal: Dictionary of [Text/*Filename*/, Integer/*NAVTableNo*/];
        TemplateCodeunitsGlobal, TargetCodeunitsMissingGlobal, TargetTablesGlobal, TargetTablesMissingGlobal : List of [Integer];
        TemplateNotInitializedErr: Label 'Template not initialized', Comment = 'de-DE=Vorlage nicht initialisiert';

}