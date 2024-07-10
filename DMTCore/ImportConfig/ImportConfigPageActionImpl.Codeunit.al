codeunit 50065 DMTImportConfigPageActionImpl implements IImportConfigPageAction
{
    procedure ImportConfigCard_TransferToTargetTable(var Rec: Record DMTImportConfigHeader);
    var
        Migrate: Codeunit DMTMigrate;
    begin
        Migrate.AllFieldsFrom(Rec, false);
    end;

    procedure ImportConfigCard_UpdateFields(var Rec: Record DMTImportConfigHeader);
    var
        importConfigMgt: Codeunit DMTImportConfigMgt;
    begin
        importConfigMgt.PageAction_UpdateFields(Rec);
    end;

    procedure ImportConfigCard_ImportBufferDataFromFile(var Rec: Record DMTImportConfigHeader);
    begin
        Rec.ImportFileToBuffer();
    end;
}