interface IImportConfigPageAction
{
    procedure ImportConfigCard_TransferToTargetTable(var Rec: Record DMTImportConfigHeader);
    procedure ImportConfigCard_UpdateFields(var Rec: Record DMTImportConfigHeader);
    procedure ImportConfigCard_ImportBufferDataFromFile(var Rec: Record DMTImportConfigHeader);
    procedure ImportConfigCard_RetryBufferRecordsWithError(var Rec: Record DMTImportConfigHeader);
}