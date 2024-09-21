enum 90000 DMTMigrationType
{
    Extensible = true;

    value(0; MigrateRecords) { }

    value(1; MigrateSelectsFields) { }

    value(2; ApplyFixValuesToTarget) { }
}