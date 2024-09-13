enum 91008 DMTProcessingPlanType
{
    Extensible = true;

    value(0; " ") { }
    value(1; "Group") { Caption = 'Group', Comment = 'de-DE=Gruppe'; }
    value(2; "Run Codeunit") { Caption = 'Run Codeunit', Comment = 'de-DE=Codeunit ausführen'; }
    value(3; "Import To Buffer") { Caption = 'Import to Buffer', Comment = 'de-DE=In Puffertabelle einlesen'; }
    value(4; "Import To Target") { Caption = 'Import to Target', Comment = 'de-DE=In Zieltabelle einlesen'; }
    value(5; "Update Field") { Caption = 'Update Field', Comment = 'de-DE=Felder aktualisieren'; }
    value(6; "Buffer + Target") { Caption = 'Buffer + Target', Comment = 'de-DE=Puffer- und Zieltab. importieren'; }
}