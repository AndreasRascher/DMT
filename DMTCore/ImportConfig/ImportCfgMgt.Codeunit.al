codeunit 91002 ImportCfgMgt
{
    procedure ImportNAVSchemaFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FieldImport: XmlPort "DMT NAVFieldBufferImport";
        InStr: InStream;
        ImportFinishedMsg: Label 'Import finished', comment = 'de-DE=Import abgeschlossen';
        FileName: Text;
    begin
        TempBlob.CreateInStream(InStr);
        if not UploadIntoStream('Select a Schema.csv file', '', Format(Enum::DMTFileFilter::CSV), FileName, InStr) then begin
            exit;
        end;
        FieldImport.SetSource(InStr);
        FieldImport.Import();

        migrateNAVSchemaToDataLayout();

        Message(ImportFinishedMsg);
    end;

    local procedure migrateNAVSchemaToDataLayout()
    var
        dataLayout: Record DMTDataLayout;
        dataLayoutLine: Record DMTDataLayoutLine;
        NAVFieldBuffer: Record "DMT NAVFieldBuffer";
        TableIDs: List of [Integer];
        TableID: Integer;
    begin
        if NAVFieldBuffer.IsEmpty then exit;
        while NAVFieldBuffer.Findfirst() do begin
            TableIDs.Add(NAVFieldBuffer.TableNo);
            NAVFieldBuffer.SetFilter(TableNo, StrSubstNo('>%1', NAVFieldBuffer.TableNo));
        end;
        foreach TableID in TableIDs do begin
            // delete old
            dataLayout.SetRange(NAVTableID, TableID);
            if not dataLayout.IsEmpty then
                dataLayout.Delete(true);
            // load fields
            NAVFieldBuffer.Reset();
            NAVFieldBuffer.FindSet(false);
            NAVFieldBuffer.SetRange(TableNo, TableID);
            NAVFieldBuffer.FindSet();
            // add header
            Clear(dataLayout);
            dataLayout.Name := NAVFieldBuffer.TableName;
            dataLayout.NAVTableID := NAVFieldBuffer.TableNo;
            dataLayout.SourceFileFormat := dataLayout.SourceFileFormat::"NAV CSV Export";
            dataLayout.Insert(true);
            repeat
                Clear(dataLayoutLine);

                dataLayoutLine."Data Layout ID" := dataLayout.ID;
                dataLayoutLine."Column No." := NAVFieldBuffer."No.";
                dataLayoutLine.ColumnName := NAVFieldBuffer.FieldName;
                dataLayoutLine.NAVFieldCaption := NAVFieldBuffer."Field Caption";
                dataLayoutLine."NAV Primary Key" := NAVFieldBuffer."Primary Key";
                dataLayoutLine."NAV Table Caption" := NAVFieldBuffer."Table Caption";
                dataLayoutLine.NAVClass := NAVFieldBuffer.Class;
                dataLayoutLine.NAVDataType := NAVFieldBuffer.Type;
                dataLayoutLine.NAVEnabled := NAVFieldBuffer.Enabled;
                dataLayoutLine.NAVLen := NAVFieldBuffer.Len;

                dataLayoutLine.Insert(true);
            until NAVFieldBuffer.Next() = 0;
        end;
    end;
}