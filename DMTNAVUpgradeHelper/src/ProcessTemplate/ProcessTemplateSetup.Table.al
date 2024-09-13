table 90014 DMTProcessTemplateSetup
{
    Caption = 'DMT Process Template Setup', Comment = 'de-DE=DMT Prozessvorlagen Einrichtung';
    fields
    {
        field(1; "Template Code"; Code[150]) { Caption = 'Template Code', Comment = 'de-DE=Vorlagencode'; }
        field(2; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennummer'; }
        #region SourceInfo
        field(10; "Sorting No."; Integer)
        {
            Caption = 'Sorting No.', Comment = 'de-DE=Reihenfolge';
            trigger OnValidate()
            begin
                propagateField(rec.FieldNo("Sorting No."));
            end;
        }
        field(20; Type; Option)
        {
            Caption = 'Type', Comment = 'de-DE=Art';
            OptionMembers = " ",Group,"Import Buffer","Import Target","Import Buffer+Target","Update Field","Default Value","Filter","Req. Setup","Run Codeunit";
            OptionCaption = ' ,Group,Import Buffer,Import Target,Import Buffer+Target,Update Field,Default Value,Filter,Req. Setup,Run Codeunit',
            Comment = 'de-DE= ,Gruppe,In Puffertabelle einlesen,In Zieltabelle einlesen,Puffer- und Zieltab. importieren,Felder aktualisieren,Vorgaberwert,Filter,benötigte Einrichtung,Codeunit ausführen';
        }
        field(21; "NAV Source Table No."; Integer) { Caption = 'NAV Source Table No.', Comment = 'de-DE=NAV Quelltabelle Nr.'; BlankZero = true; }
        field(22; "Source File Name"; Text[250]) { Caption = 'Source File Name', Comment = 'de-DE=Quelldatei Name'; }
        #endregion SourceInfo
        #region ProcessingPlan
        field(31; "Description"; Text[250]) { Caption = 'Description (Processing Plan)', Comment = 'de-DE=Beschreibung (Verarbeitungsplan)'; }
        field(32; "Indentation"; Integer) { Caption = 'Indentation (Processing Plan)', Comment = 'de-DE=Einrückung (Verarbeitungsplan)'; BlankZero = true; }
        field(33; "Run Codeunit"; Integer) { Caption = 'Run Codeunit ID (Processing Plan)', Comment = 'de-DE=Codeunit ID ausführen (Verarbeitungsplan)'; BlankZero = true; }
        field(40; "Field Name"; Text[30]) { Caption = 'Field Name', Comment = 'de-DE=Feldname'; }
        field(41; "Default Value"; Text[250]) { Caption = 'Default Value', Comment = 'de-DE=Vorgabewert'; }
        field(42; "Filter Expression"; Text[250]) { Caption = 'Filter', Comment = 'de-DE=Filter'; }
        field(50; "Target Table ID"; Integer)
        {
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ValidateTableRelation = false;
            Caption = 'Target Table ID', Comment = 'de-DE=Zieltabelle ID';
            BlankZero = true;
        }
        field(51; "Target Table Caption"; Text[249])
        {
            Caption = 'Target Table Caption', Comment = 'de-DE=Zieltabellen Bezeichnung';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
        }
        #endregion ProcessingPlan
    }

    keys
    {
        key(Key1; "Template Code", "Line No.") { Clustered = true; }
        key(Key2; "Sorting No.", "Template Code", "Line No.") { }
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

    internal procedure IsDataRequiremt(): Boolean
    begin
        exit(Rec.Type = Rec.Type::"Req. Setup");
    end;

    internal procedure IsDataRequirementFulfilled() Result: Boolean
    var
        TableMetadata: Record "Table Metadata";
        dataTypeMgt: Codeunit "Data Type Management";
        recRef: RecordRef;
        fieldRef: FieldRef;
    begin
        Result := true;
        if not TableMetadata.Get(Rec."Target Table ID") then
            exit(false);
        recRef.Open(Rec."Target Table ID");
        if not recRef.FindFirst() then
            exit(false);
        // Tabelle ohne Feld -> Tabelle muss Daten enthalten
        if rec."Field Name" = '' then
            exit(true);
        // Tabelle mit Feldname -> Feld muss gefüllt sein
        if not dataTypeMgt.FindFieldByName(recRef, fieldRef, Rec."Field Name") then
            exit(false);
        Result := format(fieldRef.Value) <> '';
    end;

    internal procedure IsSourceFileRequirement(): Boolean
    begin
        exit(Rec."Source File Name" <> '');
    end;

    internal procedure IsSourceFileRequirementFulfilled() sourceFileExists: Boolean
    var
        sourceFileStorage: Record DMTSourceFileStorage;
    begin
        sourceFileExists := sourceFileStorage.findByFileName(Rec."Source File Name");
        if IsNAVSourceTableEmpty() then
            sourceFileExists := true;
    end;

    internal procedure IsTableRequirement(): Boolean
    begin
        exit((Rec."Target Table ID" <> 0) and (rec.Type <> rec.Type::"Req. Setup"));
    end;

    procedure IsTableRequirementFulfilled() targetTableExists: Boolean
    var
        allObjWithCaption: Record allObjWithCaption;
    begin
        if Rec."Target Table ID" = 0 then
            exit(false);
        targetTableExists := allObjWithCaption.get(allObjWithCaption."Object Type"::Table, Rec."Target Table ID");
    end;

    internal procedure IsCodeunitRequirement(): Boolean
    begin
        exit(Rec.Type = Rec.Type::"Run Codeunit");
    end;

    internal procedure AddFromProcessingPlan(targetTemplateCode: Code[150]; processingPlan: Record DMTProcessingPlan) OK: Boolean
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        processingPlanType: Enum DMTProcessingPlanType;
    begin
        if not processTemplateSetup.tryFindMappedProcessingPlanType(processingPlanType) then
            exit(false);
        case processingPlanType of
            processingPlanType::" ", processingPlanType::Group, processingPlanType::"Import To Buffer":
                begin
                    processTemplateSetup.New(targetTemplateCode);
                    copyDefaultFields(processingPlan, processingPlanType, processTemplateSetup);
                end;
            processingPlanType::"Import To Target", processingPlanType::"Buffer + Target":
                begin
                    processTemplateSetup.New(targetTemplateCode);
                    copyDefaultFields(processingPlan, processingPlanType, processTemplateSetup);
                    //TODO:Filter;
                end;
            processingPlanType::"Update Field":
                begin
                    processTemplateSetup.New(targetTemplateCode);
                    copyDefaultFields(processingPlan, processingPlanType, processTemplateSetup);
                    //TODO:Filter
                end;
            processingPlanType::"Run Codeunit":
                begin

                    copyDefaultFields(processingPlan, processingPlanType, processTemplateSetup);
                    processTemplateSetup."Run Codeunit" := processingPlan.ID;
                end;
            else
                Error('Unhandled processing plan type %1', processingPlanType);
        end;
        processTemplateSetup.Insert();
    end;

    local procedure propagateField(FieldNo: Integer)
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        processTemplateSetup.SetRange("Template Code", Rec."Template Code");
        processTemplateSetup.SetFilter("Line No.", '<>%1', Rec."Line No.");
        case FieldNo of
            Rec.FieldNo("Sorting No."):
                begin
                    processTemplateSetup.ModifyAll("Sorting No.", Rec."Sorting No.");
                end;
        end;
    end;

    local procedure copyDefaultFields(var processingPlan: Record DMTProcessingPlan; var processingPlanType: Enum DMTProcessingPlanType; var processTemplateSetup: Record DMTProcessTemplateSetup)
    begin
        processTemplateSetup.Type := processingPlanType;
        processTemplateSetup."Description" := processingPlan."Description";
        processTemplateSetup.Indentation := processingPlan.Indentation;
    end;

    procedure prepareNewLine(var newLine: Record DMTProcessTemplateSetup) OK: Boolean
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        OK := true;
        if newLine."Template Code" = '' then
            exit(false);

        if newLine."Line No." = 0 then
            newLine."Line No." := newLine.getNextLineNo(newLine."Template Code");

        if newLine."Sorting No." = 0 then begin
            processTemplateSetup.Reset();
            processTemplateSetup.SetRange("Template Code", newLine."Template Code");
            processTemplateSetup.SetFilter("Sorting No.", '<>0');
            if processTemplateSetup.FindFirst() then
                newLine."Sorting No." := processTemplateSetup."Sorting No.";
        end;
    end;

    procedure IsCodeunitRequirementFulfilled() exists: Boolean
    var
        allObjWithCaption: Record allObjWithCaption;
    begin
        if Rec."Run Codeunit" = 0 then
            exit(false);
        exists := allObjWithCaption.get(allObjWithCaption."Object Type"::Codeunit, Rec."Run Codeunit");
    end;

    procedure IsNAVSourceTableEmpty() isEmpty: Boolean
    var
        fieldBuffer: Record DMTFieldBuffer;
    begin
        isEmpty := false;
        if Rec."NAV Source Table No." = 0 then
            exit(false);
        fieldBuffer.SetRange(TableNo, Rec."NAV Source Table No.");
        if fieldBuffer.FindFirst() then
            if fieldBuffer."No. of Records" = 0 then
                exit(true);
    end;

    procedure tryFindMappedProcessingPlanType(var processingPlanType: Enum DMTProcessingPlanType) OK: Boolean
    begin
        ok := true;
        case Rec."Type" of
            Rec."Type"::" ":
                processingPlanType := processingPlanType::" ";
            Rec."Type"::Group:
                processingPlanType := processingPlanType::Group;
            Rec."Type"::"Import Buffer":
                processingPlanType := processingPlanType::"Import To Buffer";
            Rec."Type"::"Import Target":
                processingPlanType := processingPlanType::"Import To Target";
            Rec."Type"::"Import Buffer+Target":
                processingPlanType := processingPlanType::"Buffer + Target";
            Rec."Type"::"Update Field":
                processingPlanType := processingPlanType::"Update Field";
            Rec.Type::"Run Codeunit":
                processingPlanType := processingPlanType::"Run Codeunit";
            else
                OK := false;
        end;
    end;

    procedure getNextLineNo(templateCode: Code[150]) nextLineNo: Integer
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        tempProcessTemplateSetup: Record DMTProcessTemplateSetup temporary;
    begin
        if Rec.IsTemporary then begin
            tempProcessTemplateSetup.Copy(Rec, true);

            tempProcessTemplateSetup.SetRange("Template Code", templateCode);
            if tempProcessTemplateSetup.FindLast() then;
            nextLineNo += tempProcessTemplateSetup."Line No." + 10000;
        end else begin
            processTemplateSetup.SetRange("Template Code", templateCode);
            if processTemplateSetup.FindLast() then;
            nextLineNo += processTemplateSetup."Line No." + 10000;
        end;
    end;
}