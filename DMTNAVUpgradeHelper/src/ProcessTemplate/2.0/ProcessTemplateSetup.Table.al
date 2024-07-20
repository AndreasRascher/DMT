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

    internal procedure InitDefaults()
    begin
    end;

    procedure getMappedProcessingPlanType() processingPlanType: Enum DMTProcessingPlanType
    begin
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
            else
                Error('Unknown processing template type "%1"', Rec."Type");
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
                if processTemplateSetup."Type" <> processTemplateSetup."Type"::Group then begin
                    ProcessTemplateDetailGlobal.InsertNew(templateCode);
                    ProcessTemplateDetailGlobal."NAV Source Table No.(Req.)" := processTemplateSetup."NAV Source Table No.";
                    ProcessTemplateDetailGlobal."PrPl Type" := processTemplateSetup.getMappedProcessingPlanType();
                    if processTemplateSetup."Description" <> '' then
                        ProcessTemplateDetailGlobal.Name := processTemplateSetup."Description"
                    else
                        ProcessTemplateDetailGlobal.Name := processTemplateSetup."Source File Name";
                    ProcessTemplateDetailGlobal.Modify();
                    // Source file names
                    if processTemplateSetup."Source File Name" <> '' then
                        if not TemplateSourceFileNamesGlobal.Contains(processTemplateSetup."Source File Name") then
                            TemplateSourceFileNamesGlobal.Add(processTemplateSetup."Source File Name");
                    // migration objects
                    if processTemplateSetup."Run Codeunit" <> 0 then
                        if not TemplateCodeunitsGlobal.Contains(processTemplateSetup."Run Codeunit") then
                            TemplateCodeunitsGlobal.Add(processTemplateSetup."Run Codeunit");
                    // target tables
                    if processTemplateSetup.Type <> processTemplateSetup.Type::"Req. Setup" then
                        if processTemplateSetup."Target Table ID" <> 0 then
                            if not TargetTablesGlobal.Contains(processTemplateSetup."Target Table ID") then
                                TargetTablesGlobal.Add(processTemplateSetup."Target Table ID");
                end;
            until processTemplateSetup.Next() = 0;
        InitializedTemplateCode := templateCode;
    end;

    procedure getTemplateSourceFileNames() SourceFileNames: List of [Text]
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
        TemplateSourceFileNamesGlobal: List of [Text];
        TemplateCodeunitsGlobal, TargetTablesGlobal : List of [Integer];
        TemplateNotInitializedErr: Label 'Template not initialized', Comment = 'de-DE=Vorlage nicht initialisiert';

}