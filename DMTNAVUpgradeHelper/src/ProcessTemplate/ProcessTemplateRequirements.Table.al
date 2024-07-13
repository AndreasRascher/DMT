table 90013 DMTProcessTemplateDetails
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
            OptionMembers = " ",SourceFile,MigrationTable,MigrationCodeunit;
            OptionCaption = ' ,SourceFile,MigrationTable,MigrationCodeunit',
                  Comment = 'de-DE= ,Quelldatei,Migrations-Tabelle,Migrations-Codeunit';
        }
        field(11; "Req. Src.Filename"; Text[250])
        {
            Caption = 'Source File Name', Comment = 'de-DE=Quelldateiname (Vorraussetzung)';
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
                Rec."Object Name (Req.)" := '';
                if (Rec."Object Type (Req.)" = Rec."Object Type (Req.)"::Codeunit) then
                    if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Codeunit, Rec."Object ID (Req.)") then
                        Rec."Object Name (Req.)" := AllObjWithCaption."Object Caption";

                if Rec."Object Type (Req.)" = Rec."Object Type (Req.)"::Table then
                    if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Object ID (Req.)") then
                        Rec."Object Name (Req.)" := AllObjWithCaption."Object Caption"
            end;
        }
        field(14; "Object Name (Req.)"; Text[249])
        {
            Caption = 'Object Name (Req.)', Comment = 'de-DE=Objektname (Vorraussetzung)';
        }
        field(15; "NAV Source Table No.(Req.)"; Integer)
        {
            Caption = 'NAV Source Table No.(Req.)', Comment = 'de-DE=NAV Quelltabelle Nr.(Vorraussetzung)';
        }
        #endregion Requirement
        #region Step
        field(20; "Step Type"; Option)
        {
            Caption = 'Step Type', Comment = 'de-DE=Schritt Typ';
            OptionMembers = ,MigrationTable,MigrationCodeunit;
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

    procedure filterFor(DMTProcessTemplate: Record DMTProcessTemplate) HasLinesInFilter: Boolean
    begin
        Rec.SetRange(Rec."Process Template Code", DMTProcessTemplate.Code);
        HasLinesInFilter := not Rec.IsEmpty;
    end;

    internal procedure getNextLineNo() nextLineNo: Integer
    var
        DMTProcessTemplateDetails: Record DMTProcessTemplateDetails;
    begin
        Rec.TestField("Process Template Code");
        DMTProcessTemplateDetails.SetRange("Process Template Code", Rec."Process Template Code");
        if DMTProcessTemplateDetails.FindLast() then;
        nextLineNo := DMTProcessTemplateDetails."Line No." + 10000;
    end;
}