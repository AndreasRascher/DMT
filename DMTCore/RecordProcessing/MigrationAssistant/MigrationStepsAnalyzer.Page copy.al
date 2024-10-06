page 91028 DMTMigrationStepsAnalyzer
{
    Caption = 'Migration Steps Analyzer';
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = DMTImportConfigLine;
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(InfoStep)
            {
                // field(CurrStepType1; CurrStepType) { Caption = 'Current Step:', Comment = 'de-DE=Aktueller Schritt:'; }
                // field(SourceType1; CurrSourceType) { Caption = 'Source Type:', Comment = 'de-DE=Quelle'; }
                // field(SourceDescr; SourceDescr) { Caption = 'Source Description:', Comment = 'de-DE=Quellenbeschreibung:'; }
                // field(CurrTargetDescr; CurrTargetDescr) { Caption = 'Target Field:', Comment = 'de-DE=Zielfeld:'; }
            }
            group(Errors)
            {
                // Visible = ErrorsVisible;
                field(ErrorType; GetLastErrorCode) { Editable = false; }
                field(ErrorDescription; GetLastErrorText()) { MultiLine = true; Editable = false; }
                field(ErrorCallstack; GetLastErrorCallStack())
                {
                    MultiLine = true;
                    Editable = false;
                    trigger OnAssistEdit()
                    begin
                        Message(GetLastErrorCallStack);
                    end;
                }

            }
            group(LinesOfChangedFields)
            {
                Caption = 'Changed Fields', Comment = 'de-DE=Geänderte Felder';
                repeater(ChangedFieldsForCurrStep)
                {
                    field("Target Field Caption"; Rec."Target Field Caption") { }
                    field("Fixed Value"; Rec."Fixed Value") { Caption = 'New Value', Comment = 'de-DE=Neuer Wert'; }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Next)
            {
                ApplicationArea = All;
                Image = NextRecord;
                // Visible = NextVisible;

                trigger OnAction();
                begin
                    DoNextStep(true);
                end;
            }
        }
        area(Promoted)
        {
            actionref(NextRef; Next) { }
        }
    }
    trigger OnOpenPage()
    begin
        getTestCase(GlobalBufferRef, GlobalImportConfigHeader);
        prepareMigration(GlobalImportConfigHeader);
        loadSteps(GlobalSteps, GlobalBufferRef);
        DoNextStep(false);
    end;

    procedure DoNextStep(removeCurrentStep: Boolean)
    begin
        if removeCurrentStep then
            removeTopStep();
        prepareCurrentStepAndUpdateControls();
        executeCurrentStep();
        updateDependingSteps()
    end;

    /*init buffer reference to process*/
    local procedure prepareMigration(importConfigHeader: record DMTImportConfigHeader)
    var
        importConfigLine: record DMTImportConfigLine;
        tempImportConfigLine: record DMTImportConfigLine temporary;
    begin
        importConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.CopyToTemp(tempImportConfigLine);
        GlobalImportSettings.SetImportConfigLine(tempImportConfigLine);

        GlobalImportSettings.init(importConfigHeader, enum::DMTMigrationType::MigrateRecords);
        GlobalImportSettings.EvaluateOptionValueAsNumber(importConfigHeader."Ev. Nos. for Option fields as" = GlobalImportConfigHeader."Ev. Nos. for Option fields as"::Position);

        Setup.getDefaultReplacementImplementation(iGloblalReplacementHandler);
        iGloblalReplacementHandler.InitBatchProcess(importConfigHeader);
        iGloblalReplacementHandler.InitProcess(GlobalBufferRef);

        GlobalMigrateRecord.Init(GlobalBufferRef, GlobalImportSettings, iGloblalReplacementHandler);

        ClearLastError();
    end;

    /*create a list of steps*/
    local procedure loadSteps(var GlobalSteps: List of [List of [Text]]; var iReplacementHandler: Interface IReplacementHandler)
    var
        tempImportConfigLine: Record DMTImportConfigLine temporary;
        importConfigLine: Record DMTImportConfigLine;
    begin
        // load field list
        GlobalImportConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.CopyToTemp(tempImportConfigLine);
        // Key fields
        tempImportConfigLine.Reset();
        tempImportConfigLine.SetRange("Is Key Field(Target)", true);
        if tempImportConfigLine.FindSet() then repeat
            // Insert Record / Update Record
        until tempImportConfigLine.Next() = 0;
        // Non-key fields
        // Insert Record / Update Record
    end;

    /*Remove top from steps list after excecution*/
    local procedure removeTopStep()
    begin
        if GlobalSteps.Count > 0 then
            GlobalSteps.RemoveAt(1);
    end;

    /* If Error occured (not ignored), remove insert or modify transactions */
    local procedure updateDependingSteps()
    begin
        Error('Procedure updateDependingSteps not implemented.');
    end;

    /*Read top step and set page controls*/
    local procedure prepareCurrentStepAndUpdateControls()
    begin
    end;

    /* run field migration for current step */
    local procedure executeCurrentStep()
    begin
    end;

    local procedure getTestCase(var bufferRef: RecordRef; var importConfigHeader: Record DMTImportConfigHeader)
    var
        genBuffTable: Record DMTGenBuffTable;
    begin
        importConfigHeader.get(2);
        genBuffTable.SetRange("Imp.Conf.Header ID", importConfigHeader.ID);
        genBuffTable.SetRange(IsCaptionLine, false);
        genBuffTable.FindFirst();
        bufferRef.GetTable(genBuffTable);
    end;

    var
        GlobalImportConfigHeader: Record DMTImportConfigHeader;
        GlobalImportSettings: Codeunit DMTImportSettings;
        GlobalMigrateRecord: Codeunit DMTMigrateRecord;
        iGloblalReplacementHandler: Interface iReplacementHandler;
        GlobalBufferRef: RecordRef;
        GlobalSteps: List of [List of [Text]];
        Setup: Record DMTSetup;
}