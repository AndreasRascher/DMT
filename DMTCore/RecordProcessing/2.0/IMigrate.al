// interface IMigrateRecordSet
// {
//     procedure SetSourceRecordSet(SourceTableID: Integer; SourceTableView: Text);
//     procedure SetSourceRecordSet(RecIDList: List of [RecordID]);
//     procedure SetTargetTable(TableID: Integer);
//     procedure SetFieldMapping(var tempImportConfigLine: Record DMTImportConfigLine);
//     procedure SetFixedValues(fixedValues: Dictionary of [Integer/*Target Field ID*/, Text/*fixed Value*/]);
//     procedure SetProcessingOptions(UpdateExistingRecords: Boolean; InsertOnlyNewRecords: Boolean);
//     procedure Read(var sourceRef: RecordRef): Boolean;
// }


// interface IMigrateRecord
// {
//     procedure SetSourceRecord(var sourceRef: RecordRef);
//     procedure setFieldMapping(var tempImportConfigLine: Record DMTImportConfigLine);
//     procedure InitFillKeyFields(var tempTargetRefResult: RecordRef);
//     procedure InitFillNonKeyFields(var tempTargetRefResult: RecordRef; var tempImportConfigLine: Record DMTImportConfigLine);
//     procedure InitInsertTargetRecord(runTrigger: Boolean)
//     procedure Execute();
//     procedure FindExistingRecord(var existingTargetRef: RecordRef; targetRecID: RecordId) targetRefExists: Boolean;
//     procedure ShouldProcessRecord(var tempTargetRefResult: RecordRef; updateExistingRecordsOnly: Boolean; InsertOnlyNewRecords: Boolean; targetRefExists: Boolean): Boolean;
//     procedure GetProcessingResult(): enum DMTProcessingResultType;
//     procedure LogError();
// }

// codeunit 90001 TestMigrateRecordSet
// {
//     Subtype = Test;

//     [Test]
//     procedure "ABufferTableShouldBeMigrated_AnImportConfigIsDefines_MigrateAllRecordsFromBuffer"()
//     var
//         genBuffTable: Record DMTGenBuffTable;
//         importConfigHeader: Record DMTImportConfigHeader;
//         importConfigLine: Record DMTImportConfigLine;
//         TempImportConfigLine: Record DMTImportConfigLine temporary;
//         sourceRef: RecordRef;
//         tempTargetRefResult: RecordRef;
//         IMigrateRecord: Interface IMigrateRecord;
//         IMigrateRecordSet: Interface IMigrateRecordSet;
//     begin
//         // [GIVEN] GivenABufferTableShouldBeMigrated 
//         if not genBuffTable.FilterBy(importConfigHeader) then
//             Error('No records to migrate');

//         // [WHEN] WhenAnImportConfig exists
//         importConfigHeader.TestField(ID);
//         importConfigHeader.TestField("Target Table ID");
//         // [THEN] Define Source Record Set and Target Table
//         IMigrateRecordSet.SetSourceRecordSet(Database::DMTGenBuffTable, genBuffTable.GetView());
//         IMigrateRecordSet.SetTargetTable(importConfigHeader."Target Table ID");


//         // [WHEN] Field Mapping is defined
//         importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader.ID);
//         importConfigLine.CopyToTemp(TempImportConfigLine);
//         if importConfigLine.IsEmpty then
//             Error('No field mapping defined');
//         // [THEN] Set Processing Options
//         IMigrateRecordSet.SetFieldMapping(TempImportConfigLine);

//         while IMigrateRecordSet.Read(sourceRef) do begin
//             IMigrateRecord.setSourceRecord(sourceRef);
//             IMigrateRecord.setFieldMapping(TempImportConfigLine);
//             IMigrateRecord.InitFillKeyFields(tempTargetRefResult);
//             Problem: If codeunit run geht mit interfaces nicht
//             while not IMigrateRecord.Run do
//                 IMigrateRecord.LogError();
//         end;


//     end;
// }
