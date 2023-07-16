interface IReplacementHandler
{
    /*
    - InitBatchProcess(DMTImportConfig)
   - InitProcess(SourceRef)
   - HasReplacementForTargetField(TargetFieldNo)
   - GetReplacementValue(TargetFieldNo) TargetFieldValue : FieldRef
    */
    procedure InitBatchProcess(DMTImportConfigHeader: Record DMTImportConfigHeader);
    procedure InitProcess(var SourceRef: RecordRef)
    procedure HasReplacementsForTargetField(TargetFieldNo: Integer) HasReplacements: Boolean
    procedure GetReplacementValue(TargetFieldNo: Integer) TargetFieldValue: FieldRef
}