table 90013 DMTProcessTemplateDetail
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Process Template Code"; Code[150])
        {
            Caption = 'Process Template Code', Comment = 'de-DE=Prozessvorlage Code';
            TableRelation = DMTProcessTemplate;
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

    procedure filterFor(DMTProcessTemplate: Record DMTProcessTemplate) HasLinesInFilter: Boolean
    begin
        Rec.SetRange(Rec."Process Template Code", DMTProcessTemplate.Code);
        HasLinesInFilter := not Rec.IsEmpty;
    end;

    internal procedure getNextLineNo() nextLineNo: Integer
    var
        DMTProcessTemplateDetails: Record DMTProcessTemplateDetail;
    begin
        Rec.TestField("Process Template Code");
        DMTProcessTemplateDetails.SetRange("Process Template Code", Rec."Process Template Code");
        if DMTProcessTemplateDetails.FindLast() then;
        nextLineNo := DMTProcessTemplateDetails."Line No." + 10000;
    end;
}