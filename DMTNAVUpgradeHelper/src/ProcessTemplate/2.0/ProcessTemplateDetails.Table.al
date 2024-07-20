table 90013 DMTProcessTemplateDetail
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; "Process Template Code"; Code[150])
        {
            Caption = 'Process Template Code', Comment = 'de-DE=Prozessvorlage Code';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'de-DE=Zeilennummer';
        }
        #region Requirement
        field(10; Type; Option)
        {
            Caption = 'Type', Comment = 'de-DE=Art';
            OptionMembers = " ",SourceFile,"Table","Codeunit";
            OptionCaption = ' ,SourceFile,Table,Codeunit',
                  Comment = 'de-DE= ,Quelldatei,Tabelle,Codeunit';
        }
        field(11; "Name"; Text[250])
        {
            Caption = 'Name', Comment = 'de-DE=Name';
        }
        field(15; "NAV Source Table No.(Req.)"; Integer)
        {
            Caption = 'NAV Source Table No.(Req.)', Comment = 'de-DE=NAV Quelltabelle Nr.(Vorraussetzung)';
        }
        #endregion Requirement
        #region Step
        field(20; "PrPl Type"; Enum DMTProcessingPlanType)
        {
            Caption = 'Processing Plan Type', Comment = 'de-DE=Verarbeitungsplan Art';
        }
        #endregion Step
    }

    keys
    {
        key(PK; "Process Template Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    internal procedure getNextLineNo() nextLineNo: Integer
    var
        processTemplateDetails: Record DMTProcessTemplateDetail;
        tempProcessTemplateDetails: Record DMTProcessTemplateDetail temporary;
    begin
        if Rec.IsTemporary then begin
            tempProcessTemplateDetails.Copy(Rec, true);
            if tempProcessTemplateDetails.FindLast() then;
            nextLineNo := tempProcessTemplateDetails."Line No." + 10000;
        end else begin
            processTemplateDetails.Copy(Rec);
            if processTemplateDetails.FindLast() then;
            nextLineNo := processTemplateDetails."Line No." + 10000;
        end;
    end;

    internal procedure InsertNew(templateCode: Code[150])
    var
        processTemplateDetailNEW: Record DMTProcessTemplateDetail;
    begin
        processTemplateDetailNEW."Process Template Code" := templateCode;
        processTemplateDetailNEW."Line No." := Rec.getNextLineNo();
        Rec := processTemplateDetailNEW;
        Rec.Insert();
    end;

}