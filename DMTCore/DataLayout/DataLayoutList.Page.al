page 91007 DMTDataLayouts
{
    Caption = 'DMT Data Layouts', Comment = 'de-DE=DMT Datenlayouts Übersicht';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTDataLayout;
    CardPageId = DMTDataLayoutCard;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field(ID; Rec.ID) { }
                field(Name; Rec.Name) { }
                field(SourceFileFormat; Rec.SourceFileFormat) { }
            }
        }
        area(FactBoxes)
        {

        }
    }
}