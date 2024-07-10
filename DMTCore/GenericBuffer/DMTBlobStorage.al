table 50147 DMTBlobStorage
{
    Access = Internal;
    fields
    {
        field(1; "Primary Key"; BigInteger) { Caption = 'Primary Key', Locked = true; DataClassification = SystemMetadata; }
        field(2; Blob; BLOB) { Caption = 'Blob', locked = true; DataClassification = CustomerContent; }
        field(100; "Gen. Buffer Table Entry No."; Integer) { Caption = 'Gen. Buffer Table Entry No.', locked = true; }
        field(101; "Import from Filename"; Text[250]) { Caption = 'Import from Filename', locked = true; }
        field(102; "Imp.Conf.Header ID"; Integer) { Caption = 'Imp.Conf.Header ID', Comment = 'de-DE=Import Konfig. Kopf ID'; TableRelation = DMTImportConfigHeader; }
        field(103; "Source Field No."; Integer) { Caption = 'Source Field No.', Comment = 'de-DE=Herkunftsfeld Nr.'; }
        field(104; "Source Field Caption"; Text[80]) { Caption = 'Source Field Caption', Comment = 'de-DE=Herkunftsfeld Bezeichnung'; Editable = false; }

    }

    keys
    {
        key(Key1; "Primary Key") { Clustered = true; }
    }

    fieldgroups { }

    procedure filterBy(genBuffTable: Record DMTGenBuffTable) HasLines: Boolean
    begin
        Rec.SetRange("Gen. Buffer Table Entry No.", genBuffTable."Entry No.");
        HasLines := not Rec.IsEmpty;
    end;

    procedure filterBy(importConfigHeader: Record DMTImportConfigHeader) HasLines: Boolean
    begin
        Rec.SetRange("Imp.Conf.Header ID", importConfigHeader.ID);
        HasLines := not Rec.IsEmpty;
    end;

    procedure ReadFromGenBuffTable(var genBuffTable: Record DMTGenBuffTable)
    begin
        Rec."Gen. Buffer Table Entry No." := genBuffTable."Entry No.";
        Rec."Import from Filename" := genBuffTable."Import from Filename";
        Rec."Imp.Conf.Header ID" := genBuffTable."Imp.Conf.Header ID";
    end;

    procedure SaveFieldValue(genBuffTable: Record DMTGenBuffTable; ColumnIndex: Integer; ColumnCaption: Text; base64FieldContent: Text)
    var
        blobStorage: Record DMTBlobStorage;
        base64Convert: Codeunit "Base64 Convert";
        base64decoded: text;
        OStream: OutStream;
    begin
        if base64FieldContent = '' then exit;
        blobStorage."Primary Key" := GetNextEntryNo();
        blobStorage.ReadFromGenBuffTable(genBuffTable);
        blobStorage."Source Field Caption" := CopyStr(ColumnCaption, 1, MaxStrLen("Source Field Caption"));
        blobStorage."Source Field No." := 1000 + ColumnIndex;
        Clear(blobStorage.Blob);
        blobStorage.Blob.CreateOutStream(OStream);
        base64decoded := base64Convert.FromBase64(base64FieldContent);
        OStream.Write(base64decoded);
        blobStorage.Insert();
        blobStorage.CalcFields(Blob);
    end;

    procedure SaveFieldValue(genBuffTable: Record DMTGenBuffTable; ColumnIndex: Integer; ColumnCaption: Text; fieldContent: BigText)
    var
        blobStorage: Record DMTBlobStorage;
        // base64Convert: Codeunit "Base64 Convert";
        // base64decoded: text;
        OStream: OutStream;
    // first, last : Text;
    // JObj: JsonObject;
    begin
        if fieldContent.Length = 0 then exit;
        blobStorage."Primary Key" := GetNextEntryNo();
        blobStorage.ReadFromGenBuffTable(genBuffTable);
        blobStorage."Source Field Caption" := CopyStr(ColumnCaption, 1, MaxStrLen("Source Field Caption"));
        blobStorage."Source Field No." := 1000 + ColumnIndex;
        Clear(blobStorage.Blob);
        blobStorage.Blob.CreateOutStream(OStream);
        // // test for JSON
        // base64FieldContent.GetSubText(first, 1, 1);
        // base64FieldContent.GetSubText(last, base64FieldContent.Length, 1);
        // if (first = '{') and (last = '}') then begin
        //     OStream.Write(base64decoded);
        //     blobStorage.Insert();
        //     blobStorage.CalcFields(Blob);
        // end else begin
        // base64decoded := base64Convert.FromBase64(format(base64FieldContent));
        fieldContent.Write(OStream);
        blobStorage.Insert();
        blobStorage.CalcFields(Blob);
        // end;
    end;

    internal procedure GetNextEntryNo() NextEntryNo: Integer
    var
        BlobStorage: Record DMTBlobStorage;
    begin
        NextEntryNo := 1;
        BlobStorage.Reset();
        BlobStorage.SetLoadFields("Primary Key");
        if BlobStorage.FindLast() then begin
            NextEntryNo += BlobStorage."Primary Key";
        end;
    end;

    internal procedure getContentAsText() Content: Text
    var
        IStream: InStream;
    begin
        Rec.CalcFields(Blob);
        if not rec.Blob.HasValue then exit('');
        Rec.Blob.CreateInStream(IStream);
        IStream.ReadText(Content);
    end;
}

