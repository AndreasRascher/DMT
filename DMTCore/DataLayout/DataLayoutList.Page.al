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
            InsertPresetDataLayouts();
    end;

    local procedure InsertPresetDataLayouts()
    var
        dataLayout: Record DMTDataLayout;
    begin
        dataLayout.ID := dataLayout.GetNextID();
        dataLayout.Name := 'CSV (UTF-8), Überschrift in Zeile 1';
        dataLayout.SourceFileFormat := dataLayout.SourceFileFormat::"Custom CSV";
        dataLayout.CSVFieldDelimiter := '"';
        dataLayout.CSVTextEncoding := dataLayout.CSVTextEncoding::UTF8;
        dataLayout.CSVLineSeparator := '<CR/LF>';
        dataLayout.CSVFieldSeparator := ';';
        dataLayout."Has Heading Row" := true;
        dataLayout.HeadingRowNo := 1;
        dataLayout.Insert();

        dataLayout.ID := dataLayout.GetNextID();
        dataLayout.Name := 'DMT NAV CSV Export';
        dataLayout.SourceFileFormat := dataLayout.SourceFileFormat::"Custom CSV";
        dataLayout.CSVFieldDelimiter := '"';
        dataLayout.CSVTextEncoding := dataLayout.CSVTextEncoding::UTF8;
        dataLayout.CSVLineSeparator := '<CR/LF>';
        dataLayout.CSVFieldSeparator := '<TAB>';
        dataLayout.CSVFieldDelimiter := '<None>';
        dataLayout."Has Heading Row" := true;
        dataLayout.HeadingRowNo := 1;
        dataLayout.Insert();

        dataLayout.ID := dataLayout.GetNextID();
        dataLayout.Name := 'XLSX, Überschrift in Zeile 1';
        dataLayout.SourceFileFormat := dataLayout.SourceFileFormat::Excel;
        dataLayout."Has Heading Row" := true;
        dataLayout.HeadingRowNo := 1;
        dataLayout.Insert();
    end;
}