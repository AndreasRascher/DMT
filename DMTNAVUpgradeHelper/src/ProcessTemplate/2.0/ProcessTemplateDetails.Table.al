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

        field(3; "Type"; Option)
        {
            Caption = 'Type', Comment = 'de-DE=Art';
            OptionMembers = Requirement,Step;
        }
        #region Requirement
        field(10; "Requirement Sub Type"; Option)
        {
            Caption = 'Requirement Type', Comment = 'de-DE=Anforderungstyp';
            OptionMembers = " ",SourceFile,"Table","Codeunit";
            OptionCaption = ' ,SourceFile,Table,Codeunit',
                  Comment = 'de-DE= ,Quelldatei,Tabelle,Codeunit';
        }
        field(11; "Name"; Text[250])
        {
            Caption = 'Name', Comment = 'de-DE=Name';
        }
        field(12; "Object Type (Req.)"; Option)
        {
            OptionMembers = Table,Codeunit;
            Caption = 'Object Type (Req.)', Comment = 'de-DE=Objektart (Vorraussetzung)';
            OptionCaption = 'Table,Codeunit', Comment = 'de-DE=Tabelle,Codeunit';
        }
        field(13; "Object ID (Req.)"; Integer)
        {
            Caption = 'Object ID (Req.)', Comment = 'de-DE=Objekt ID (Vorraussetzung)';
            TableRelation = if ("Object Type (Req.)" = const(Table)) AllObjWithCaption."Object ID" where("Object Type" = const(Table)) else
            if ("Object Type (Req.)" = const(Codeunit)) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit));
            trigger OnValidate()
            var
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                Rec.Name := '';
                if (Rec."Object Type (Req.)" = Rec."Object Type (Req.)"::Codeunit) then
                    if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Codeunit, Rec."Object ID (Req.)") then
                        Rec.Name := AllObjWithCaption."Object Caption";

                if Rec."Object Type (Req.)" = Rec."Object Type (Req.)"::Table then
                    if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Object ID (Req.)") then
                        Rec.Name := AllObjWithCaption."Object Caption"
            end;
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
        field(21; "PrPl Indentation"; Integer) { Caption = 'Processing Plan Indentation', Comment = 'de-DE=Verarbeitungsplan Einrückung'; Editable = false; }
        field(30; "PrPl Filter Field 1"; Text[30]) { Caption = 'Filter Field 1', Comment = 'de-DE=Filterfeld 1'; Editable = false; }
        field(31; "PrPl Filter Value 1"; Text[250]) { Caption = 'Filter Value 1', Comment = 'de-DE=Filterwert 1'; Editable = false; }
        field(32; "PrPl Filter Field 2"; Text[30]) { Caption = 'Filter Field 2', Comment = 'de-DE=Filterfeld 2'; Editable = false; }
        field(33; "PrPl Filter Value 2"; Text[250]) { Caption = 'Filter Value 2', Comment = 'de-DE=Filterwert 2'; Editable = false; }
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