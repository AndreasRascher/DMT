page 91012 DMTFieldLookup
{
    Caption = 'Fields', comment = 'Felder';
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
    // DataFile: Record DMTDataFile;
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
                end;
            else
                Error('unhandled case');
        end;
        Rec.FilterGroup(0);


        // case DataFile.BufferTableType of
        //     DataFile.BufferTableType::"Generic Buffer Table for all Files":
        //         begin
        //             GenBuffTable.GetColCaptionForImportedFile(DataFile, BuffTableCaptions);
        //             foreach FieldNo in BuffTableCaptions.Keys do begin
        //                 TempFieldBuffer.TableNo := GenBuffTable.RecordId.TableNo;
        //                 TempFieldBuffer."No." := FieldNo + 1000;
        //                 TempFieldBuffer."Field Caption" := CopyStr(BuffTableCaptions.Get(FieldNo), 1, MaxStrLen(TempFieldBuffer."Field Caption"));
        //                 TempFieldBuffer.Insert();
        //             end;
        //             IsLoaded := true;
        //         end;

        //     DataFile.BufferTableType::"Seperate Buffer Table per CSV":
        //         begin
        //             Field.SetRange(TableNo, DataFile."Buffer Table ID");
        //             Field.SetFilter("No.", '<2000000000'); // no system fields
        //             Field.FindSet(false, false);
        //             repeat
        //                 TempFieldBuffer.ReadFrom(Field);
        //                 TempFieldBuffer.Insert(false);
        //             until Field.Next() = 0;
        //             IsLoaded := true;
        //         end;
        // end;

        // Rec.Copy(TempFieldBuffer, true);
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
}