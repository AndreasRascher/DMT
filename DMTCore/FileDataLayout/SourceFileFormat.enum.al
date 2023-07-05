enum 90000 DMTSourceFileFormat
{
    Extensible = true;

    value(0; " ") { Caption = ' ', Locked = true; }
    value(1; "NAV CSV Export") { Caption = 'NAV CSV Export', Locked = true; }
    value(2; "Custom CSV") { Caption = 'Custom CSV', comment = 'de-DE=CSV (individuell)'; }
}