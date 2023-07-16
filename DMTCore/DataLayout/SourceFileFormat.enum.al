enum 91000 DMTSourceFileFormat implements ISourceFileImport
{
    Extensible = true;
    DefaultImplementation = ISourceFileImport = DMTDefaultSourceFileImportImpl;

    value(0; " ") { Caption = ' ', Locked = true; Implementation = ISourceFileImport = DMTDefaultSourceFileImportImpl; }
    value(1; "NAV CSV Export") { Caption = 'NAV CSV Export', Locked = true; Implementation = ISourceFileImport = DMTDefaultSourceFileImportImpl; }
    value(2; "Custom CSV") { Caption = 'Custom CSV', Comment = 'de-DE=CSV (individuell)'; Implementation = ISourceFileImport = DMTDefaultSourceFileImportImpl; }
    value(3; Excel) { Caption = 'Excel', Comment = 'de-DE=Excel'; Implementation = ISourceFileImport = DMTExcelMgt; }
}