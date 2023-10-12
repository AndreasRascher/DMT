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

    procedure InsertPresetDataLayouts()
    var
        setup: Record DMTSetup;
        isDefaultLayout: Boolean;
    begin
        isDefaultLayout := setup.IsNAVExport();
        AddCustomCSVPreset('DMT NAV CSV Export', enum::DMTTextEncoding::UTF8, '<CR/LF>', '<TAB>', '<None>', 1, isDefaultLayout);
        AddCustomCSVPreset('CSV (UTF-8), Überschrift in Zeile 1', enum::DMTTextEncoding::UTF8, '<CR/LF>', ';', '"', 1, false);
        AddExcelPreset('XLSX, Überschrift in Zeile 1', 1);
    end;

    local procedure AddCustomCSVPreset(dataLayoutName: Text[250]; csvEncoding: enum DMTTextEncoding; csvLineSeparator: Text;
                                                                                   csvFieldSeparator: Text;
                                                                                   csvFieldDelimiter: Text;
                                                                                   headingRowNoNew: Integer;
                                                                                   IsDefaultLayout: boolean);
    var
        dataLayout: Record DMTDataLayout;
    begin
        dataLayout.Name := dataLayoutName;
        dataLayout.SourceFileFormat := Enum::DMTSourceFileFormat::"Custom CSV";
        dataLayout.CSVTextEncoding := csvEncoding;
        dataLayout.CSVLineSeparator := CopyStr(csvLineSeparator, 1, MaxStrLen(dataLayout.CSVLineSeparator));
        dataLayout.CSVFieldSeparator := CopyStr(csvFieldSeparator, 1, MaxStrLen(dataLayout.CSVFieldSeparator));
        dataLayout.CSVFieldDelimiter := CopyStr(csvFieldDelimiter, 1, MaxStrLen(dataLayout.CSVFieldDelimiter));
        dataLayout."Has Heading Row" := headingRowNoNew <> 0;
        dataLayout.HeadingRowNo := headingRowNoNew;
        dataLayout.Default := IsDefaultLayout;
        insertPresetIfMissing(dataLayout);
    end;

    local procedure AddExcelPreset(dataLayoutName: Text[250]; headingRowNoNew: Integer)
    var
        dataLayout: Record DMTDataLayout;
    begin
        dataLayout.Name := dataLayoutName;
        dataLayout.SourceFileFormat := Enum::DMTSourceFileFormat::Excel;
        dataLayout."Has Heading Row" := headingRowNoNew <> 0;
        dataLayout.HeadingRowNo := headingRowNoNew;
        insertPresetIfMissing(dataLayout);
    end;

    local procedure insertPresetIfMissing(var dataLayout: Record DMTDataLayout)
    var
        existingPreset: Record DMTDataLayout;
    begin
        // Check if preset with same scope and name exists
        existingPreset.SetRange(SourceFileFormat, dataLayout.SourceFileFormat);
        existingPreset.SetRange(Name, dataLayout.Name);
        existingPreset.SetRange(Preset, true);
        if not existingPreset.IsEmpty then
            exit;
        // if default exists, keep it
        existingPreset.Reset();
        existingPreset.SetRange(Default, true);
        if not existingPreset.IsEmpty then
            clear(dataLayout.Preset);
        dataLayout.ID := dataLayout.GetNextID();
        dataLayout.Preset := true;
        dataLayout.Insert();
    end;
}