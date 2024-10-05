// Idee: 
// - Erstellen einer Seite, die die Migrationsschritte anzeigt
// - Je Schritt die Fehler und die veränderten Felder anzeigen
// - Ziel: Validierungsprobleme, Dialoge, etc. den eizeln Schritten zuordnen
// - Elemente auf der Page:
//   - Aktuelles Feld/Wert der zugeordnet werden soll
//   - Letzes Feld
//   - Fehler aus dem letzen Schritt ()
//   - Alle geänderten Felder (ListPart)
// - Idee:
//   - Transaktionen mitschreiben die passieren (manual subscriber - onglobalinsert, onglobalmodify) 
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
                field(CurrStepType1; CurrStepType) { Caption = 'Current Step:', Comment = 'de-DE=Aktueller Schritt:'; }
                field(SourceType1; CurrSourceType) { Caption = 'Source Type:', Comment = 'de-DE=Quelle'; }
                field(SourceDescr; SourceDescr) { Caption = 'Source Description:', Comment = 'de-DE=Quellenbeschreibung:'; }
                field(CurrTargetDescr; CurrTargetDescr) { Caption = 'Target Field:', Comment = 'de-DE=Zielfeld:'; }
            }
            group(Errors)
            {
                Visible = ErrorsVisible;
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
            group(ChangedFields)
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
                Visible = NextVisible;

                trigger OnAction();
                var
                    importConfigLine: record DMTImportConfigLine;
                    tempImportConfigLine: record DMTImportConfigLine temporary;
                    changedFields: Dictionary of [Integer, List of [Text]];
                    fieldNo: Integer;
                begin
                    ClearLastError();
                    GlobalNoOfStepsProcessed += 1;
                    // Delete Steps from the list
                    ProcessingSteps.RemoveAt(1);
                    updateStepInfo(importConfigLine, SourceDescr, CurrTargetDescr, CurrStepType, CurrSourceType, ProcessingSteps);
                    // migrate field
                    importConfigLine.SetRecFilter();
                    importConfigLine.CopyToTemp(tempImportConfigLine);
                    GlobalMigrateRecord.SetImportConfigLine(tempImportConfigLine);
                    case CurrStepType of
                        CurrStepType::Field_Validate, CurrStepType::Field_ValidateIfNotEmpty, CurrStepType::Field_Assign,
                        CurrStepType::FixedValue_AssignValue, CurrStepType::FixedValue_ValidateValue, CurrStepType::FixedValue_ValidateIfNotEmpty:
                            if importConfigLine."Is Key Field(Target)" then
                                GlobalMigrateRecord.SetRunMode_ProcessKeyFields()
                            else
                                GlobalMigrateRecord.SetRunMode_ProcessNonKeyFields();
                        CurrStepType::InsertRecord, CurrStepType::InsertRecord_WithTrigger:
                            GlobalMigrateRecord.SetRunMode_InsertRecord();
                        CurrStepType::UpdateRecord, CurrStepType::UpdateRecord_WithTrigger:
                            GlobalMigrateRecord.SetRunMode_ModifyRecord();
                    end;
                    if GlobalMigrateRecord.Run() then begin
                        LastTmpTargetRef := TmpTargetRef;
                        GlobalMigrateRecord.GetTempTargetRef(TmpTargetRef);
                    end else begin
                        if not importConfigLine."Ignore Validation Error" then
                            removeInsertsAndUpdates(ProcessingSteps); // remove insert, because of errors
                    end;
                    if GlobalNoOfStepsProcessed = 1 then
                        LastTmpTargetRef.Open(GlobalImportConfigHeader."Target Table ID");
                    Rec.DeleteAll();
                    if DMTTriggerLogImpl.findChangedFields(changedFields, LastTmpTargetRef, TmpTargetRef) then begin
                        foreach fieldNo in changedFields.Keys do begin
                            importConfigLine.Get(GlobalImportConfigHeader.ID, fieldNo);
                            Rec := importConfigLine;
                            Rec."Fixed Value" := copyStr(changedFields.Get(fieldNo).Get(2), 1, MaxStrLen(rec."Fixed Value"));
                            Rec.Insert();
                        end;
                    end;


                    // Get the next step
                    // updateStepInfo(importConfigLine, NextSourceDescription, NextTargetFieldCaption, NextStepType, NextSourceType, ProcessingSteps);
                    NextVisible := ProcessingSteps.Count > 0;
                    ErrorsVisible := GetLastErrorText() <> '';
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            actionref(NextRef; Next) { }
        }
    }
    trigger OnOpenPage()
    var
        importConfigLine: record DMTImportConfigLine;
        tempImportConfigLine: record DMTImportConfigLine temporary;
        genBuffTable: Record DMTGenBuffTable;
    begin

        GlobalImportConfigHeader.get(2);
        GlobalImportConfigHeader.FilterRelated(importConfigLine);
        importConfigLine.CopyToTemp(tempImportConfigLine);
        GlobalImportSettings.SetImportConfigLine(tempImportConfigLine);
        GlobalImportSettings.init(GlobalImportConfigHeader, enum::DMTMigrationType::MigrateRecords);
        GlobalImportSettings.EvaluateOptionValueAsNumber(GlobalImportConfigHeader."Ev. Nos. for Option fields as" = GlobalImportConfigHeader."Ev. Nos. for Option fields as"::Position);

        genBuffTable.SetRange("Imp.Conf.Header ID", GlobalImportConfigHeader.ID);
        genBuffTable.SetRange(IsCaptionLine, false);
        genBuffTable.FindFirst();
        GlobalBufferRef.GetTable(genBuffTable);
        initProcessingSteps(GlobalBufferRef, GlobalImportConfigHeader);

        GlobalMigrateRecord.Init(GlobalBufferRef, GlobalImportSettings, iGloblalReplacementHandler);

        updateStepInfo(importConfigLine, SourceDescr, CurrTargetDescr, CurrStepType, CurrSourceType, ProcessingSteps);
        Rec.Insert();
        NextVisible := ProcessingSteps.Count > 0;
        ClearLastError();
    end;

    procedure initProcessingSteps(bufferRefNew: RecordRef; importConfigHeader: record DMTImportConfigHeader)
    var
        DMTSetup: Record DMTSetup;
        importConfigLine: record DMTImportConfigLine;
    begin
        GlobalNoOfStepsProcessed := 0;
        // prepare the replacement handler
        GlobalBufferRef := bufferRefNew;
        DMTSetup.getDefaultReplacementImplementation(iGloblalReplacementHandler);
        iGloblalReplacementHandler.InitBatchProcess(importConfigHeader);
        iGloblalReplacementHandler.InitProcess(GlobalBufferRef);

        importConfigHeader.FilterRelated(importConfigLine);
        // Key Fields
        importConfigLine.SetCurrentKey("Validation Order");
        importConfigLine.SetRange("Is Key Field(Target)", true);
        if importConfigLine.FindSet(false) then
            repeat
                addProcessingStep(importConfigLine);
            until importConfigLine.Next() = 0;
        // Non Key Fields
        importConfigLine.SetRange("Is Key Field(Target)", false);
        if importConfigLine.FindSet(false) then
            repeat
                addProcessingStep(importConfigLine);
            until importConfigLine.Next() = 0;
        //Insert
        if importConfigHeader."Use OnInsert Trigger" then begin
            SetProcessingSteps(ProcessingSteps, Format(CurrStepType::InsertRecord_WithTrigger), importConfigLine.RecordId);
        end else begin
            SetProcessingSteps(ProcessingSteps, format(CurrStepType::InsertRecord), importConfigLine.RecordId);
        end;
    end;

    local procedure SetProcessingSteps(var processingStepsNEW: List of [List of [Text]]; currStepTypeText: Text; RecordId: RecordId)
    var
        innerList: List of [Text];
    begin
        innerList.AddRange(Format(currStepTypeText, 0, '<Text>'), Format(RecordId, 0, 9));
        processingStepsNEW.Add(innerList);
    end;

    local procedure GetProcessingStep(var currStepTypeNEW: Option; var RecordId: RecordId; var processingStepsNEW: List of [List of [Text]]) OK: Boolean
    var
        innerList: List of [Text];
    begin
        Clear(currStepTypeNEW);
        Clear(RecordId);
        if processingStepsNEW.Count = 0 then
            exit(false);
        processingStepsNEW.Get(1, innerList);
        Evaluate(currStepTypeNEW, innerList.Get(1));
        if innerList.Count >= 2 then
            Evaluate(RecordId, innerList.Get(2), 9);
        exit(true);
    end;

    local procedure updateStepInfo(var importConfigLine: record DMTImportConfigLine; var SourceDescription: Text; var TargetDescription: Text; var stepType: Option; var sourceType: Option; ProcessingSteps: List of [List of [Text]]) OK: Boolean
    var
        recID: RecordId;
    begin
        Clear(SourceDescription);
        Clear(TargetDescription);
        Clear(stepType);
        Clear(sourceType);
        if not GetProcessingStep(stepType, recID, ProcessingSteps) then
            exit(false);

        case stepType of
            CurrStepType::Field_Validate, CurrStepType::Field_ValidateIfNotEmpty, CurrStepType::Field_Assign,
            CurrStepType::FixedValue_ValidateValue, CurrStepType::FixedValue_ValidateIfNotEmpty, CurrStepType::FixedValue_AssignValue:
                begin
                    CurrStepType := stepType;
                    importConfigLine.Get(recID);
                    importConfigLine.CalcFields("Target Field Caption");
                    SourceDescription := importConfigLine."Source Field Caption";
                    TargetDescription := importConfigLine."Target Field Caption";
                end;
            CurrStepType::InsertRecord, CurrStepType::InsertRecord_WithTrigger:
                begin
                    CurrStepType := stepType;
                    SourceDescription := 'Insert Record';
                    TargetDescription := '';
                end;
            CurrStepType::UpdateRecord, CurrStepType::UpdateRecord_WithTrigger:
                begin
                    CurrStepType := stepType;
                    SourceDescription := 'Update Record';
                    TargetDescription := '';
                end;
        end;
        exit(true);
    end;

    local procedure addProcessingStep(var importConfigLine: record DMTImportConfigLine)
    begin
        case importConfigLine."Processing Action" of
            enum::DMTFieldProcessingType::Transfer:
                begin
                    case importConfigLine."Validation Type" of
                        Enum::DMTFieldValidationType::AlwaysValidate:
                            SetProcessingSteps(ProcessingSteps, Format(CurrStepType::Field_Validate), importConfigLine.RecordId);
                        Enum::DMTFieldValidationType::AssignWithoutValidate:
                            SetProcessingSteps(ProcessingSteps, format(CurrStepType::Field_Assign), importConfigLine.RecordId);
                        Enum::DMTFieldValidationType::ValidateOnlyIfNotEmpty:
                            SetProcessingSteps(ProcessingSteps, format(CurrStepType::Field_ValidateIfNotEmpty), importConfigLine.RecordId);
                    end;
                end;
            Enum::DMTFieldProcessingType::FixedValue:
                begin
                    case importConfigLine."Validation Type" of
                        Enum::DMTFieldValidationType::AlwaysValidate:
                            SetProcessingSteps(ProcessingSteps, format(CurrStepType::FixedValue_ValidateValue), importConfigLine.RecordId);
                        Enum::DMTFieldValidationType::AssignWithoutValidate:
                            SetProcessingSteps(ProcessingSteps, format(CurrStepType::FixedValue_AssignValue), importConfigLine.RecordId);
                        Enum::DMTFieldValidationType::ValidateOnlyIfNotEmpty:
                            SetProcessingSteps(ProcessingSteps, format(CurrStepType::FixedValue_ValidateIfNotEmpty), importConfigLine.RecordId);
                    end;
                end;
        end;
    end;

    local procedure removeInsertsAndUpdates(var currProcessingSteps: List of [List of [Text]])
    var
        index: Integer;
        debug, debug2 : Text;
    begin
        for index := 1 to currProcessingSteps.Count do begin
            debug := currProcessingSteps.Get(index).Get(1);
            debug2 := Format(CurrStepType::InsertRecord);
            case currProcessingSteps.Get(index).Get(1) of
                Format(CurrStepType::InsertRecord),
                Format(CurrStepType::InsertRecord_WithTrigger),
                Format(CurrStepType::UpdateRecord),
                Format(CurrStepType::UpdateRecord_WithTrigger):
                    currProcessingSteps.RemoveAt(index);
            end;
        end;
    end;

    var
        GlobalImportConfigHeader: Record DMTImportConfigHeader;
        GlobalImportSettings: Codeunit DMTImportSettings;
        GlobalMigrateRecord: Codeunit DMTMigrateRecord;
        DMTTriggerLogImpl: Codeunit DMTTriggerLogImpl;
        GlobalBufferRef: RecordRef;
        LastTmpTargetRef, TmpTargetRef : RecordRef;
        iGloblalReplacementHandler: Interface IReplacementHandler;
        ProcessingSteps: List of [List of [Text]];
        CurrStepType: Option " ",Field_Assign,Field_Validate,Field_ValidateIfNotEmpty,FixedValue_AssignValue,FixedValue_ValidateValue,FixedValue_ValidateIfNotEmpty,InsertRecord,InsertRecord_WithTrigger,UpdateRecord,UpdateRecord_WithTrigger;
        CurrSourceType: Option SourceField,FixedValue,ReplacementValue;
        CurrTargetDescr: Text;
        SourceDescr: Text;
        NextVisible, ErrorsVisible : Boolean;
        GlobalNoOfStepsProcessed: Integer;

}