table 90014 DMTProcessTemplateSetup
{
    fields
    {
        field(1; "Template Code"; Code[150]) { Caption = 'Template Code', Comment = 'de-DE=Vorlagencode'; }
        field(2; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennummer'; }
        #region SourceInfo
        field(10; "NAV Source Table No."; Integer) { Caption = 'NAV Source Table No.', Comment = 'de-DE=NAV Quelltabelle Nr.'; BlankZero = true; }
        field(11; "Source File Name"; Text[250]) { Caption = 'Source File Name', Comment = 'de-DE=Quelldatei Name'; }
        #endregion SourceInfo
        #region ProcessingPlan
        field(20; "PrPl Type"; Enum DMTProcessingPlanType) { Caption = 'Type (Processing Plan)', Comment = 'de-DE=Art (Verarbeitungsplan)'; }
        field(21; "PrPl Indentation"; Integer) { Caption = 'Indentation (Processing Plan)', Comment = 'de-DE=Einrückung (Verarbeitungsplan)'; Editable = false; }
        field(22; "PrPl Description"; Text[250]) { Caption = 'Description (Processing Plan)', Comment = 'de-DE=Beschreibung (Verarbeitungsplan)'; }
        field(23; "PrPl Run Codeunit"; Integer) { Caption = 'Run Codeunit ID (Processing Plan)', Comment = 'de-DE=Codeunit ID ausführen (Verarbeitungsplan)'; BlankZero = true; }
        field(24; "PrPl Default Target Table ID"; Integer) { Caption = 'Default Target Table ID', Comment = 'de-DE=Vorgabe Zieltabelle ID'; BlankZero = true; }
        field(30; "PrPl Filter Field 1"; Text[30]) { Caption = 'Filter Field 1', Comment = 'de-DE=Filterfeld 1'; Editable = false; }
        field(31; "PrPl Filter Value 1"; Text[250]) { Caption = 'Filter Value 1', Comment = 'de-DE=Filterwert 1'; Editable = false; }
        field(32; "PrPl Filter Field 2"; Text[30]) { Caption = 'Filter Field 2', Comment = 'de-DE=Filterfeld 2'; Editable = false; }
        field(33; "PrPl Filter Value 2"; Text[250]) { Caption = 'Filter Value 2', Comment = 'de-DE=Filterwert 2'; Editable = false; }
        field(40; "PrPl Default Field 1"; Text[30]) { Caption = 'Default Field 1', Comment = 'de-DE=Vorgabefeld 1'; Editable = false; }
        field(41; "PrPl Default Value 1"; Text[250]) { Caption = 'Default Value 1', Comment = 'de-DE=Vorgabewert 1'; Editable = false; }
        field(42; "PrPl Default Field 2"; Text[30]) { Caption = 'Default Field 2', Comment = 'de-DE=Vorgabefeld 2'; Editable = false; }
        field(43; "PrPl Default Value 2"; Text[250]) { Caption = 'Default Value 2', Comment = 'de-DE=Vorgabewert 2'; Editable = false; }
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
                if processTemplateSetup."PrPl Type" <> DMTProcessingPlanType::Group then begin
                    ProcessTemplateDetailGlobal.InsertNew(templateCode);
                    ProcessTemplateDetailGlobal."NAV Source Table No.(Req.)" := processTemplateSetup."NAV Source Table No.";
                    ProcessTemplateDetailGlobal."PrPl Type" := processTemplateSetup."PrPl Type";
                    if processTemplateSetup."PrPl Description" <> '' then
                        ProcessTemplateDetailGlobal.Name := processTemplateSetup."PrPl Description"
                    else
                        ProcessTemplateDetailGlobal.Name := processTemplateSetup."Source File Name";
                    ProcessTemplateDetailGlobal.Modify();
                    // Source file names
                    if processTemplateSetup."Source File Name" <> '' then
                        if not TemplateSourceFileNamesGlobal.Contains(processTemplateSetup."Source File Name") then
                            TemplateSourceFileNamesGlobal.Add(processTemplateSetup."Source File Name");
                    // migration objects
                    if processTemplateSetup."PrPl Run Codeunit" <> 0 then
                        if not TemplateCodeunitsGlobal.Contains(processTemplateSetup."PrPl Run Codeunit") then
                            TemplateCodeunitsGlobal.Add(processTemplateSetup."PrPl Run Codeunit");
                    // target tables
                    if processTemplateSetup."PrPl Default Target Table ID" <> 0 then
                        if not TargetTablesGlobal.Contains(processTemplateSetup."PrPl Default Target Table ID") then
                            TargetTablesGlobal.Add(processTemplateSetup."PrPl Default Target Table ID");
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