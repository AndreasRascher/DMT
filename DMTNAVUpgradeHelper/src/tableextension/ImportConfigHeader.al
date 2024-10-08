tableextension 50000 DMTImportConfigHeader extends DMTImportConfigHeader
{
    fields
    {
        // Add changes to table fields here
        field(90000; "NAV Src.Table No."; Integer)
        {
            Caption = 'NAV Src.Table No.', Comment = 'de-DE=NAV Tabellennr.';
            trigger OnValidate()
            begin
                updateNAVTableFromTableNo();
            end;
        }
        field(90001; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name', Comment = 'de-DE=NAV Tabellenname'; Editable = false; }
        field(90002; "NAV Src.Table Caption"; Text[250]) { Caption = 'NAV Source Table Caption', Comment = 'de-DE=NAV Tabellenbezeichnung'; Editable = false; }
    }

    local procedure updateNAVTableFromTableNo()
    var
        fieldBuffer: Record DMTFieldBuffer;
        SchemaIsNotImportedErr: Label 'You have to import the Schema.csv.', comment = 'de-DE=Sie müssen die Schema.csv importieren.';
    begin
        if "NAV Src.Table No." = 0 then exit;
        if fieldBuffer.IsEmpty then
            Error(SchemaIsNotImportedErr);
        Clear("NAV Src.Table Name");
        Clear("NAV Src.Table Caption");
        fieldBuffer.SetRange(TableNo, "NAV Src.Table No.");
        fieldBuffer.SetLoadFields(TableNo, "Table Caption", TableName);
        if fieldBuffer.FindFirst() then begin
            "NAV Src.Table Caption" := fieldBuffer."Table Caption";
            "NAV Src.Table Name" := fieldBuffer.TableName;
        end;
    end;

    procedure SetNAVTableByFileName(fileName: text)
    var
        fieldBuffer: Record DMTFieldBuffer;
        NAVTableID: Integer;
    begin
        LoadFileNameMapping();
        if FileNameTableCaptionMapping.Get(fileName, NAVTableID) then begin
            fieldBuffer.SetRange(TableNo, NAVTableID);
            if fieldBuffer.FindFirst() then begin
                Rec."NAV Src.Table No." := fieldBuffer.TableNo;
                Rec."NAV Src.Table Name" := fieldBuffer.TableName;
                Rec."NAV Src.Table Caption" := fieldBuffer."Table Caption";
                Rec.Modify()
            end;
        end;
    end;

    local procedure LoadFileNameMapping()
    var
        fieldBuffer: Record DMTFieldBuffer;
        fileNameFromCaption: Text;
    begin
        if FileNameTableCaptionMapping.Count > 0 then exit;
        fieldBuffer.SetLoadFields(TableNo, "Table Caption");
        fieldBuffer.SetFilter(TableNo, '1..49999|100000..');
        if fieldBuffer.FindSet(false) then
            repeat
                //Land/Region -> Land_Region
                fileNameFromCaption := StrSubstNo('%1.csv', ConvertStr(fieldBuffer."Table Caption", '<>*\/|"', '_______'));
                // TODO: Doppelte Captions im Standard
                if not FileNameTableCaptionMapping.ContainsKey(fileNameFromCaption) then
                    FileNameTableCaptionMapping.Add(fileNameFromCaption, fieldBuffer.TableNo);
            until fieldBuffer.Next() = 0;

        // ignore Custom Tables with duplicate captions
        fieldBuffer.SetFilter(TableNo, '50000..99999');
        if fieldBuffer.FindSet(false) then
            repeat
                fileNameFromCaption := StrSubstNo('%1.csv', ConvertStr(fieldBuffer."Table Caption", '<>*\/|"', '_______'));
                if not FileNameTableCaptionMapping.ContainsKey(fileNameFromCaption) then
                    FileNameTableCaptionMapping.Add(fileNameFromCaption, fieldBuffer.TableNo);
            until fieldBuffer.Next() = 0;
    end;

    var
        FileNameTableCaptionMapping: Dictionary of [Text, Integer];

}