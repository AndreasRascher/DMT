page 50007 DMTDataLayouts
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
                field(Default; Rec.Default) { }
                field("Has Heading Row"; Rec."Has Heading Row") { }
                field(HeadingRowNo; Rec.HeadingRowNo) { }
            }
        }
        area(FactBoxes)
        {

        }
    }
    trigger OnOpenPage()
    var
        dataLayout: Record DMTDataLayout;
    begin
        if dataLayout.IsEmpty then
            Rec.InsertPresetDataLayouts();
    end;


}