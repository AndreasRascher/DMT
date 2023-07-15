page 91012 DMTFieldLookup
{
    Caption = 'Fields', comment = 'de-DE=Felder';
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
    // ImportConfigHeader : Record DMTImportConfigHeader;
    // TempFieldBuffer: Record DMTFieldBuffer temporary;
    // GenBuffTable: Record DMTGenBuffTable;
    // Field: Record Field;
    // BuffTableCaptions: Dictionary of [Integer, Text];
    // FieldNo: Integer;
    begin
        if IsLoaded then exit;
        Rec.FilterGroup(4);
        case true of
            Rec.GetFilter("Data File ID Filter") <> '':
                begin
                    ImportConfigHeader.Get(Rec.GetRangeMin("Data File ID Filter"));
                    DataLayout.Get(ImportConfigHeader."Data Layout ID");
                    DataLayoutLine.SetRange("Data Layout ID", DataLayout.ID);
                    DataLayoutLine.CopyToTemp(TempDataLayoutLine);
                    Rec.Copy(TempDataLayoutLine, true);
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