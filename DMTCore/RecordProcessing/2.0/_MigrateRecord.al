codeunit 90002 DMTMigrateRecord
{
    trigger OnRun()
    begin

    end;

    internal procedure Init(bufferRef: RecordRef; var tmpImportConfigLine: Record DMTImportConfigLine; iReplacementHandler: Interface IReplacementHandler)
    begin
        Error('Procedure Init not implemented.');
    end;

    internal procedure findExistingRecord(): Boolean
    begin
        Error('Procedure findExistingRecord not implemented.');
    end;

    internal procedure SaveErrors(log: Codeunit DMTLog)
    begin
        Error('Procedure SaveErrors not implemented.');
    end;

    internal procedure SetRunMode_ProcessKeyFields()
    begin
        RunMode := RunMode::ProcessKeyFields;
        TempImportConfigLine.Reset();
        TempImportConfigLine.SetRange("Is Key Field(Target)", true);
    end;

    internal procedure SetRunMode_ProcessNonKeyFields()
    begin
        RunMode := RunMode::ProcessNonKeyFields;
        TempImportConfigLine.Reset();
        TempImportConfigLine.SetRange("Is Key Field(Target)", true);
    end;

    internal procedure SetRunMode_InsertRecord()
    begin
        RunMode := RunMode::InsertRecord;
    end;

    internal procedure SetRunMode_ModifyRecord()
    begin
        RunMode := RunMode::ModifyRecord
    end;

    internal procedure CollectLastError()
    var
        ErrorItem: Dictionary of [Text, Text];
    begin
        if GetLastErrorText() = '' then
            exit;
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        ErrorItem.Add('ErrorValue', CurrValueToAssignText);
        ErrorItem.Add('ErrorTargetRecID', CurrTargetRecIDText);
        ErrorLogDict.Add(CurrFieldToProcess, ErrorItem);
        ProcessedFields.Add(CurrFieldToProcess);
        // Check if this error should block the insert oder modify
        if RunMode = RunMode::ProcessNonKeyFields then
            if not ErrorsOccuredThatShouldNotBeIngored then begin
                TempImportConfigLine.Get(CurrFieldToProcess);
                if not TempImportConfigLine."Ignore Validation Error" then
                    ErrorsOccuredThatShouldNotBeIngored := true;
            end;

        ClearLastError();
    end;

    procedure HasErrorsThatShouldNotBeIngored(): Boolean
    begin
        exit(ErrorsOccuredThatShouldNotBeIngored);
    end;

    var
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        CurrFieldToProcess: RecordId;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        ProcessedFields: List of [RecordId];
        RunMode: Option ProcessKeyFields,ProcessNonKeyFields,InsertRecord,ModifyRecord;
        CurrTargetRecIDText, CurrValueToAssignText : Text;
        ErrorsOccuredThatShouldNotBeIngored: Boolean;

}