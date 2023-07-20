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
                    ApplyFieldIdOffsetInGenBuffTableTo(TempDataLayoutLine);
                    IsLoaded := true;
                end;
            else
                Error('unhandled case');
        end;
        Rec.FilterGroup(0);
    end;

    /// <summary>
    /// Field IDs in Gen. Buffer Table start from 1000
    /// </summary>
    /// <param name="TempDataLayoutLine"></param>
    local procedure ApplyFieldIdOffsetInGenBuffTableTo(var TempDataLayoutLine: Record DMTDataLayoutLine temporary)
    var
        GenBufferFieldNoOffSet: Integer;
    begin
        GenBufferFieldNoOffSet := 1000;
        TempDataLayoutLine."Column No." += GenBufferFieldNoOffSet;
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
}