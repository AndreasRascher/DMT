table 91004 DMTSourceFileStorage
{
    LookupPageId = 91005;
    Caption = 'DMT Source File', Comment = 'de-DE=DMT Quelldatei';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "File ID"; Integer) { }
        field(10; "File Blob"; Blob) { }
        field(100; Name; Text[99]) { Caption = 'Name', Comment = 'de-DE=Name'; Editable = false; }
        field(101; Extension; Text[10]) { Caption = 'Extension', Comment = 'de-DE=Dateiendung'; Editable = false; }
        field(102; Size; Integer) { Caption = 'Size', Comment = 'de-DE=Größe'; Editable = false; }
        field(103; UploadDateTime; DateTime) { Caption = 'Uploaded at', Comment = 'de-DE=Hochgeladen am'; Editable = false; }
    }
    keys
    {
        key(PK; "File ID") { Clustered = true; }
    }

    procedure GetFileAsTempBlob(var tempBlob: Codeunit "Temp Blob")
    begin
        Clear(tempBlob);
        tempBlob.FromRecord(Rec, Rec.FieldNo("File Blob"));
    end;

    local procedure ConfirmDeleteIfSourceFileIsAssigned(Rec: Record DMTSourceFileStorage)
    var
        DMTImportConfigHeader: Record DMTImportConfigHeader;
        DeleteSourceFileQst: Label 'The source file %1 "%2" is currently assigned in import configurations. Continue?', Comment = 'de-DE=Die Quelldatei %1 "%2" ist Importkonfigurationen zugewiesen. Mit dem Löschen fortfahren?';
        ProcessCanceldErr: Label 'Process Canceled', Comment = 'de-DE=Vorgang abgebrochen';
    begin
        DMTImportConfigHeader.SetRange("Source File ID", rec."File ID");
        if not DMTImportConfigHeader.IsEmpty then
            if not Confirm(StrSubstNo(DeleteSourceFileQst, Rec."File ID", Rec.Name)) then begin
                Error(ProcessCanceldErr);
            end else begin
                // remove references
                DMTImportConfigHeader.Reset();
                DMTImportConfigHeader.SetRange("Source File ID", rec."File ID");
                DMTImportConfigHeader.ModifyAll("Source File ID", 0, false);
            end;

    end;

    trigger OnDelete()
    begin
        ConfirmDeleteIfSourceFileIsAssigned(Rec);
    end;
}