table 91007 DMTBlobStorage
{
    Access = Internal;
    fields
    {
        field(1; "Primary Key"; BigInteger) { DataClassification = SystemMetadata; }
        field(2; Blob; BLOB) { DataClassification = CustomerContent; }
        field(100; "Gen. Buffer Table Entry No."; Integer) { }
        field(101; "Import from Filename"; Text[250]) { }
        field(102; "Imp.Conf.Header ID"; Integer) { TableRelation = DMTImportConfigHeader; }
        field(103; "Source Field No."; Integer) { Caption = 'Source Field No.', Comment = 'de-DE=Herkunftsfeld Nr.'; }
        field(104; "Source Field Caption"; Text[80]) { Caption = 'Source Field Caption', Comment = 'de-DE=Herkunftsfeld Bezeichnung'; Editable = false; }

    }

    keys
    {
        key(Key1; "Primary Key") { Clustered = true; }
    }

    fieldgroups
    {
    }

    procedure filterBy(genBuffTable: Record DMTGenBuffTable) HasLines: Boolean
    begin
        Rec.SetRange("Gen. Buffer Table Entry No.", genBuffTable."Entry No.");
        HasLines := not Rec.IsEmpty;
    end;

    procedure ReadFromGenBuffTable(var genBuffTable: Record DMTGenBuffTable)
    begin
        Rec."Gen. Buffer Table Entry No." := genBuffTable."Entry No.";
        Rec."Import from Filename" := genBuffTable."Import from Filename";
        Rec."Imp.Conf.Header ID" := genBuffTable."Imp.Conf.Header ID";
    end;

    procedure ReadFromImportConfigLine(var importConfigLine: Record DMTImportConfigLine)
    begin
        Rec."Imp.Conf.Header ID" := importConfigLine."Imp.Conf.Header ID";
        Rec."Source Field No." := importConfigLine."Source Field No.";
        Rec."Source Field Caption" := importConfigLine."Source Field Caption";
    end;

    procedure SaveFieldValue(genBuffTable: Record DMTGenBuffTable; importConfigLine: Record DMTImportConfigLine; base64FieldContent: Text)
    var
        blobStorage: Record DMTBlobStorage;
        base64Convert: Codeunit "Base64 Convert";
        OStream: OutStream;
    begin
        if base64FieldContent = '' then exit;
        blobStorage."Primary Key" := GetNextEntryNo();
        blobStorage.ReadFromGenBuffTable(genBuffTable);
        blobStorage.ReadFromImportConfigLine(importConfigLine);
        blobStorage.Blob.CreateOutStream(OStream);
        base64Convert.FromBase64(base64FieldContent, OStream);
        blobStorage.Insert();
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
}

