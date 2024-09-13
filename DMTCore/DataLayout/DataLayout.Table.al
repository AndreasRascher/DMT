table 91002 DMTDataLayout
{
    Caption = 'Data Layout', Comment = 'de-DE=Datenlayout';
    DataClassification = CustomerContent;
    LookupPageId = DMTDataLayouts;
    DrillDownPageId = DMTDataLayouts;

    fields
    {
        field(1; ID; Integer) { Caption = 'ID', Locked = true; }
        field(10; Name; Text[250]) { Caption = 'Name', Comment = 'de-DE=Name'; }
        field(11; SourceFileFormat; Enum DMTSourceFileFormat) { Caption = 'Source File Format', Comment = 'de-DE=Dateiformat'; }
        field(12; "Has Heading Row"; Boolean) { Caption = 'Has Heading Row', Comment = 'de-DE=Enthält Überschriftenzeile'; }
        field(13; HeadingRowNo; Integer) { Caption = 'Heading Row no.', Comment = 'de-DE=Überschrift Zeilennr.'; }
        field(14; Default; Boolean)
        {
            Caption = 'Default', comment = 'de-DE=Standard';
            trigger OnValidate()
            var
                dataLayout: Record DMTDataLayout;
            begin
                if Default then begin
                    dataLayout.SetFilter(ID, '<>%1', rec.ID);
                    dataLayout.SetRange(SourceFileFormat, rec.SourceFileFormat);
                    dataLayout.ModifyAll(Default, false);
                end;
            end;
        }
        field(15; Preset; Boolean) { Caption = 'Preset', Comment = 'de-DE=Voreinstellung'; }
        field(100; CSVFieldSeparator; Text[50]) { Caption = 'Field Separator', Comment = 'de-DE=Feldtrenner'; InitValue = ';'; }
        field(101; CSVLineSeparator; Text[50]) { Caption = 'Line Separator', Comment = 'de-DE=Zeilentrenner'; InitValue = '<NewLine>'; }
        field(102; CSVFieldDelimiter; Text[50]) { Caption = 'Field Delimiter', Comment = 'de-DE=Feldbegrenzungszeichen'; InitValue = '"'; }
        field(103; CSVTextEncoding; Enum DMTTextEncoding) { Caption = 'Text Encoding', Comment = 'de-DE=Text Encoding'; }
        // field(200; NAVTableID; Integer) { Caption = 'NAV TableID', Comment = 'de-DE=Tabellen ID'; Editable = false; }
        field(302; XLSDefaultSheetName; Text[250])
        {
            Caption = 'Default Excel Sheet', Comment = 'de-DE=Standard Excel Blatt';
            Editable = false;
        }
        // field(50000; NAVTableCaption; Text[80]) { Caption = 'Table Caption', Comment = 'de-DE=Tabellenbezeichnung'; Editable = false; }
        // field(50001; NAVPrimaryKey; Text[250]) { Caption = 'Primary Key', Comment = 'de-DE=Primärschlüssel Felder'; Editable = false; }
        // field(50004; NAVNoOfRecords; Integer) { Caption = 'No. of Records', Comment = 'de-DE=Anz. Datensätze'; Editable = false; }
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }
    trigger OnDelete()
    var
        DataLayoutLine: Record DMTDataLayoutLine;
    begin
        if filterDataLayoutLines(DataLayoutLine) then
            DataLayoutLine.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if Rec.ID = 0 then
            Rec.ID := Rec.GetNextID();
    end;

    procedure filterDataLayoutLines(var DataLayoutLine: Record DMTDataLayoutLine) HasLinesInFilter: Boolean
    begin
        DataLayoutLine.SetRange("Data Layout ID", Rec.ID);
        HasLinesInFilter := not DataLayoutLine.IsEmpty;
    end;

    procedure GetNextID() NextID: Integer
    var
        DataLayout: Record DMTDataLayout;
    begin
        NextID := 1;
        if DataLayout.FindLast() then
            NextID += DataLayout.ID;
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

    local procedure AddCustomCSVPreset(dataLayoutName: Text[250]; csvEncoding: enum DMTTextEncoding;
                                                                               csvLineSeparator: Text;
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

    internal procedure CreateOrGetDataLayout(var dataLayout: Record DMTDataLayout; dataLayoutName: Text) OK: Boolean
    begin
        dataLayout.InsertPresetDataLayouts();
        dataLayout.SetRange(Name, dataLayoutName);
        OK := dataLayout.FindFirst();
    end;

    internal procedure GetDefaultNAVDMTLayout() dataLayout: Record DMTDataLayout
    begin
        CreateOrGetDataLayout(dataLayout, 'DMT NAV CSV Export');
    end;
}