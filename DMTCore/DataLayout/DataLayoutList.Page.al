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
    trigger OnOpenPage()
    var
        dataLayout: Record DMTDataLayout;
    begin
        if dataLayout.IsEmpty then
            InsertPresetDataLayouts();
    end;

    local procedure InsertPresetDataLayouts()
    var
        dataLayout: Record DMTDataLayout;
    begin
        dataLayout.ID := dataLayout.GetNextID();
        dataLayout.Name := 'CSV (MS-DOS)';
        dataLayout.CSVFieldDelimiter := '"';
        dataLayout.CSVTextEncoding := dataLayout.CSVTextEncoding::MSDos;
        dataLayout.CSVLineSeparator := '<CR/LF>';
        dataLayout.CSVFieldSeparator := '"';
        dataLayout.Insert();
    end;
}