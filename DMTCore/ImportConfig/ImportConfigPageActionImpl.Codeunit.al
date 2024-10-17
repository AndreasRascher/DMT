codeunit 91025 DMTImportConfigPageActionImpl implements IImportConfigPageAction
{
    // procedure ImportConfigCard_TransferToTargetTable(var Rec: Record DMTImportConfigHeader);
    // var
    //     Migrate: Codeunit DMTMigrate;
    // begin
    //     Migrate.AllFieldsFrom(Rec, false);
    // end;

    // procedure ImportConfigCard_UpdateFields(var Rec: Record DMTImportConfigHeader);
    // var
    //     importConfigMgt: Codeunit DMTImportConfigMgt;
    // begin
    //     importConfigMgt.PageAction_UpdateFields(Rec);
    // end;

    procedure ImportConfigCard_TransferToTargetTable(var Rec: Record DMTImportConfigHeader);
    var
        migrateRecordSet: Codeunit DMTMigrateRecordSet;
    begin
        migrateRecordSet.Start(Rec, Enum::DMTMigrationType::MigrateRecords);
    end;

    procedure ImportConfigCard_UpdateFields(var Rec: Record DMTImportConfigHeader);
    var
        migrateRecordSet: Codeunit DMTMigrateRecordSet;
        fieldSelection: Page DMTFieldSelection;
        UpdateFieldsFilter: Text;
    begin
        // // Show only Non-Key Fields for selection
        // SelectMultipleFields.Editable := true;
        // if not SelectMultipleFields.InitSelectTargetFields(Rec, Rec.ReadLastFieldUpdateSelection()) then
        //     exit;
        // RunModalAction := SelectMultipleFields.RunModal();
        // if RunModalAction = Action::OK then begin
        //     Rec.WriteLastFieldUpdateSelection(SelectMultipleFields.GetTargetFieldIDListAsText());
        //     migrateRecordSet.Start(Rec, Enum::DMTMigrationType::MigrateSelectsFields);
        // end;

        UpdateFieldsFilter := Rec.ReadLastFieldUpdateSelection();
        if fieldSelection.SelectFieldsToProcess(UpdateFieldsFilter, Rec) then begin
            Rec.WriteLastFieldUpdateSelection(UpdateFieldsFilter);
            migrateRecordSet.Start(Rec, Enum::DMTMigrationType::MigrateSelectsFields);
        end;
    end;

    procedure ImportConfigCard_ImportBufferDataFromFile(var Rec: Record DMTImportConfigHeader);
    begin
        Rec.ImportFileToBuffer();
    end;

    procedure ImportConfigCard_RetryBufferRecordsWithError(var ImportConfigHeader: Record DMTImportConfigHeader)
    var
        migrateRecordSet: Codeunit DMTMigrateRecordSet;
    begin
        migrateRecordSet.Start(ImportConfigHeader, Enum::DMTMigrationType::RetryErrors);
    end;
}