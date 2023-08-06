page 91012 DMTFieldLookup
{
    Caption = 'Fields', Comment = 'de-DE=Felder';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTDataLayoutLine;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field(Caption; Rec.NAVFieldCaption) { ApplicationArea = All; }
                field(Name; Rec.ColumnName) { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadLines();
    end;

    procedure LoadLines()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        DataLayout: Record DMTDataLayout;
        DataLayoutLine: Record DMTDataLayoutLine;
        TempDataLayoutLine: Record DMTDataLayoutLine temporary;
        GenBuffTable: Record DMTGenBuffTable;
        BuffTableCaptions: Dictionary of [Integer, Text];
        FieldNo: Integer;
    // ImportConfigHeader : Record DMTImportConfigHeader;
    // TempFieldBuffer: Record DMTFieldBuffer temporary;
    // Field: Record Field;
    begin
        if IsLoaded then exit;
        Rec.FilterGroup(4);
        case true of
            Rec.GetFilter("Data File ID Filter") <> '':
                begin
                    ImportConfigHeader.Get(Rec.GetRangeMin("Data File ID Filter"));
                    if not ImportConfigHeader."Use Separate Buffer Table" then begin
                        GenBuffTable.GetColCaptionForImportedFile(ImportConfigHeader, BuffTableCaptions);
                        foreach FieldNo in BuffTableCaptions.Keys do begin
                            TempDataLayoutLine.Init();
                            // TempDataLayoutLine."Data Layout ID" := ImportConfigHeader."Data Layout ID";
                            TempDataLayoutLine."Column No." := FieldNo;
                            TempDataLayoutLine.ColumnName := CopyStr(BuffTableCaptions.Get(FieldNo), 1, MaxStrLen(TempDataLayoutLine.ColumnName));
                            TempDataLayoutLine.Insert();
                            Rec.Copy(TempDataLayoutLine, true);
                        end;
                    end;
                    IsLoaded := true;
                end;
            else
                Error('unhandled case');
        end;
        Rec.FilterGroup(0);
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
}