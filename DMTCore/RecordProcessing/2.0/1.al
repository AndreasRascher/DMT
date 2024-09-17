
/*
  DefineSourceRecords(SourceTableView: Text;ProcessErrorsOnly: Boolean;ImportConfigHeaderID: Integer)
  - Filters
  - RecordIDs to process

  PrepareRecordLoop
  - InitErrorLog
  - InitReplacements
  - InitFieldMapping
  - InitProgressDialog

  Loop through the source record set 
    ProcessRecord
      - FillKeyFields
      - FindExistingRecord
      - ProcessNonKeyFields
      - LogError
    UpdateProgressDialog
    - cout Results
  EndLoop

  PostProcess
  - LogErrors
  - LogStatistics
*/
codeunit 90000 DMTMigrationProcessor implements IMigrateRecordSet
{
    procedure SetSourceRecordSet(importConfigHeaderID: Integer; processErrorsOnly: Boolean; SourceTableView: Text);
    begin

    end;

    procedure SetNonKeyFieldsToProcess(var tempImportConfigLine: Record DMTImportConfigLine);
    begin

    end;

    procedure SetProcessingOptions(UpdateExistingRecords: Boolean; InsertOnlyNewRecords: Boolean);
    begin

    end;
}