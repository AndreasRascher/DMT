codeunit 91022 DMTSeparateBufferTableMgtImpl implements IBufferTableMgt
{
    procedure setImportConfigHeader(var ImportConfigHeader: record DMTImportConfigHeader);
    begin
        ImportConfigHeaderGlobal.Copy(ImportConfigHeader);
    end;

    procedure checkHeaderIsSet();
    begin
        ImportConfigHeaderGlobal.TestField(ID);
    end;

    procedure InitBufferRef(var BufferRef: RecordRef);
    var
        TableMetadata: Record "Table Metadata";
        BufferTableMissingErr: Label 'Buffer Table %1 not found', Comment = 'de-DE=Eine Puffertabelle mit der ID %1 wurde nicht gefunden.';
    begin
        checkHeaderIsSet();
        if not TableMetadata.Get(ImportConfigHeaderGlobal."Buffer Table ID") then
            Error(BufferTableMissingErr, ImportConfigHeaderGlobal."Buffer Table ID");
        BufferRef.Open(ImportConfigHeaderGlobal."Buffer Table ID");
    end;

    procedure InitBufferRef(var BufferRef: RecordRef; HideGenBufferFilters: Boolean);
    begin
        InitBufferRef(BufferRef);
    end;


    internal procedure LoadImportConfigLines(var tempImportConfigLine: Record DMTImportConfigLine temporary) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
    begin
        checkHeaderIsSet();
        importConfigHeaderGlobal.FilterRelated(importConfigLine);
        importConfigLine.SetFilter("Processing Action", '<>%1', importConfigLine."Processing Action"::Ignore);
        importConfigLine.SetFilter("Source Field No.", '<>0');
        importConfigLine.CopyToTemp(tempImportConfigLine);
        OK := tempImportConfigLine.FindFirst();
    end;

    procedure CheckBufferTableIsNotEmpty()
    var
        bufferRef: RecordRef;
        bufferTableEmptyErr: Label 'The buffer table is empty. Filename: "%1"', Comment = 'de-DE=Die Puffertable entält keine Zeilen. Dateiname: "%1"';
    begin
        checkHeaderIsSet();
        InitBufferRef(bufferRef);
        if bufferRef.IsEmpty then
            Error(bufferTableEmptyErr, ImportConfigHeaderGlobal."Source File Name");
    end;

    procedure ReadBufferTableColumnCaptions(var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    var
        field: Record field;
    begin
        checkHeaderIsSet();
        ImportConfigHeaderGlobal.TestField("Target Table ID");
        field.SetRange(TableNo, ImportConfigHeaderGlobal."Target Table ID");
        field.SetFilter("No.", '<2000000000'); // exclude system fields
        field.SetRange(Enabled, true);
        field.SetRange(Class, Field.Class::Normal);
        if field.FindSet(false) then
            repeat
                BuffTableCaptions.Add(field."No.", field."Field Caption");
            until field.Next() = 0;
    end;

    procedure CountRecordsInBufferTable() NoOfRecords: Integer;
    var
        recRef: RecordRef;
    begin
        InitBufferRef(recRef);
        NoOfRecords := recRef.Count;
    end;

    internal procedure ShowBufferTable() OK: Boolean
    begin
        OK := ImportConfigHeaderGlobal.ShowTableContent(ImportConfigHeaderGlobal."Buffer Table ID");
    end;

    var
        ImportConfigHeaderGlobal: record DMTImportConfigHeader;

    procedure DeleteAllBufferData();
    var
        TableMetadata: Record "Table Metadata";
        bufferRef: RecordRef;
    begin
        if ImportConfigHeaderGlobal."Buffer Table ID" = 0 then
            exit;
        if not TableMetadata.Get(ImportConfigHeaderGlobal."Buffer Table ID") then
            exit;
        InitBufferRef(bufferRef);
        bufferRef.DeleteAll();
    end;

    procedure SetDMTImportFields(var BufferRef: RecordRef; CurrTargetRecIDText: Text)
    var
        TargetRecID: RecordId;
        targetRef: RecordRef;
        TargetRecIDFieldNo, TargetRecIsImportedFieldNo : Integer;
    begin
        checkHeaderIsSet();
        if not FindDMTFieldNosInBufferTable(TargetRecIDFieldNo, TargetRecIsImportedFieldNo) then
            exit;
        if Evaluate(TargetRecID, CurrTargetRecIDText) then begin
            BufferRef.Field(TargetRecIDFieldNo).Value := TargetRecID;
            BufferRef.Field(TargetRecIsImportedFieldNo).Value := targetRef.Get(TargetRecID);
        end else begin
            BufferRef.Field(TargetRecIDFieldNo).Value := TargetRecID;
            BufferRef.Field(TargetRecIsImportedFieldNo).Value := false;
        end;
        BufferRef.Modify();
    end;

    procedure FindDMTFieldNosInBufferTable(var TargetRecIDFieldNo: Integer; var TargetRecIsImportedFieldNo: Integer) Found: Boolean
    var
        bufferFields: Record Field;
    begin
        Clear(TargetRecIDFieldNo);
        Clear(TargetRecIsImportedFieldNo);
        checkHeaderIsSet();

        bufferFields.SetRange(TableNo, ImportConfigHeaderGlobal."Buffer Table ID");
        bufferFields.SetRange(FieldName, 'DMT RecId (Imported)');
        if bufferFields.FindFirst() then
            TargetRecIDFieldNo := bufferFields."No.";

        bufferFields.SetRange(FieldName, 'DMT Imported');
        if bufferFields.FindFirst() then
            TargetRecIsImportedFieldNo := bufferFields."No.";

        Found := (TargetRecIDFieldNo <> 0) and (TargetRecIsImportedFieldNo <> 0);
    end;

    internal procedure updateImportToTargetPercentage()
    var
        bufferRef, TargetRef : RecordRef;
        noOfRecords, noOfRecordsMigrated : Integer;
        TargetRecIDFieldNo, TargetRecIsImportedFieldNo : Integer;
        IsImported, IsImportedOld : Boolean;
        emptyRecID: RecordId;
    begin
        ImportConfigHeaderGlobal.get(ImportConfigHeaderGlobal.RecordId); // update
        InitBufferRef(bufferRef);
        if bufferRef.IsEmpty then begin
            Clear(ImportConfigHeaderGlobal.ImportToTargetPercentage);
            Clear(ImportConfigHeaderGlobal.ImportToTargetPercentage);
            ImportConfigHeaderGlobal.Modify();
            exit;
        end;
        if not FindDMTFieldNosInBufferTable(TargetRecIDFieldNo, TargetRecIsImportedFieldNo) then
            exit;

        bufferRef.AddLoadFields(TargetRecIDFieldNo);
        bufferRef.AddLoadFields(TargetRecIsImportedFieldNo);

        bufferRef.FindSet();
        repeat
            noOfRecords += 1;
            IsImported := TargetRef.Get(bufferRef.Field(TargetRecIDFieldNo).Value);
            IsImportedOld := bufferRef.Field(TargetRecIsImportedFieldNo).Value;

            if IsImported then
                noOfRecordsMigrated += 1;

            if IsImported <> IsImportedOld then begin
                bufferRef.Field(TargetRecIsImportedFieldNo).Value := IsImported;
                if not IsImported then
                    bufferRef.Field(TargetRecIDFieldNo).Value := emptyRecID;
                bufferRef.Modify();
            end;
        until bufferRef.Next() = 0;

        ImportConfigHeaderGlobal.ImportToTargetPercentage := (noOfRecordsMigrated / noOfRecords) * 100;
        case ImportConfigHeaderGlobal.ImportToTargetPercentage of
            100:
                ImportConfigHeaderGlobal.ImportToTargetPercentageStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            0:
                ImportConfigHeaderGlobal.ImportToTargetPercentageStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            else
                ImportConfigHeaderGlobal.ImportToTargetPercentageStyle := Format(Enum::DMTFieldStyle::Yellow);
        end;
        ImportConfigHeaderGlobal.Modify();
    end;

}