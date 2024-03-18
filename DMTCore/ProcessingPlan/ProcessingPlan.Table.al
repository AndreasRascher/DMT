table 91009 DMTProcessingPlan
{
    DataClassification = ToBeClassified;
    Caption = 'DMTProcessingPlan', Locked = true;
    LookupPageId = DMTProcessingPlan;

    fields
    {
        field(1; "Line No."; Integer) { Caption = 'Line No.', Comment = 'de-DE=Zeilennr.'; }
        field(10; Type; Enum DMTProcessingPlanType)
        {
            Caption = 'Type', Comment = 'de-DE=Art';

            trigger OnValidate()
            begin
                if xRec.Type = xRec.Type::" " then
                    if Rec.Type = Rec.Type::Group then begin
                        Clear(Description);
                        Clear(ID);
                    end;
            end;
        }
        field(11; ID; Integer)
        {
            Caption = 'ID', Locked = true;
            TableRelation =
            if (Type = const("Run Codeunit")) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit))
            else
            if (Type = const("Import To Buffer")) DMTImportConfigHeader.ID
            else
            if (Type = const("Import To Target")) DMTImportConfigHeader.ID
            else
            if (Type = const("Update Field")) DMTImportConfigHeader.ID
            else
            if (Type = const("Buffer + Target")) DMTImportConfigHeader.ID;
            trigger OnValidate()
            var
                CodeUnitMetadata: Record "CodeUnit Metadata";
                DMTImportConfigHeader: Record DMTImportConfigHeader;
            begin
                case true of
                    (xRec.ID <> 0) and (Rec.ID = 0):
                        Description := '';
                    (Rec.ID <> 0) and (Type in [Type::"Import To Buffer", Type::"Import To Target", Type::"Update Field", Type::"Buffer + Target"]):
                        begin
                            DMTImportConfigHeader.Get(Rec.ID);
                            Description := DMTImportConfigHeader.GetSourceFileStorage().Name;
                            "Source Table No." := 0;
                        end;
                    (Rec.ID <> 0) and (Type in [Type::"Run Codeunit"]):
                        begin
                            CodeUnitMetadata.Get(Rec.ID);
                            Description := CodeUnitMetadata.Name;
                        end;
                end;
            end;
        }
        field(12; Description; Text[250]) { Caption = 'Description', Comment = 'de-DE=Beschreibung'; }
        field(30; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.', Comment = 'de-DE=Herkunftstabellennr.';
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Current App Package ID Filter"));
        }
        field(31; "Current App Package ID Filter"; Guid) { Caption = 'Current Package ID Filter', Locked = true; FieldClass = FlowFilter; }
        field(32; "Source Table Filter"; Blob) { Caption = 'Source Table Filter Blob', Locked = true; }
        field(33; "Update Fields Filter"; Blob) { Caption = 'Update Fields Filter', Locked = true; }
        field(34; "Default Field Values"; Blob) { Caption = 'Default Field Values', Locked = true; }
        field(40; Status; Option) { Caption = 'Status', Locked = true; OptionMembers = " ","In Progress",Finished; OptionCaption = ' ,In Progress', comment = 'de-DE= ,in Arbeit, Abgeschlossen'; Editable = false; }
        field(41; StartTime; DateTime) { Caption = 'Start Time', Comment = 'de-DE=Startzeit'; Editable = false; }
        field(42; "Processing Duration"; Duration) { Caption = 'Processing Duration', Comment = 'de-DE=Verarbeitungszeit'; Editable = false; }
        field(50; Indentation; Integer) { Caption = 'Indentation', Comment = 'de-DE=Einrückung'; Editable = false; }
    }

    keys
    {
        key(PK; "Line No.") { Clustered = true; }
    }

    procedure EditSourceTableFilter()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        FPBuilder: Codeunit DMTFPBuilder;
        BufferRef: RecordRef;
        CurrView: Text;
    begin
        if Rec.Type = Rec.Type::"Run Codeunit" then begin
            Rec.TestField("Source Table No.");
            BufferRef.Open(Rec."Source Table No.");
            // ImportConfigHeader.BufferTableType := ImportConfigHeader.BufferTableType::"Seperate Buffer Table per CSV";
        end else begin
            ImportConfigHeader.Get(Rec.ID);
            ImportConfigHeader.BufferTableMgt().CheckBufferTableIsNotEmpty();
            ImportConfigHeader.BufferTableMgt().InitBufferRef(BufferRef, true);
        end;
        CurrView := ReadSourceTableView();
        if CurrView <> '' then
            BufferRef.SetView(CurrView);
        if FPBuilder.RunModal(BufferRef, ImportConfigHeader) then begin
            SaveSourceTableFilter(BufferRef.GetView());
        end;
    end;

    procedure EditDefaultValues()
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        FPBuilder: Codeunit DMTFPBuilder;
        TargetRef: RecordRef;
        CurrView: Text;
    begin
        ImportConfigHeader.Get(Rec.ID);
        ImportConfigHeader.BufferTableMgt().CheckBufferTableIsNotEmpty();
        TargetRef.Open(ImportConfigHeader."Target Table ID");
        CurrView := ReadDefaultValuesView();
        if CurrView <> '' then
            TargetRef.SetView(CurrView);
        if FPBuilder.RunModal(TargetRef) then begin
            SaveDefaultValuesView(TargetRef.GetView());
        end;
    end;

    procedure ReadSourceTableView() SourceTableView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields("Source Table Filter");
        if not Rec."Source Table Filter".HasValue then exit('');
        Rec."Source Table Filter".CreateInStream(IStr);
        IStr.ReadText(SourceTableView);
    end;

    procedure ReadDefaultValuesView() DefaultValuesView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields("Default Field Values");
        if not Rec."Default Field Values".HasValue then exit('');
        Rec."Default Field Values".CreateInStream(IStr);
        IStr.ReadText(DefaultValuesView);
    end;

    procedure ReadUpdateFieldsFilter() FilterExpr: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields("Update Fields Filter");
        if not Rec."Update Fields Filter".HasValue then exit('');
        Rec."Update Fields Filter".CreateInStream(IStr);
        IStr.ReadText(FilterExpr);
    end;

    procedure SaveSourceTableFilter(SourceTableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Source Table Filter");
        Rec.Modify();
        if SourceTableView = '' then
            exit;
        Rec."Source Table Filter".CreateOutStream(OStr);
        OStr.WriteText(SourceTableView);
        Rec.Modify();
    end;

    procedure SaveDefaultValuesView(DefaultValuesView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Default Field Values");
        Rec.Modify();
        if DefaultValuesView = '' then
            exit;
        Rec."Default Field Values".CreateOutStream(OStr);
        OStr.WriteText(DefaultValuesView);
        Rec.Modify();
    end;

    procedure SaveUpdateFieldsFilter(UpdateFieldsFilter: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Update Fields Filter");
        Rec.Modify();
        if UpdateFieldsFilter = '' then
            exit;
        Rec."Update Fields Filter".CreateOutStream(OStr);
        OStr.WriteText(UpdateFieldsFilter);
        Rec.Modify();
    end;

    procedure CopyToTemp(var TempProcessingPlan: Record DMTProcessingPlan temporary) LineCount: Integer
    var
        ProcessingPlan: Record DMTProcessingPlan;
        TempProcessingPlan2: Record DMTProcessingPlan temporary;
    begin
        ProcessingPlan.Copy(Rec);
        if ProcessingPlan.FindSet(false) then
            repeat
                LineCount += 1;
                TempProcessingPlan2 := ProcessingPlan;
                TempProcessingPlan2.Insert(false);
            until ProcessingPlan.Next() = 0;
        TempProcessingPlan.Copy(TempProcessingPlan2, true);
    end;

    procedure CreateSourceTableRef(var SourceRef: RecordRef) Ok: Boolean
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
    begin
        Clear(SourceRef);
        if Rec.ID = 0 then exit(false);
        case Rec.Type of
            Rec.Type::"Run Codeunit":
                begin
                    SourceRef.Open(Rec."Source Table No.", false);
                    exit(true);
                end;
            else begin
                ImportConfigHeader.Get(Rec.ID);
                ImportConfigHeader.BufferTableMgt().InitBufferRef(SourceRef);
                exit(true)
            end;
        end;
    end;

    procedure ConvertSourceTableFilterToFieldLines(var TmpImportConfigLine: Record DMTImportConfigLine temporary)
    var
        genBuffTable: Record DMTGenBuffTable;
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
        RecRef: RecordRef;
        FieldIndexNo: Integer;
        CurrView: Text;
    begin
        if not (rec.Type in [rec.Type::"Buffer + Target", Rec.Type::"Import To Target", rec.Type::"Update Field", rec.Type::"Run Codeunit"]) then
            exit;
        if rec.ID = 0 then exit;
        if not Rec.CreateSourceTableRef(RecRef) then
            exit;
        if RecRef.Name = genBuffTable.TableName then begin
            RecRef.SetTable(genBuffTable);
            if not genBuffTable.HasCaptionLine(genBuffTable."Imp.Conf.Header ID") then begin
                TmpImportConfigLine.Copy(TempImportConfigLine2, true);
                exit;
            end;
            genBuffTable.InitFirstLineAsCaptions(genBuffTable); // init column caption single instance codeunit
            RecRef.GetTable(genBuffTable);
        end;
        CurrView := Rec.ReadSourceTableView();
        if CurrView <> '' then begin
            RecRef.SetView(CurrView);
            if RecRef.HasFilter then
                for FieldIndexNo := 1 to RecRef.FieldCount do begin
                    if RecRef.FieldIndex(FieldIndexNo).GetFilter <> '' then begin
                        TempImportConfigLine2."Imp.Conf.Header ID" := Rec.ID;
                        TempImportConfigLine2."Target Field No." := RecRef.FieldIndex(FieldIndexNo).Number;
                        TempImportConfigLine2."Source Field Caption" := CopyStr(RecRef.FieldIndex(FieldIndexNo).Caption, 1, MaxStrLen(TempImportConfigLine2."Source Field Caption"));
                        TempImportConfigLine2."Fixed Value" := CopyStr(RecRef.FieldIndex(FieldIndexNo).GetFilter, 1, MaxStrLen(TempImportConfigLine2."Fixed Value"));
                        TempImportConfigLine2.Insert();
                    end;
                end;
        end;

        TmpImportConfigLine.Copy(TempImportConfigLine2, true);
    end;

    procedure ConvertDefaultValuesViewToFieldLines(var TmpImportConfigLine: Record DMTImportConfigLine temporary) LineCount: Integer
    var
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
        ImportConfigHeader: Record DMTImportConfigHeader;
        ImportConfigLine: Record DMTImportConfigLine;
        RecRef: RecordRef;
        FieldIndexNo: Integer;
        CurrView: Text;
    begin
        if not ImportConfigHeader.Get(Rec.ID) then exit; // ID can be zero
        RecRef.Open(ImportConfigHeader."Target Table ID");
        CurrView := Rec.ReadDefaultValuesView();
        if CurrView <> '' then begin
            RecRef.SetView(CurrView);
            if RecRef.HasFilter then
                for FieldIndexNo := 1 to RecRef.FieldCount do begin
                    if RecRef.FieldIndex(FieldIndexNo).GetFilter <> '' then begin
                        ImportConfigLine.Get(Rec.ID, RecRef.FieldIndex(FieldIndexNo).Number);
                        TempImportConfigLine2 := ImportConfigLine;
                        TempImportConfigLine2."Processing Action" := TempImportConfigLine2."Processing Action"::FixedValue;
                        TempImportConfigLine2."Fixed Value" := CopyStr(RecRef.FieldIndex(FieldIndexNo).GetFilter, 1, MaxStrLen(TempImportConfigLine2."Fixed Value"));
                        TempImportConfigLine2.Insert();
                    end;
                end;
        end;

        TmpImportConfigLine.Copy(TempImportConfigLine2, true);
        LineCount := TmpImportConfigLine.Count;
    end;

    procedure ConvertUpdateFieldsListToFieldLines(var TmpImportConfigLine: Record DMTImportConfigLine temporary) LineCount: Integer
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
        ImportConfigLine: Record DMTImportConfigLine;
        TempImportConfigLine2: Record DMTImportConfigLine temporary;
        RecRef: RecordRef;
        FieldNoFilter: Text;
    begin
        if not Rec.CreateSourceTableRef(RecRef) then exit;
        if not ImportConfigHeader.Get(Rec.ID) then exit;

        FieldNoFilter := Rec.ReadUpdateFieldsFilter();
        if FieldNoFilter <> '' then begin
            ImportConfigHeader.FilterRelated(ImportConfigLine);
            ImportConfigLine.SetFilter("Target Field No.", FieldNoFilter);
            if ImportConfigLine.FindSet(false) then
                repeat
                    TempImportConfigLine2 := ImportConfigLine;
                    TempImportConfigLine2.Insert();
                until ImportConfigLine.Next() = 0;
        end;

        TmpImportConfigLine.Copy(TempImportConfigLine2, true);
        LineCount := TmpImportConfigLine.Count;
    end;

    procedure ApplySourceTableFilter(var Ref: RecordRef) OK: Boolean
    begin
        OK := true;
        if Rec.ReadSourceTableView() = '' then exit(false);
        Ref.SetView(Rec.ReadSourceTableView());
    end;

    internal procedure InitFlowFilters()
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        mI: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mI);
        NAVAppInstalledApp.SetRange("App ID", mI.Id);
        NAVAppInstalledApp.FindFirst();
        Rec.FilterGroup(2);
        Rec.SetRange("Current App Package ID Filter", NAVAppInstalledApp."Package ID");
        Rec.FilterGroup(0);
    end;

    procedure TypeSupportsSourceTableFilter(): Boolean
    begin
        exit(Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Run Codeunit", Rec.Type::"Buffer + Target"]);
    end;

    procedure TypeSupportsProcessSelectedFieldsOnly(): Boolean
    begin
        exit(Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target"]);
    end;

    procedure TypeSupportsFixedValues(): Boolean
    begin
        exit(Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target"]);
    end;

}