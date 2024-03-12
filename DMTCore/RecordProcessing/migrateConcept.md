Ziele:
- mit Interfaces die Migrationslogik erweiterbarer zu gestalten

IMigrateRecordSet
=================
InitSetup
- CheckSetup
- ImportConfigHeader
- ImportConfigLine
- Replacments
- InitLog
ProcessingOptions
- noUserInteraction
- selectedFields
- selectedRecords
- SourceTableFilters
- UpdateOnly
- NewOnly

IMigrateRecord
==============
ProcessKeyFields(var TargetRecID:RecordID)
ShouldProcessRecord(SourceRecID;TargetRecID)
    - TargetExists
    - TargetHasBeenUpdatedAfterLastRun 
    - UpdateOnly
    - NewOnly
ProcessNonKeyFields
RunMode_InsertRecord
RunMode_ModifyRecord

            ImportConfigHeader	NoUserInteraction	SourceTableView	LoadImportConfigLine	UpdateFieldsFilter	UpdateExistingRecordsOnly	RecIdToProcessList
AllFieldsFrom             	                        x	x	x	x			
SelectedFieldsFrom        	                        x	x			x	x	
RetryBufferRecordIDs                            	x	x		x			x
DMTDeleteDataInTargetTable.GetTargetRefRecordID							
BufferFor                                       	x	x	x	x	x		
AssignFieldWithoutValidate							



IMigrateRecordSet
- Initialize(LoadImportConfigLine)
- ImportSettings_SetSource(SourceTableNo,SourceTableView)
- ImportSettings_SetSource(RecIDToProcess)
- ImportSettings_SourceTableView
- ImportSettings_NoUserInteraction

IMigrateRecord
- MigrateKeyFields(var TargetRef,SourceRef)
- MigrateNonKeyFields(var TargetRef,SourceRef)