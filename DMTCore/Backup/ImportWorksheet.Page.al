page 91018 "DMTImportWorksheet"
{
    Caption = 'DMT Import Worksheet', Comment = 'de-DE=DMT Import-Arbeitsblatt';
    PageType = Worksheet;
    DelayedInsert = true;
    SaveValues = true;
    SourceTable = DMTImportWorksheetBuffer;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(ImportWorksheetRepeater)
            {
                field(Type; Rec.Type) { }
                field(UniqueID; Rec.UniqueID) { }
                field(ImportAction; Rec.ImportAction) { }
            }
        }
    }
}