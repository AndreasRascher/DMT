table 90014 DMTProcessTemplateSetup
{
    fields
    {
        field(1; "Template Code"; Code[150]) { Caption = 'Template Code', Comment = 'de-DE=Vorlagencode'; }
        field(2; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennummer'; }
        #region SourceInfo
        field(10; "NAV Source Table No."; Integer) { Caption = 'NAV Source Table No.', Comment = 'de-DE=NAV Quelltabelle Nr.'; BlankZero = true; }
        field(11; "Source File Name"; Text[250]) { Caption = 'Source File Name', Comment = 'de-DE=Quelldatei Name'; }
        #endregion SourceInfo
        #region ProcessingPlan
        field(20; "PrPl Type"; Enum DMTProcessingPlanType) { Caption = 'Type (Processing Plan)', Comment = 'de-DE=Art (Verarbeitungsplan)'; }
        field(21; "PrPl Indentation"; Integer) { Caption = 'Indentation (Processing Plan)', Comment = 'de-DE=Einrückung (Verarbeitungsplan)'; Editable = false; }
        field(22; "PrPl Description"; Text[250]) { Caption = 'Description (Processing Plan)', Comment = 'de-DE=Beschreibung (Verarbeitungsplan)'; }
        field(23; "PrPl Run Codeunit"; Integer) { Caption = 'Run Codeunit ID (Processing Plan)', Comment = 'de-DE=Codeunit ID ausführen (Verarbeitungsplan)'; BlankZero = true; }
        field(24; "PrPl Default Target Table ID"; Integer) { Caption = 'Default Target Table ID', Comment = 'de-DE=Vorgabe Zieltabelle ID'; BlankZero = true; }
        field(30; "PrPl Filter Field 1"; Text[30]) { Caption = 'Filter Field 1', Comment = 'de-DE=Filterfeld 1'; Editable = false; }
        field(31; "PrPl Filter Value 1"; Text[250]) { Caption = 'Filter Value 1', Comment = 'de-DE=Filterwert 1'; Editable = false; }
        field(32; "PrPl Filter Field 2"; Text[30]) { Caption = 'Filter Field 2', Comment = 'de-DE=Filterfeld 2'; Editable = false; }
        field(33; "PrPl Filter Value 2"; Text[250]) { Caption = 'Filter Value 2', Comment = 'de-DE=Filterwert 2'; Editable = false; }
        field(40; "PrPl Default Field 1"; Text[30]) { Caption = 'Default Field 1', Comment = 'de-DE=Vorgabefeld 1'; Editable = false; }
        field(41; "PrPl Default Value 1"; Text[250]) { Caption = 'Default Value 1', Comment = 'de-DE=Vorgabewert 1'; Editable = false; }
        field(42; "PrPl Default Field 2"; Text[30]) { Caption = 'Default Field 2', Comment = 'de-DE=Vorgabefeld 2'; Editable = false; }
        field(43; "PrPl Default Value 2"; Text[250]) { Caption = 'Default Value 2', Comment = 'de-DE=Vorgabewert 2'; Editable = false; }
        #endregion ProcessingPlan
    }

    keys
    {
        key(Key1; "Template Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }


    internal procedure New(templateCode: Code[150])
    var
        ProcessTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup."Template Code" := templateCode;
        ProcessTemplateSetup."Line No." := getNextLineNo(templateCode);
        Rec.Copy(ProcessTemplateSetup);
    end;

    procedure getNextLineNo(templateCode: Code[150]) NextLineNo: Integer
    var
        ProcessTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        ProcessTemplateSetup.SetRange("Template Code", templateCode);
        if ProcessTemplateSetup.FindLast() then;
        NextLineNo += ProcessTemplateSetup."Line No." + 10000;
    end;
}