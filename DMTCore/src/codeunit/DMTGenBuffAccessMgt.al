codeunit 91023 DMTGenBuffAccessMgt
{
    internal procedure InitImportToGenBuffer(importConfigHeader: Record DMTImportConfigHeader)
    begin
        HeadLineRowNoGlobal := importConfigHeader.GetDataLayout().HeadingRowNo;
        ImportConfigHeaderIDGlobal := importConfigHeader.ID;
        ImportFromFileNameGlobal := importConfigHeader."Source File Name";
    end;

    internal procedure ImportLine(currLine: List of [Text]; currRowNo: Integer);
    var
        genBuffTable: Record DMTGenBuffTable;
        blobStorage: Record DMTBlobStorage;
        RecRef: RecordRef;
        IsColumnCaptionLine: Boolean;
        CurrColIndex: Integer;
        cellValue: Text;
    begin
        IsColumnCaptionLine := (HeadLineRowNoGlobal = currRowNo);
        if NextEntryNoGlobal = 0 then
            NextEntryNoGlobal := genBuffTable.GetNextEntryNo()
        else
            NextEntryNoGlobal += 1;

        genBuffTable.Init();
        genBuffTable."Entry No." := NextEntryNoGlobal;
        genBuffTable.IsCaptionLine := IsColumnCaptionLine;
        genBuffTable."Import from Filename" := ImportFromFileNameGlobal;
        genBuffTable."Imp.Conf.Header ID" := ImportConfigHeaderIDGlobal;
        genBuffTable.CalcFields("No. of Blob Contents");
        RecRef.GetTable(genBuffTable);

        foreach cellValue in currLine do begin
            CurrColIndex += 1;

            if IsColumnCaptionLine then begin
                ColCaptionsGlobal.add(CurrColIndex, cellValue);
                if cellValue.EndsWith('[Base64]') or cellValue.EndsWith('[BlobText]') then
                    Base64FieldIDListGlobal.Add(CurrColIndex, cellValue);
            end;
            if not IsColumnCaptionLine then
                if not Base64FieldIDListGlobal.ContainsKey(CurrColIndex) then
                    if Strlen(cellValue) > 250 then
                        LargeTextColCaptionGlobal.Set(CurrColIndex, ColCaptionsGlobal.Get(CurrColIndex));
            case true of
                not IsColumnCaptionLine and Base64FieldIDListGlobal.ContainsKey(CurrColIndex):
                    blobStorage.SaveFieldValue(genBuffTable, CurrColIndex, ColCaptionsGlobal.Get(CurrColIndex), cellValue);
                else begin
                    RecRef.Field(1000 + CurrColIndex).Value := CopyStr(cellValue, 1, 250);
                end;
            end;

        end;
        RecRef.SetTable(genBuffTable);
        genBuffTable."Column Count" := CurrColIndex;
        genBuffTable.Insert();
    end;

    internal procedure ImportLine(currLine: List of [BigText]; currRowNo: Integer);
    var
        blobStorage: Record DMTBlobStorage;
        genBuffTable: Record DMTGenBuffTable;
        cellValueBT: BigText;
        RecRef: RecordRef;
        IsColumnCaptionLine: Boolean;
        CurrColIndex: Integer;
    begin
        IsColumnCaptionLine := (HeadLineRowNoGlobal = currRowNo);
        if NextEntryNoGlobal = 0 then
            NextEntryNoGlobal := genBuffTable.GetNextEntryNo()
        else
            NextEntryNoGlobal += 1;

        genBuffTable.Init();
        genBuffTable."Entry No." := NextEntryNoGlobal;
        genBuffTable.IsCaptionLine := IsColumnCaptionLine;
        genBuffTable."Import from Filename" := ImportFromFileNameGlobal;
        genBuffTable."Imp.Conf.Header ID" := ImportConfigHeaderIDGlobal;
        genBuffTable.CalcFields("No. of Blob Contents");
        RecRef.GetTable(genBuffTable);

        foreach cellValueBT in currLine do begin
            CurrColIndex += 1;

            if IsColumnCaptionLine then begin
                ColCaptionsGlobal.add(CurrColIndex, format(cellValueBT));
                if format(cellValueBT).EndsWith('[Base64]') or format(cellValueBT).EndsWith('[BlobText]') then
                    Base64FieldIDListGlobal.Add(CurrColIndex, format(cellValueBT));
            end;
            if not IsColumnCaptionLine then
                if not Base64FieldIDListGlobal.ContainsKey(CurrColIndex) then
                    if cellValueBT.Length > 250 then
                        LargeTextColCaptionGlobal.Set(CurrColIndex, ColCaptionsGlobal.Get(CurrColIndex));
            case true of
                not IsColumnCaptionLine and Base64FieldIDListGlobal.ContainsKey(CurrColIndex):
                    blobStorage.SaveFieldValue(genBuffTable, CurrColIndex, ColCaptionsGlobal.Get(CurrColIndex), cellValueBT);
                else begin
                    RecRef.Field(1000 + CurrColIndex).Value := CopyStr(format(cellValueBT), 1, 250);
                end;
            end;

        end;
        RecRef.SetTable(genBuffTable);
        genBuffTable."Column Count" := CurrColIndex;
        genBuffTable.Insert();
    end;

    procedure LargeTextColCaptions(): Dictionary of [Integer, Text];
    begin
        exit(LargeTextColCaptionGlobal);
    end;

    var
        HeadLineRowNoGlobal, NextEntryNoGlobal, ImportConfigHeaderIDGlobal : Integer;
        ColCaptionsGlobal: Dictionary of [Integer, Text];
        LargeTextColCaptionGlobal: Dictionary of [Integer, Text];
        ImportFromFileNameGlobal: Text[250];
        Base64FieldIDListGlobal: Dictionary of [Integer, Text];
}