page 90015 DMTProcessTemplateSetup
{
    Caption = 'DMT Process Template Setup', Comment = 'de-DE=DMT Prozessvorlagen Einrichtung';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTProcessTemplateSetup;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Template Code"; Rec."Template Code") { StyleExpr = lineStyleExpr; }
                field("Line No."; Rec."Line No.") { }
                field("Type"; Rec."Type")
                {
                    StyleExpr = lineStyleExpr;
                    trigger OnValidate()
                    begin
                        UpdateMandatoryIndicator();
                    end;
                }
                field("Source File Name"; Rec."Source File Name") { ShowMandatory = SourceFileName_Mandatory; }
                field(Indentation; Rec.Indentation) { ShowMandatory = Description_Mandatory; }
                field(Description; Rec.Description) { StyleExpr = lineStyleExpr; ShowMandatory = Description_Mandatory; }
                field("Field Name"; Rec."Field Name") { ShowMandatory = FieldName_Mandatory; }
                field("Filter Expression"; Rec."Filter Expression") { ShowMandatory = FilterExpression_Mandatory; }
                field("Default Value"; Rec."Default Value") { ShowMandatory = DefaultValue_Mandatory; }
                field("NAV Source Table No."; Rec."NAV Source Table No.") { ShowMandatory = NAVSourceTableNo_Mandatory; }
                field("Run Codeunit"; Rec."Run Codeunit") { ShowMandatory = RunCodeunit_Mandatory; }
                field("Target Table ID"; Rec."Target Table ID") { ShowMandatory = TargetTableID_Mandatory; }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(XLSXExport)
            {
                Caption = 'Create Backup', Comment = 'de-DE=Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;

                trigger OnAction()
                begin
                    ExportTemplateSetupToExcel();
                end;
            }
            action(XLSXImport)
            {
                Caption = 'Import Backup', Comment = 'de-DE=Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;

                trigger OnAction()
                begin
                    ImportTemplateSetupFromExcel();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        processTemplateLib: Codeunit DMTProcessTemplateLib;
    begin
        processTemplateLib.InitDefaults();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateMandatoryIndicator();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateMandatoryIndicator();
        case true of
            (Rec.Type = Rec.Type::Group):
                lineStyleExpr := Format(Enum::DMTFieldStyle::Bold);
            else
                lineStyleExpr := Format(Enum::DMTFieldStyle::None);
        end;
    end;

    local procedure UpdateMandatoryIndicator()
    begin
        case Rec.Type of
            Rec.Type::" ":
                begin
                    resetMandatoryIndicator();
                end;
            Rec.Type::"Default Value":
                begin
                    resetMandatoryIndicator();
                    FieldName_Mandatory := true;
                    DefaultValue_Mandatory := true;
                end;
            Rec.Type::"Filter":
                begin
                    resetMandatoryIndicator();
                    FieldName_Mandatory := true;
                    FilterExpression_Mandatory := true;
                end;
            Rec.Type::Group:
                begin
                    resetMandatoryIndicator();
                    Description_Mandatory := true;
                end;
            Rec.Type::"Import Buffer",
            Rec.Type::"Import Buffer+Target",
            Rec.Type::"Import Target":
                begin
                    resetMandatoryIndicator();
                    SourceFileName_Mandatory := true;
                end;
            Rec.Type::"Run Codeunit":
                begin
                    resetMandatoryIndicator();
                    RunCodeunit_Mandatory := true;
                end;
        end;
    end;

    local procedure resetMandatoryIndicator()
    begin
        Description_Mandatory := false;
        SourceFileName_Mandatory := false;
        FieldName_Mandatory := false;
        FilterExpression_Mandatory := false;
        DefaultValue_Mandatory := false;
        NAVSourceTableNo_Mandatory := false;
        RunCodeunit_Mandatory := false;
        TargetTableID_Mandatory := false;
    end;

    procedure createListEntry(var exportSchema: Dictionary of [Integer/*field No.*/, List of [Text] /*Caption, CellType*/]; fieldNo: Integer)
    var
        dmyExcelBuffer: Record "Excel Buffer";
        processTemplateSetup: Record DMTProcessTemplateSetup;
        recRef: RecordRef;
        fieldProps: List of [Text];
    begin
        recRef.GetTable(processTemplateSetup);
        fieldProps.Add(recRef.Field(fieldNo).Caption);
        case recRef.Field(fieldNo).Type of
            FieldType::Code, FieldType::Text, FieldType::Option:
                fieldProps.Add(format(dmyExcelBuffer."Cell Type"::Text));
            FieldType::Integer:
                fieldProps.Add(format(dmyExcelBuffer."Cell Type"::Number));
            else
                Error('Field type %1 not supported', recRef.Field(fieldNo).Type);
        end;
        exportSchema.Add(fieldNo, fieldProps);
    end;

    local procedure ExportTemplateSetupToExcel()
    var
        tempExcelBuffer: Record "Excel Buffer" temporary;
        processTemplateSetup: Record DMTProcessTemplateSetup;
        recRef: RecordRef;
        exportSchema: Dictionary of [Integer/*field No.*/, List of [Text] /*Caption, CellType*/];
        fieldNo: Integer;
        fieldProps: List of [Text];
    begin

        // if not processTemplateSetup.FindSet(false) then
        //     exit;
        exportSchema := loadExportSchema();

        // create headline
        foreach fieldNo in exportSchema.Keys do begin
            fieldProps := exportSchema.Get(fieldNo);
            addTitleColumn(tempExcelBuffer, fieldProps.Get(1));
        end;
        tempExcelBuffer.NewRow();
        if processTemplateSetup.FindSet(false) then
            repeat
                // add line
                recRef.GetTable(processTemplateSetup);
                foreach fieldNo in exportSchema.Keys do begin
                    fieldProps := exportSchema.Get(fieldNo);
                    case true of
                        fieldProps.Get(2) = format(tempExcelBuffer."Cell Type"::Text):
                            tempExcelBuffer.AddColumn(recRef.Field(fieldNo).Value, false, '', false, false, false, '', tempExcelBuffer."Cell Type"::Text);
                        fieldProps.Get(2) = format(tempExcelBuffer."Cell Type"::Number):
                            tempExcelBuffer.AddColumn(recRef.Field(fieldNo).Value, false, '', false, false, false, '', tempExcelBuffer."Cell Type"::Number);
                        else
                            Error('Cell type %1 not supported', fieldProps.Get(1));
                    end;
                end;
                tempExcelBuffer.NewRow();
            until processTemplateSetup.Next() = 0;
        tempExcelBuffer.CreateNewBook(CopyStr(processTemplateSetup.TableCaption, 1, 250));
        tempExcelBuffer.WriteSheet(Rec.TableCaption, CompanyName, UserId);
        tempExcelBuffer.CloseBook();

        tempExcelBuffer.SetFriendlyFilename(StrSubstNo('%1-%2', Rec.TableCaption, Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2>_<Seconds,2>')));
        tempExcelBuffer.OpenExcel();
    end;

    local procedure addTitleColumn(var tempExcelBuffer: Record "Excel Buffer" temporary; content: Text)
    begin
        tempExcelBuffer.AddColumn(content, false, '', true, false, false, '', tempExcelBuffer."Cell Type"::Text);
    end;

    local procedure ImportTemplateSetupFromExcel()
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
        tempProcessTemplateSetup: Record DMTProcessTemplateSetup temporary;
        tempExcelBuffer: Record "Excel Buffer" temporary;
        TempNameValueBufferOut: Record "Name/Value Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        recRef: RecordRef;
        exportSchema: Dictionary of [Integer, List of [Text]];
        FileStream: InStream;
        fieldNo: Integer;
        maxRowNo, rowNo : Integer;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
    begin
        if not UploadExcelFile(TempBlob) then
            exit;
        TempBlob.CreateInStream(FileStream);
        tempExcelBuffer.GetSheetsNameListFromStream(FileStream, TempNameValueBufferOut);
        TempNameValueBufferOut.FindFirst();
        tempExcelBuffer.OpenBookStream(FileStream, TempNameValueBufferOut.Value);
        tempExcelBuffer.ReadSheet();

        if not tempExcelBuffer.FindLast() then
            exit;
        maxRowNo := tempExcelBuffer."Row No.";

        exportSchema := loadExportSchema();
        for rowNo := 2 to maxRowNo do begin
            Clear(processTemplateSetup);
            recRef.GetTable(processTemplateSetup);
            foreach fieldNo in exportSchema.Keys do begin
                if tempExcelBuffer.Get(rowNo, exportSchema.Keys.IndexOf(fieldNo)) then
                    AssignFieldValue(recRef, fieldNo, tempExcelBuffer);
            end;
            recRef.SetTable(processTemplateSetup);
            tempProcessTemplateSetup := processTemplateSetup;
            tempProcessTemplateSetup."Line No." := tempProcessTemplateSetup.getNextLineNo(tempProcessTemplateSetup."Template Code");
            tempProcessTemplateSetup.Insert(false);
        end;
        // Replace
        if tempProcessTemplateSetup.FindSet() then begin
            processTemplateSetup.DeleteAll();
            repeat
                processTemplateSetup := tempProcessTemplateSetup;
                processTemplateSetup.Insert();
            until tempProcessTemplateSetup.Next() = 0;
        end;
        Message(ImportFinishedMsg);
    end;

    local procedure loadExportSchema() exportSchema: Dictionary of [Integer/*field No.*/, List of [Text] /*Caption, CellType*/]
    var
        processTemplateSetup: Record DMTProcessTemplateSetup;
    begin
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Template Code"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Type"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Source File Name"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo(Indentation));
        createListEntry(exportSchema, processTemplateSetup.FieldNo(Description));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Field Name"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Filter Expression"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Default Value"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("NAV Source Table No."));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Run Codeunit"));
        createListEntry(exportSchema, processTemplateSetup.FieldNo("Target Table ID"));
    end;

    local procedure AssignFieldValue(var recRef: RecordRef; fieldNo: Integer; var tempExcelBuffer: Record "Excel Buffer" temporary)
    var
        refHelper: Codeunit DMTRefHelper;
        fieldRef: FieldRef;
        InvalidValueErr: Label 'Invalid cell value "%1" in cell %2%3', Comment = 'de-DE=Ungültiger Zellwert %1 in Zelle %2%3';
    begin
        fieldRef := recRef.Field(fieldNo);
        if not refHelper.EvaluateFieldRef(fieldRef, tempExcelBuffer."Cell Value as Text", false, false) then begin
            Error(InvalidValueErr, tempExcelBuffer."Cell Value as Text", tempExcelBuffer.xlColID, tempExcelBuffer.xlRowID);
        end;
    end;

    procedure UploadExcelFile(var TempBlob: Codeunit "Temp Blob") OK: Boolean
    var
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
        selectExcelFileLbl: Label 'Select Excel File', Comment = 'de-DE=Excel Datei auswählen';
        debug: Integer;
    begin
        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);
        OK := UploadIntoStream(selectExcelFileLbl, '', Format(Enum::DMTFileFilter::Excel), FileName, InStr);
        CopyStream(OutStr, InStr);
        debug := TempBlob.Length();
    end;

    var
        lineStyleExpr: Text;
        // mandatory boolean fields
        Description_Mandatory: Boolean;
        SourceFileName_Mandatory: Boolean;
        FieldName_Mandatory: Boolean;
        FilterExpression_Mandatory: Boolean;
        DefaultValue_Mandatory: Boolean;
        NAVSourceTableNo_Mandatory: Boolean;
        RunCodeunit_Mandatory: Boolean;
        TargetTableID_Mandatory: Boolean;

}