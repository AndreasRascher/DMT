interface IValueMigrationLog
{
    procedure Activate();
    procedure IsActive(): Boolean;
    procedure setBeforeState(targetRefBeforeChange: RecordRef);
    procedure setAfterState(targetRefAfterChange: RecordRef);
    procedure analyseStatesForAction(recOperationType: Enum DMTRecOperationType; fieldNo: Integer);
    procedure showChangesInOrder(forFieldNo: Integer);

}