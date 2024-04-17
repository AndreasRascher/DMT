interface ITriggerLog
{
    procedure InitBeforeValidate(SourceField: FieldRef; TargetField: FieldRef; TmpTargetRef: RecordRef)
    procedure CheckAfterValidate(TmpTargetRef: RecordRef)
    procedure InitBeforeModify(TargetRef: RecordRef; UseTrigger: Boolean)
    procedure CheckAfterOnModiy(TargetRef: RecordRef)
    procedure InitBeforeInsert(TargetRef: RecordRef; UseTrigger: Boolean)
    procedure CheckAfterOnInsert(TargetRef: RecordRef)
    procedure findChangedFields(var changedFields: Dictionary of [Integer, List of [Text]]; recRefFrom: RecordRef; recRefTO: RecordRef) hasChangedFields: Boolean
    procedure DeleteExistingLogFor(BufferRef2: RecordRef);
    procedure SaveTriggerLog(log: Codeunit DMTLog; importConfigHeader: Record DMTImportConfigHeader)

}
