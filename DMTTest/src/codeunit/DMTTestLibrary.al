codeunit 90022 DMTTestLibrary
{
    procedure CreateDMTSetup()
    var
        DMTSetup: Record DMTSetup;
    begin
        DMTSetup.InsertWhenEmpty();
        DMTSetup.Validate(MigrationProfil, DMTSetup.MigrationProfil::"From NAV"); // required to match fields by name not caption
    end;

    procedure CreateImportConfigHeader(var importConfigHeader: Record DMTImportConfigHeader; targetTableID: Integer; sourceFileStorage: Record DMTSourceFileStorage) OK: Boolean
    begin
        Clear(importConfigHeader);
        importConfigHeader.Validate("Target Table ID", Database::"Sales Line");
        importConfigHeader.Validate("Source File ID", sourceFileStorage."File ID");
        importConfigHeader.Validate("Source File Name", sourceFileStorage.Name);
        OK := importConfigHeader.Insert(true);
    end;

    procedure CreateFieldMapping(importConfigHeader: Record DMTImportConfigHeader; AssignWithoutValidate: Boolean) OK: Boolean
    var
        importConfigLine: Record DMTImportConfigLine;
        importConfigMgt: Codeunit DMTImportConfigMgt;
    begin
        ImportConfigMgt.PageAction_InitImportConfigLine(importConfigHeader.ID);
        importConfigHeader.ImportFileToBuffer();
        importConfigMgt.PageAction_ProposeMatchingFields(importConfigHeader.ID);
        importConfigHeader.FilterRelated(importConfigLine);
        if AssignWithoutValidate then
            importConfigLine.ModifyAll("Validation Type", importConfigLine."Validation Type"::AssignWithoutValidate);
    end;

    internal procedure CreateReplacementSetup2by2(replacementCode: Code[100]; ImportConfigHeader: Record DMTImportConfigHeader) ok: Boolean
    var
        replacementHeader: Record DMTReplacementHeader;
        replacementLine: Record DMTReplacementLine;
        SalesLine: Record "Sales Line";
    begin
        if replacementHeader.Get(replacementCode) then
            replacementHeader.Delete(true);
        CreateReplacementHeader(replacementHeader, replacementCode, 2, 2);
        CreateReplacementAssignmentLine(replacementLine, replacementHeader);

        replacementLine.Validate("Imp.Conf.Header ID", ImportConfigHeader.ID);
        replacementLine.Validate("Source 1 Field No.", SalesLine.FieldNo(Description));
        replacementLine.Validate("Source 1 Field Caption", SalesLine.FieldName(Description));
        replacementLine.Validate("Source 2 Field No.", SalesLine.FieldNo("Description 2"));
        replacementLine.Validate("Source 2 Field Caption", SalesLine.FieldName("Description 2"));

        replacementLine.Validate("Target Table ID", SalesLine.RecordId.TableNo);
        replacementLine.Validate("Target 1 Field No.", SalesLine.FieldNo(Description));
        replacementLine.Validate("Target 1 Field Caption", SalesLine.FieldName(Description));
        replacementLine.Validate("Target 2 Field No.", SalesLine.FieldNo("Description 2"));
        replacementLine.Validate("Target 2 Field Caption", SalesLine.FieldName("Description 2"));
        ok := replacementLine.Modify(true);

        CreateReplacementRuleLine(replacementLine, replacementHeader);
        replacementLine."Comp.Value 1" := 'OldValue1';
        replacementLine."Comp.Value 2" := 'OldValue2';
        replacementLine."New Value 1" := 'NewValue1';
        replacementLine."New Value 2" := 'NewValue2';
        replacementLine.Modify();
    end;

    internal procedure CreateSourceFileStorage(var sourceFileStorage: Record DMTSourceFileStorage; fileNameWithExtension: Text; DMTDataLayout: Record DMTDataLayout) OK: Boolean
    var
        fileMgt: Codeunit "File Management";
    begin
        sourceFileStorage."File ID" := 1;
        sourceFileStorage.Name := CopyStr(fileNameWithExtension, 1, MaxStrLen(sourceFileStorage.Name));
        sourceFileStorage.Extension := CopyStr(fileMgt.GetExtension(fileNameWithExtension), 1, MaxStrLen(sourceFileStorage.Extension));
        sourceFileStorage.SourceFileFormat := sourceFileStorage.SourceFileFormat::"Custom CSV";
        sourceFileStorage.Validate("Data Layout ID", DMTDataLayout.ID);
        OK := sourceFileStorage.Insert();
    end;

    internal procedure CreateOrGetDataLayout(var dataLayout: Record DMTDataLayout; dataLayoutName: Text) OK: Boolean
    var
        dataLayouts: page DMTDataLayouts;
    begin
        dataLayouts.InsertPresetDataLayouts();
        dataLayout.SetRange(Name, dataLayoutName);
        OK := dataLayout.FindFirst();
    end;

    internal procedure BuildDataTable(var dataTable: List of [List of [Text]]; rowNo: Integer; colNo: Integer; content: Text)
    var
        line: list of [Text];
    begin
        // create empty postions until the row desired position
        while dataTable.Count < rowNo do
            dataTable.Add(line);
        // create empty postions until the column desired position
        dataTable.Get(rowNo, line);
        while line.Count < colNo do
            line.Add('');
        dataTable.Get(rowNo).Set(colNo, content);
    end;

    internal procedure WriteDataTableToSourceFile(dataTable: List of [List of [Text]]; sourceFileStorage: Record DMTSourceFileStorage)
    var
        BigText: BigText;
        iStr: InStream;
        colNo, lastColNo : Integer;
        line: list of [Text];
        oStr: OutStream;
        TAB: Text[1];
        CRLF: Text[2];
    begin
        TAB[1] := 9;
        CRLF[1] := 13;
        CRLF[2] := 10;
        clear(sourceFileStorage."File Blob");
        sourceFileStorage."File Blob".CreateOutStream(oStr);
        // iterate through the data table and write the content to the CSV file
        foreach line in dataTable do begin
            lastColNo := line.Count;
            for colNo := 1 to line.Count do
                if colNo = lastColNo then
                    oStr.WriteText(line.Get(colNo))
                else
                    OStr.WriteText(line.Get(colNo) + TAB);
            oStr.WriteText(CRLF);
        end;
        sourceFileStorage.Modify();
        sourceFileStorage.CalcFields("File Blob");
        sourceFileStorage."File Blob".CreateInStream(iStr);
        BigText.Read(iStr);
    end;

    internal procedure ImportSelectedToTarget(importConfigHeader: Record DMTImportConfigHeader)
    var
        genBuffTable: Record DMTGenBuffTable;
        migrate: Codeunit DMTMigrate;
        Log: Codeunit DMTLog;
        RecIdToProcessList: List of [RecordId];
    begin
        genBuffTable.FilterBy(importConfigHeader);
        genBuffTable.SetRange(IsCaptionLine, false);
        genBuffTable.FindSet();
        repeat
            RecIdToProcessList.Add(genBuffTable.RecordId);
        until genBuffTable.Next() = 0;
        Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", ImportConfigHeader);
        migrate.ListOfBufferRecIDs(RecIdToProcessList, Log, importConfigHeader, false);
    end;

    internal procedure ImportAllToTarget(importConfigHeader: Record DMTImportConfigHeader)
    var
        migrate: Codeunit DMTMigrate;
        Log: Codeunit DMTLog;
    begin
        Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", ImportConfigHeader);
        migrate.AllFieldsFrom(importConfigHeader, true);
    end;

    internal procedure UpdateSelectedFieldsInTarget(importConfigHeader: Record DMTImportConfigHeader; SelectedFieldsNoFilter: Text)
    var
        migrate: Codeunit DMTMigrate;
        Log: Codeunit DMTLog;
    begin
        Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Field Update", ImportConfigHeader);
        importConfigHeader.WriteLastFieldUpdateSelection(SelectedFieldsNoFilter);
        migrate.SelectedFieldsFrom(importConfigHeader, true);
    end;

    local procedure CreateReplacementHeader(var replacementHeader: Record DMTReplacementHeader; replacementCode: Code[100]; NoOfSourceValues: Integer; NoOfTargetValues: Integer)
    begin
        Clear(replacementHeader);
        replacementHeader.Code := replacementCode;
        if replacementHeader.Insert(true) then
            replacementHeader.Validate("Replacement Type", replacementHeader."Replacement Type"::"Field Content");
        case NoOfSourceValues of
            1:
                replacementHeader.Validate("No. of Source Values", replacementHeader."No. of Source Values"::"1");
            2:
                replacementHeader.Validate("No. of Source Values", replacementHeader."No. of Source Values"::"2");
        end;
        case NoOfTargetValues of
            1:
                replacementHeader.Validate("No. of Values to modify", replacementHeader."No. of Values to modify"::"1");
            2:
                replacementHeader.Validate("No. of Values to modify", replacementHeader."No. of Values to modify"::"2");
        end;
        replacementHeader.Modify(true)
    end;

    local procedure CreateReplacementAssignmentLine(var replacementLine: Record DMTReplacementLine; replacementHeader: Record DMTReplacementHeader)
    begin
        replacementLine."Replacement Code" := replacementHeader.Code;
        replacementLine."Line Type" := replacementLine."Line Type"::Assignment;
        replacementLine."Line No." := replacementLine.GetNextLineNo(replacementHeader.Code, replacementLine."Line Type"::Assignment);
        replacementLine.Insert(true);
    end;

    local procedure CreateReplacementRuleLine(var replacementLine: Record DMTReplacementLine; replacementHeader: Record DMTReplacementHeader)
    begin
        replacementLine."Replacement Code" := replacementHeader.Code;
        replacementLine."Line Type" := replacementLine."Line Type"::Rule;
        replacementLine."Line No." := replacementLine.GetNextLineNo(replacementHeader.Code, replacementLine."Line Type"::Assignment);
        replacementLine.Insert(true);
    end;

    procedure ValidateAssignmentsExitsFor(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        replacementAssignments: Record DMTReplacementLine;
    begin
        //load assigned replacements
        replacementAssignments.FindFirst();
        replacementAssignments.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        replacementAssignments.SetRange("Line Type", replacementAssignments."Line Type"::Assignment);
        if replacementAssignments.IsEmpty() then
            Error('No replacement assignments found for the import configuration');
    end;

    internal procedure ValidateRulesExitsFor(replacementCode: Code[100])
    var
        replacementAssignments: Record DMTReplacementLine;
    begin
        //load assigned replacements
        replacementAssignments.SetRange("Replacement Code", replacementCode);
        replacementAssignments.SetRange("Line Type", replacementAssignments."Line Type"::Rule);
        if replacementAssignments.IsEmpty() then
            Error('No replacement rules found for the replacement code');
    end;
}