codeunit 91007 DMTXMLBackup
{

    #region Export
    procedure Export();
    begin
        MarkAllRecordsForExport();
        ExcludeFieldsFromExport();
        ExportXML('');
    end;

    procedure ExportSelectedRecordIDs(recordsToExport: Dictionary of [Integer/*TableID*/, List of [RecordId]]; exportFileBaseName: Text);
    begin
        GlobalRecordIDList := recordsToExport;
        ExportXML(exportFileBaseName);
    end;

    procedure MarkAllRecordsForExport();
    var
        recRef: RecordRef;
        tableID: Integer;
        TablesToExport: List of [Integer];
        listOfRecordIDs: List of [RecordId];
    begin
        TablesToExport.Add(Database::DMTSetup);
        TablesToExport.Add(Database::DMTDataLayout);
        TablesToExport.Add(Database::DMTDataLayoutLine);
        TablesToExport.Add(Database::DMTImportConfigHeader);
        TablesToExport.Add(Database::DMTImportConfigLine);
        TablesToExport.Add(Database::DMTSourceFileStorage);
        TablesToExport.Add(Database::DMTProcessingPlan);
        TablesToExport.Add(Database::DMTReplacementHeader);
        TablesToExport.Add(Database::DMTReplacementLine);
        TablesToExport.Add(Database::DMTCopyTable);
        TablesToExport.Add(Database::DMTProcessingPlanBatch);
        foreach tableID in TablesToExport do begin
            Clear(listOfRecordIDs);
            recRef.Open(tableID);
            if recRef.FindSet(false) then
                repeat
                    listOfRecordIDs.Add(recRef.RecordId);
                until recRef.Next() = 0;
            recRef.Close();
            GlobalRecordIDList.Add(tableID, listOfRecordIDs);
        end;
    end;

    local procedure ExcludeFieldsFromExport();
    var
        sourceFileStorage: Record DMTSourceFileStorage;
        importConfigHeader: Record DMTImportConfigHeader;
        processingPlan: Record DMTProcessingPlan;
    begin
        AddFieldToExcludeList(importConfigHeader.RecordId.TableNo, importConfigHeader.FieldNo("No.of Records in Buffer Table"));
        AddFieldToExcludeList(importConfigHeader.RecordId.TableNo, importConfigHeader.FieldNo(ImportToTargetPercentage));
        AddFieldToExcludeList(importConfigHeader.RecordId.TableNo, importConfigHeader.FieldNo(ImportToTargetPercentageStyle));
        AddFieldToExcludeList(sourceFileStorage.RecordId.TableNo, sourceFileStorage.FieldNo("File Blob"));
        AddFieldToExcludeList(sourceFileStorage.RecordId.TableNo, sourceFileStorage.FieldNo(Size));
        AddFieldToExcludeList(sourceFileStorage.RecordId.TableNo, sourceFileStorage.FieldNo(SizeInKB));
        AddFieldToExcludeList(sourceFileStorage.RecordId.TableNo, sourceFileStorage.FieldNo(UploadDateTime));
        AddFieldToExcludeList(processingPlan.RecordId.TableNo, processingPlan.FieldNo(StartTime));
        AddFieldToExcludeList(processingPlan.RecordId.TableNo, processingPlan.FieldNo("Processing Duration"));
        AddFieldToExcludeList(processingPlan.RecordId.TableNo, processingPlan.FieldNo(Status));
        AddFieldToExcludeList(processingPlan.RecordId.TableNo, processingPlan.FieldNo("No.of Records in Buffer Table"));
    end;

    local procedure AddFieldToExcludeList(TableNo: Integer; FieldNo: Integer)
    var
        FieldList: List of [Integer];
    begin
        if not ExcludedFields.ContainsKey(TableNo) then begin
            ExcludedFields.Add(TableNo, FieldList);
        end;
        if ExcludedFields.Get(TableNo, FieldList) then begin
            if not FieldList.Contains(FieldNo) then begin
                FieldList.Add(FieldNo);
                ExcludedFields.Set(TableNo, FieldList);
            end;
        end;
    end;

    local procedure IsFieldExcluded(var fldRef: FieldRef) IsExcluded: Boolean
    var
        FieldList: List of [Integer];
    begin
        IsExcluded := true;
        if not ExcludedFields.Get(fldRef.Record().Number, FieldList) then
            exit(false);
        if not FieldList.Contains(fldRef.Number) then
            exit(false);
    end;

    internal procedure CreateBackupXML(var backupXmlFile: Codeunit "Temp Blob")
    var
        allObj: Record AllObj;
        tableID: Integer;
        fieldDefinitionNode: XmlNode;
        rootNode: XmlNode;
        tableNode: XmlNode;
        oStr: OutStream;
        backupXMLDocument: XmlDocument;
    begin
        // DOKUMENT
        Clear(backupXMLDocument);
        backupXMLDocument := XmlDocument.Create();

        // ROOT
        rootNode := XmlElement.Create('DMT').AsXmlNode();
        backupXMLDocument.Add(rootNode);
        AddAttribute(rootNode, 'Version', '2.0');

        // Table Loop
        foreach tableID in GlobalRecordIDList.Keys do
            if GlobalRecordIDList.Get(tableID).Count > 0 then begin
                allObj.Get(allObj."Object Type"::Table, tableID);
                tableNode := XmlElement.Create(CreateTagName(allObj."Object Name")).AsXmlNode();
                rootNode.AsXmlElement().Add(tableNode);

                AddAttribute(tableNode, 'ID', Format(tableID));
                AddAttribute(tableNode, 'NAME', ConvertStr(allObj."Object Name", '"', '_'));
                fieldDefinitionNode := CreateFieldDefinitionNode(tableID);
                tableNode.AsXmlElement().Add(fieldDefinitionNode);
                AddTable(tableNode, allObj."Object ID");
            end;
        Clear(backupXmlFile);
        backupXmlFile.CreateOutStream(oStr);
        backupXMLDocument.WriteTo(oStr);
    end;

    procedure CreateFieldDefinitionNode(tableID: Integer) XFieldDefinition: XmlNode
    var
        recRef: RecordRef;
        fldRef: FieldRef;
        fieldList: Dictionary of [Integer, Text];
        fieldID: Integer;
        xField: XmlNode;
    begin
        recRef.Open(tableID);
        recRef.Init();
        XFieldDefinition := XmlElement.Create('FieldDefinition').AsXmlNode();
        CreateListOfExportFields(recRef, fieldList);
        foreach fieldID in fieldList.Keys do begin
            Clear(fldRef);
            fldRef := recRef.Field(fieldID);
            xField := XmlElement.Create('Field').AsXmlNode();
            AddAttribute(xField, 'Number', Format(fldRef.Number));
            AddAttribute(xField, 'Type', Format(fldRef.Type));
            if fldRef.Length <> 0 then
                AddAttribute(xField, 'Length', Format(fldRef.Length));
            if fldRef.Class <> FieldClass::Normal then
                AddAttribute(xField, 'Class', Format(fldRef.Class));
            if not fldRef.Active then
                AddAttribute(xField, 'Active', Format(fldRef.Active, 0, 9));
            AddAttribute(xField, 'Name', Format(fldRef.Name, 0, 9));
            AddAttribute(xField, 'Caption', Format(fldRef.Caption, 0, 9));
            if not (fldRef.Type in [FieldType::Blob, FieldType::Media, FieldType::MediaSet]) then
                AddAttribute(xField, 'InitValue', Format(recRef.Field(fldRef.Number).Value, 0, 9));
            if fldRef.Type = FieldType::Option then begin
                AddAttribute(xField, 'OptionCaption', Format(fldRef.OptionCaption));
                AddAttribute(xField, 'OptionMembers', Format(fldRef.OptionMembers));
            end;
            if fldRef.Relation <> 0 then
                AddAttribute(xField, 'Relation', Format(fldRef.Relation));
            XFieldDefinition.AsXmlElement().Add(xField);
        end;
    end;

    local procedure AddTable(var _XMLNode_Start: XmlNode; tableID: Integer);
    var
        ID: RecordId;
        recRef: RecordRef;
        fldRef: FieldRef;
        i: Integer;
        keyFieldID: Integer;
        fieldIDsList: List of [Integer];
        fieldValueAsText: Text;
        fieldNode: XmlNode;
        recordNode: XmlNode;
        textNode: XmlText;
    begin
        foreach ID in GlobalRecordIDList.Get(tableID) do begin
            recordNode := XmlElement.Create('RECORD').AsXmlNode();
            _XMLNode_Start.AsXmlElement().Add(recordNode);
            recRef.Get(ID);
            fieldIDsList := GetListOfKeyFieldIDs(recRef);
            // Add Key Fields As Attributes
            foreach keyFieldID in fieldIDsList do begin
                fldRef := recRef.Field(keyFieldID);
                AddAttribute(recordNode, CreateTagName(fldRef.Name), GetFldRefValueAsText(fldRef));
            end;
            // Add Fields with Value
            for i := 1 to recRef.FieldCount do begin
                fldRef := recRef.FieldIndex(i);
                if not IsFieldExcluded(fldRef) then
                    if not FldRefIsEmpty(fldRef) then begin
                        fieldNode := XmlElement.Create('FIELD').AsXmlNode();
                        recordNode.AsXmlElement().Add(fieldNode);
                        AddAttribute(fieldNode, 'ID', Format(fldRef.Number));
                        fieldValueAsText := GetFldRefValueAsText(fldRef);
                        textNode := XmlText.Create(fieldValueAsText);
                        fieldNode.AsXmlElement().Add(textNode);
                    end;
            end;
        end;
    end;

    local procedure ExportXML(exportFileBaseName: Text);
    var
        xmlFile: Codeunit "Temp Blob";
    begin
        CreateBackupXML(xmlFile);
        CreateExportFileName(exportFileBaseName);
        DownloadFile(xmlFile, exportFileBaseName, TextEncoding::UTF8);
        Clear(GlobalRecordIDList); // Clear the list of marked records for export
    end;

    local procedure CreateExportFileName(var exportFileBaseName: Text)
    var
        Company: Record Company;
    begin
        // Compose Export Filename
        if exportFileBaseName = '' then
            exportFileBaseName := 'Backup_';
        Company.Get(CompanyName);
        if Company."Display Name" <> '' then
            exportFileBaseName += Company."Display Name"
        else
            exportFileBaseName += Company.Name;
        exportFileBaseName += Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2>_<Seconds,2>');
        exportFileBaseName += '.xml';
        exportFileBaseName := ConvertStr(exportFileBaseName, '<>*\/|"', '_______');
    end;
    #endregion Export

    #region Import
    internal procedure ImportWithDialog();
    var
        tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary;
        uploadedFile: Codeunit "Temp Blob";
        Start: DateTime;
        iStr: InStream;
        length: Integer;
        importFinishedMsg: Label 'Import abgeschlossen\ Import Dauer: %1', Comment = 'de-DE=Import abgeschlossen\ Import Dauer: %1';
        UploadFileMsg: Label 'Select a backup.xml file', Comment = 'de-DE=Wählen Sie eine Backup.XML-Datei aus';
        oStr: outStream;
        FileName: Text;
        xDoc: XmlDocument;
    begin
        uploadedFile.CreateInStream(iStr, TextEncoding::Windows);
        if not UploadIntoStream(UploadFileMsg, '', Format(Enum::DMTFileFilter::Xml), FileName, IStr) then
            exit;
        uploadedFile.CreateOutStream(OStr);
        CopyStream(OStr, IStr);
        length := uploadedFile.Length();

        Start := CurrentDateTime;
        if not XmlDocument.ReadFrom(uploadedFile.CreateInStream(), XDoc) then
            Error('reading xml failed');
        ImportTables(tempImportWorksheetBuffer, xDoc);
        findImportActions(tempImportWorksheetBuffer);

        if openImportWorksheet(tempImportWorksheetBuffer) then begin
            RenameIncomingRecordsIfRequired(tempImportWorksheetBuffer);
            DeleteExistingRecords(tempImportWorksheetBuffer);
            SaveRecords(tempImportWorksheetBuffer);
            RunPostImportOperations();
            Message(importFinishedMsg, CurrentDateTime - Start);
        end;
    end;

    internal procedure ImportTables(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary; xmlDoc: XmlDocument)
    var
        DMTSetup: Record DMTSetup;
        DMTDataLayout: Record DMTDataLayout;
        DMTDataLayoutLine: Record DMTDataLayoutLine;
        DMTImportConfigHeader: Record DMTImportConfigHeader;
        DMTImportConfigLine: Record DMTImportConfigLine;
        DMTSourceFileStorage: Record DMTSourceFileStorage;
        DMTProcessingPlanBatch: Record DMTProcessingPlanBatch;
        DMTProcessingPlan: Record DMTProcessingPlan;
        DMTReplacementHeader: Record DMTReplacementHeader;
        DMTReplacementLine: Record DMTReplacementLine;
        DMTCopyTable: Record DMTCopyTable;
    begin
        ImportTable(tempImportWorksheetBuffer, DMTSetup, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTDataLayout, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTDataLayoutLine, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTImportConfigHeader, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTImportConfigLine, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTSourceFileStorage, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTProcessingPlanBatch, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTProcessingPlan, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTReplacementHeader, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTReplacementLine, xmlDoc);
        ImportTable(tempImportWorksheetBuffer, DMTCopyTable, xmlDoc);
    end;

    internal procedure ImportTable(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary; targetTableRecordVariant: Variant; xmlDoc: XmlDocument) OK: Boolean
    var
        // dmtSetup: Record DMTSetup;
        tmpTargetRef, targetRef : RecordRef;
        tableNodeName: Text;
        XRecordNode, XTableNode : XmlNode;
        XRecordList: XmlNodeList;
    begin
        targetRef.GetTable(targetTableRecordVariant);
        tableNodeName := CreateTagName(targetRef.Name);
        if not xmlDoc.SelectSingleNode(StrSubstNo('//DMT/%1', tableNodeName), XTableNode) then
            exit(false);
        if not XTableNode.SelectNodes('child::RECORD', XRecordList) then  // select all element children
            exit(false);
        OK := XRecordList.Count > 0;
        foreach XRecordNode in XRecordList do begin
            readRecordNode(tmpTargetRef, targetRef.Number, targetRef.Name, XRecordNode);
            saveImportedRecToTemp(tempImportWorksheetBuffer, tmpTargetRef);
        end;
    end;

    internal procedure readRecordNode(var TmpTargetRef: RecordRef; ImportToTableID: Integer; ImportToTableName: Text; var XRecordNode: XmlNode)
    var
        allObj: Record AllObj;
        FldRef: FieldRef;
        FieldNodeID: Integer;
        XFieldNode: XmlNode;
        XFieldList: XmlNodeList;
    begin
        // Check for renumbering
        if not allObj.Get(allObj."Object Type"::Table, ImportToTableID) then
            if ImportToTableName <> '' then begin
                allObj.SetRange("Object Type", allObj."Object Type"::Table);
                allObj.SetFilter("Object Name", ConvertStr(ImportToTableName, '_', '?'));
                if allObj.FindFirst() then
                    ImportToTableID := allObj."Object ID";
            end;

        Clear(TmpTargetRef);
        TmpTargetRef.Open(ImportToTableID, true);
        XRecordNode.SelectNodes('child::*', XFieldList); // select all element children
        foreach XFieldNode in XFieldList do begin
            Evaluate(FieldNodeID, GetAttributeValue(XFieldNode, 'ID'));
            if TmpTargetRef.FieldExist(FieldNodeID) then begin
                FldRef := TmpTargetRef.Field(FieldNodeID);
                if XFieldNode.AsXmlElement().InnerText <> '' then
                    FldRefEvaluate(FldRef, XFieldNode.AsXmlElement().InnerText);
            end;
        end;
    end;
    #endregion Import

    procedure AddAttribute(XNode: XmlNode; AttrName: Text; AttrValue: Text): Boolean
    begin
        if not XNode.IsXmlElement then
            exit(false);
        XNode.AsXmlElement().SetAttribute(AttrName, AttrValue);
    end;

    procedure GetAttributeValue(XNode: XmlNode; AttrName: Text): Text
    var
        XAttribute: XmlAttribute;
    begin
        if XNode.AsXmlElement().Attributes().Get(AttrName, XAttribute) then
            exit(XAttribute.Value());
    end;

    procedure FldRefIsEmpty(FldRef: FieldRef) IsEmpty: Boolean
    var
        InitRef: RecordRef;
    begin
        InitRef.Open(FldRef.Record().Number);
        InitRef.Init();
        if FldRef.Type in [FieldType::Blob] then
            FldRef.CalcField();
        IsEmpty := (InitRef.Field(FldRef.Number).Value = FldRef.Value);
        exit(IsEmpty);
    end;

    procedure FldRefEvaluate(var FldRef: FieldRef; ValueAsText: Text)
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        DateFormulaType: DateFormula;
        RecordIDType: RecordId;
        BigIntegerType: BigInteger;
        BooleanType: Boolean;
        DateType: Date;
        DateTimeType: DateTime;
        DecimalType: Decimal;
        DurationType: Duration;
        GUIDType: Guid;
        IntegerType: Integer;
        OStream: OutStream;
        TimeType: Time;
    begin
        case FldRef.Type of
            FldRef.Type::BigInteger:
                begin
                    Evaluate(BigIntegerType, ValueAsText);
                    FldRef.Value(BigIntegerType);
                end;
            FldRef.Type::Blob:
                begin
                    Clear(TenantMedia.Content);
                    if ValueAsText <> '' then begin
                        TenantMedia.Content.CreateOutStream(OStream);
                        Base64Convert.FromBase64(ValueAsText, OStream);
                    end;
                    FldRef.Value(TenantMedia.Content);
                end;
            FldRef.Type::Boolean:
                begin
                    Evaluate(BooleanType, ValueAsText, 9);
                    FldRef.Value(BooleanType);
                end;
            FldRef.Type::Text,
            FldRef.Type::Code:
                FldRef.Value(ValueAsText);
            FldRef.Type::Date:
                begin
                    Evaluate(DateType, ValueAsText, 9);
                    FldRef.Value(DateType);
                end;
            FldRef.Type::DateFormula:
                begin
                    Evaluate(DateFormulaType, ValueAsText, 9);
                    FldRef.Value(DateFormulaType);
                end;
            FldRef.Type::DateTime:
                begin
                    Evaluate(DateTimeType, ValueAsText, 9);
                    FldRef.Value(DateTimeType);
                end;
            FldRef.Type::Decimal:
                begin
                    Evaluate(DecimalType, ValueAsText, 9);
                    FldRef.Value(DecimalType);
                end;
            FldRef.Type::Duration:
                begin
                    Evaluate(DurationType, ValueAsText, 9);
                    FldRef.Value(DurationType);
                end;
            FldRef.Type::Guid:
                begin
                    Evaluate(GUIDType, ValueAsText, 9);
                    FldRef.Value(GUIDType);
                end;
            FldRef.Type::Integer,
            FldRef.Type::Option:
                begin
                    Evaluate(IntegerType, ValueAsText, 9);
                    FldRef.Value(IntegerType);
                end;
            //FldRef.Type::Media:
            //    ;
            //FldRef.Type::MediaSet:
            //    ;
            FldRef.Type::RecordId:
                begin
                    Evaluate(RecordIDType, ValueAsText, 9);
                    FldRef.Value(RecordIDType);
                end;
            FldRef.Type::Time:
                begin
                    Evaluate(TimeType, ValueAsText, 9);
                    FldRef.Value(TimeType);
                end;
            FldRef.Type::TableFilter:
                ;
            else
                Error('FldRefEvaluate: unhandled field type %1', FldRef.Type);
        end;

    end;

    procedure GetFldRefValueAsText(var FldRef: FieldRef) ValueText: Text;
    begin
        case Format(FldRef.Type) of
            'BLOB':
                GetBlobFieldAsText(FldRef, true, ValueText);
            'Media':
                GetMediaFieldAsText(FldRef, true, ValueText);
            'MediaSet':
                Error('not Implemented');
            'BigInteger',
            'Boolean',
            'Code',
            'Date',
            'DateFormula',
            'DateTime',
            'Decimal',
            'Duration',
            'GUID',
            'Integer',
            'Option',
            'RecordId',
            'TableFilter',
            'Text',
            'Time',
            'RecordID':
                ValueText := Format(FldRef.Value, 0, 9);
            else
                Error('GetFldRefValueAsText:unhandled Fieldtype %1', FldRef.Type);
        end;
    end;

    local procedure CreateListOfExportFields(var RecRef: RecordRef; var FieldIDs: Dictionary of [Integer, Text])
    var
        FldRef: FieldRef;
        FldIndex: Integer;
    begin
        for FldIndex := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(FldIndex);
            if (FldRef.Class = FldRef.Class::Normal) and FldRef.Active then
                FieldIDs.Add(FldRef.Number, FldRef.Name);
        end;
    end;

    procedure CreateTagName(_Name: Text) _TagName: Text;
    begin
        _Name := DelChr(_Name, '=', ' ');
        _TagName := ConvertStr(_Name, '\/-.()', '______')
    end;

    procedure GetListOfKeyFieldIDs(var RecRef: RecordRef) KeyFieldIDsList: List of [Integer];
    var
        FieldRef: FieldRef;
        _KeyIndex: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for _KeyIndex := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(_KeyIndex);
            KeyFieldIDsList.Add(FieldRef.Number);
        end;
    end;


    local procedure RunPostImportOperations()
    var
        importConfigHeader: Record DMTImportConfigHeader;
        processingPlan: Record DMTProcessingPlan;
    begin
        // Update imported "Qty.Lines In Trgt. Table" with actual values
        if importConfigHeader.FindSet() then
            repeat
                importConfigHeader.UpdateBufferRecordCount();
            until importConfigHeader.Next() = 0;

        // Update "No.of Records in Buffer Table" in Processing Plan
        if processingPlan.FindSet() then
            repeat
                if processingPlan.findImportConfigHeader(importConfigHeader) then begin
                    processingPlan."No.of Records in Buffer Table" := importConfigHeader."No.of Records in Buffer Table";
                    processingPlan.Modify();
                end;
            until processingPlan.Next() = 0;
    end;
    /// <summary>
    /// <p>Process the imported record and insert it into global temp table</p>
    /// </summary>
    local procedure saveImportedRecToTemp(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary; TmpTargetRef: RecordRef)
    var
        uniqueID: Text;
    begin
        CalcAllBlobFields(TmpTargetRef);

        // map to correct table
        case TmpTargetRef.Name of
            TempSetup.TableName:
                begin
                    TmpTargetRef.SetTable(TempSetup);
                    TempSetup.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::Setup;
                    tempImportWorksheetBuffer.UniqueID := StrSubstNo('');
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            TempDataLayout.TableName:
                begin
                    TmpTargetRef.SetTable(TempDataLayout);
                    TempDataLayout.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::"Data Layout";
                    tempImportWorksheetBuffer.UniqueID := StrSubstNo('%1', TempDataLayout.Name);
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            TempDataLayoutLine.TableName:
                begin
                    TmpTargetRef.SetTable(TempDataLayoutLine);
                    TempDataLayoutLine.Insert();
                end;
            TempImportConfigHeader.TableName:
                begin
                    TmpTargetRef.SetTable(TempImportConfigHeader);
                    TempImportConfigHeader.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::"Import Config";
                    uniqueID := StrSubstNo('Zieltabelle: %1 - Quelle:%2',
                                           TempImportConfigHeader."Target Table Caption",
                                           TempImportConfigHeader."Source File Name");
                    tempImportWorksheetBuffer.UniqueID := CopyStr(uniqueID, 1, 250);
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            TempImportConfigLine.TableName:
                begin
                    TmpTargetRef.SetTable(TempImportConfigLine);
                    TempImportConfigLine.Insert();
                end;
            TempSourceFileStorage.TableName:
                begin
                    TmpTargetRef.SetTable(TempSourceFileStorage);
                    TempSourceFileStorage.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::"Source File";
                    tempImportWorksheetBuffer.UniqueID := StrSubstNo('%1', TempSourceFileStorage.Name);
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            TempProcessingPlanBatch.TableName:
                begin
                    TmpTargetRef.SetTable(TempProcessingPlanBatch);
                    TempProcessingPlanBatch.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::"Proc.Plan Batch";
                    tempImportWorksheetBuffer.UniqueID := StrSubstNo('%1', TempProcessingPlanBatch.Name);
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            TempProcessingPlan.TableName:
                begin
                    TmpTargetRef.SetTable(TempProcessingPlan);
                    TempProcessingPlan.Insert();
                end;
            TempReplacementHeader.TableName:
                begin
                    TmpTargetRef.SetTable(TempReplacementHeader);
                    TempReplacementHeader.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::Replacement;
                    tempImportWorksheetBuffer.UniqueID := StrSubstNo('%1 %2', TempReplacementHeader.Code, TempReplacementHeader.Description);
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            TempReplacementLine.TableName:
                begin
                    TmpTargetRef.SetTable(TempReplacementLine);
                    TempReplacementLine.Insert();
                end;
            TempCopyTable.TableName:
                begin
                    TmpTargetRef.SetTable(TempCopyTable);
                    TempCopyTable.Insert();
                    tempImportWorksheetBuffer.Type := Enum::DMTBackupEntity::"Copy Table";
                    TempCopyTable.CalcFields("Table Caption");
                    uniqueID := StrSubstNo('%1-%2', TempCopyTable.SourceCompanyName, TempCopyTable."Table Caption");
                    tempImportWorksheetBuffer.UniqueID := CopyStr(uniqueID, 1, 250);
                    tempImportWorksheetBuffer.SourceRecID := TmpTargetRef.RecordId;
                    tempImportWorksheetBuffer.Insert();
                end;
            else
                Error('Table %1 not implemented', TmpTargetRef.Name);
        end;
    end;

    local procedure openImportWorksheet(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary) OK: Boolean
    var
        importWorksheet: Page DMTImportWorksheet;
        runmodalAction: Action;
    begin
        OK := true;
        importWorksheet.setLines(tempImportWorksheetBuffer);
        importWorksheet.LookupMode(true);
        runmodalAction := importWorksheet.RunModal();
        if not (runmodalAction in [Action::LookupOK, Action::OK]) then
            exit(false);
        importWorksheet.getLines(tempImportWorksheetBuffer);
    end;

    procedure findImportActions(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary);
    begin
        tempImportWorksheetBuffer.Reset();
        if not tempImportWorksheetBuffer.FindSet() then
            exit;
        repeat
            findImportAction(tempImportWorksheetBuffer);
        until tempImportWorksheetBuffer.Next() = 0;
    end;

    local procedure findImportAction(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary)
    var
        importConfigHeader: Record DMTImportConfigHeader;
        sourceFileStorage, sourceFileStorageFrom : Record DMTSourceFileStorage;
        recordRef: RecordRef;
        nextID: Integer;
    begin
        Clear(tempImportWorksheetBuffer.mappedToID);
        tempImportWorksheetBuffer.ImportAction := tempImportWorksheetBuffer.ImportAction::Add;
        case tempImportWorksheetBuffer.Type of
            Enum::DMTBackupEntity::Setup,
            Enum::DMTBackupEntity::"Copy Table",
            Enum::DMTBackupEntity::"Data Layout",
            Enum::DMTBackupEntity::"Proc.Plan Batch",
            Enum::DMTBackupEntity::Replacement:
                begin
                    if recordRef.Get(tempImportWorksheetBuffer.SourceRecID) then
                        tempImportWorksheetBuffer.ImportAction := tempImportWorksheetBuffer.ImportAction::Replace;
                end;
            Enum::DMTBackupEntity::"Import Config":
                begin
                    // Replace if same source file and target table
                    TempImportConfigHeader.Get(tempImportWorksheetBuffer.SourceRecID);
                    importConfigHeader.SetRange("Source File Name", TempImportConfigHeader."Source File Name");
                    importConfigHeader.SetRange("Target Table ID", TempImportConfigHeader."Target Table ID");
                    if importConfigHeader.FindFirst() then begin
                        tempImportWorksheetBuffer.ImportAction := tempImportWorksheetBuffer.ImportAction::Replace;
                        tempImportWorksheetBuffer.mappedToID := importConfigHeader.ID;
                        // TODO Remapping of Import Config Header and Lines, Delete existing
                    end;
                end;
            Enum::DMTBackupEntity::"Source File":
                begin
                    TempSourceFileStorage.Get(tempImportWorksheetBuffer.SourceRecID);
                    // Case 1: Source File Storage exists with the same name
                    sourceFileStorage.SetRange(Name, TempSourceFileStorage.Name);
                    if sourceFileStorage.FindFirst() then begin
                        tempImportWorksheetBuffer.SourceRecID.GetRecord().SetTable(sourceFileStorageFrom);
                        tempImportWorksheetBuffer.ImportAction := tempImportWorksheetBuffer.ImportAction::Replace;
                        tempImportWorksheetBuffer.mappedToID := sourceFileStorage."File ID";
                        tempImportWorksheetBuffer.Modify();
                    end;

                    // Case 2: Source File Storage exists with the same ID
                    if tempImportWorksheetBuffer.mappedToID = 0 then begin
                        TempSourceFileStorage.Get(tempImportWorksheetBuffer.SourceRecID);
                        if sourceFileStorage.Get(TempSourceFileStorage."File ID") then begin
                            // getNextID
                            nextID := 1;
                            sourceFileStorage.Reset();
                            if sourceFileStorage.FindLast() then
                                nextID += sourceFileStorage."File ID";
                            tempImportWorksheetBuffer.mappedToID := nextID;
                            tempImportWorksheetBuffer.Modify();
                        end;
                    end;
                end;
            else
                Error('Type %1 not implemented', tempImportWorksheetBuffer.Type);
        end;
        tempImportWorksheetBuffer.Modify();
    end;

    local procedure DeleteExistingRecords(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary)
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        sourceFileStorage: Record DMTSourceFileStorage;
        recRef: RecordRef;
    begin
        tempImportWorksheetBuffer.Reset();
        if not tempImportWorksheetBuffer.FindSet() then
            exit;
        repeat
            if tempImportWorksheetBuffer.ImportAction = tempImportWorksheetBuffer.ImportAction::Replace then begin
                // Delete existing record
                case tempImportWorksheetBuffer.Type of
                    Enum::DMTBackupEntity::" ",
                    Enum::DMTBackupEntity::Setup,
                    Enum::DMTBackupEntity::"Copy Table",
                    Enum::DMTBackupEntity::"Data Layout",
                    Enum::DMTBackupEntity::"Proc.Plan Batch",
                    Enum::DMTBackupEntity::Replacement:
                        begin
                            recRef.Get(tempImportWorksheetBuffer.SourceRecID);
                            recRef.Delete(true);
                        end;
                    Enum::DMTBackupEntity::"Source File":
                        begin
                            sourceFileStorage.Get(tempImportWorksheetBuffer.SourceRecID);
                            sourceFileStorage.Delete();
                        end;
                    Enum::DMTBackupEntity::"Import Config":
                        begin
                            importConfigHeader.Get(tempImportWorksheetBuffer.SourceRecID);
                            importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader.ID);
                            importConfigLine.DeleteAll();
                            importConfigHeader.Delete();
                            //TODO GenBufferZeilen löschen?
                        end;
                    else
                        Error('Type %1 not implemented', tempImportWorksheetBuffer.Type);
                end;
            end;
        until tempImportWorksheetBuffer.Next() = 0;
    end;

    internal procedure SaveRecords(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary)
    begin
        tempImportWorksheetBuffer.Reset();
        if not tempImportWorksheetBuffer.FindSet() then
            exit;
        repeat
            SaveRecordFor(tempImportWorksheetBuffer);
        until tempImportWorksheetBuffer.Next() = 0;
    end;

    local procedure SaveRecordFor(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary)
    var
        setup: Record DMTSetup;
        sourceFileStorage: Record DMTSourceFileStorage;
        copyTable: Record DMTCopyTable;
        dataLayout: Record DMTDataLayout;
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        processingPlanBatch: Record DMTProcessingPlanBatch;
        processingPlan: Record DMTProcessingPlan;
        replacementHeader: Record DMTReplacementHeader;
        replacementLine: Record DMTReplacementLine;
        recRef: RecordRef;
    begin

        if not (tempImportWorksheetBuffer.ImportAction in [tempImportWorksheetBuffer.ImportAction::Replace,
                                                      tempImportWorksheetBuffer.ImportAction::Add]) then
            exit;

        // Delete existing record
        case tempImportWorksheetBuffer.Type of
            Enum::DMTBackupEntity::" ":
                ;
            Enum::DMTBackupEntity::"Source File":
                begin
                    TempSourceFileStorage.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempSourceFileStorage);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(sourceFileStorage);
                    sourceFileStorage.Insert();
                end;
            Enum::DMTBackupEntity::Setup:
                begin
                    TempSetup.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempSetup);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(setup);
                    setup.Insert();
                end;
            Enum::DMTBackupEntity::"Copy Table":
                begin
                    TempCopyTable.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempCopyTable);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(copyTable);
                    copyTable.Insert();
                end;
            Enum::DMTBackupEntity::"Data Layout":
                begin
                    TempDataLayout.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempDataLayout);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(dataLayout);
                    dataLayout.Insert();
                end;
            Enum::DMTBackupEntity::"Import Config":
                begin
                    TempImportConfigHeader.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempImportConfigHeader);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(importConfigHeader);
                    importConfigHeader.Insert();

                    TempImportConfigLine.Reset();
                    TempImportConfigLine.SetRange("Imp.Conf.Header ID", TempImportConfigHeader.ID);
                    if TempImportConfigLine.FindSet() then
                        repeat
                            recRef.GetTable(TempImportConfigLine);
                            CalcAllBlobFields(recRef);
                            recRef.SetTable(importConfigLine);
                            importConfigLine.Insert();
                        until TempImportConfigLine.Next() = 0;
                end;
            Enum::DMTBackupEntity::"Proc.Plan Batch":
                begin
                    TempProcessingPlanBatch.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempProcessingPlanBatch);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(processingPlanBatch);
                    processingPlanBatch.Insert();

                    processingPlan.Reset();
                    processingPlan.SetRange("Journal Batch Name", processingPlanBatch.Name);
                    if processingPlan.FindSet() then
                        repeat
                            recRef.GetTable(processingPlan);
                            CalcAllBlobFields(recRef);
                            recRef.SetTable(importConfigLine);
                            importConfigLine.Insert();
                        until processingPlan.Next() = 0;
                end;
            Enum::DMTBackupEntity::Replacement:
                begin
                    TempReplacementHeader.get(tempImportWorksheetBuffer.SourceRecID);
                    recRef.GetTable(TempReplacementHeader);
                    CalcAllBlobFields(recRef);
                    recRef.SetTable(replacementHeader);
                    replacementHeader.Insert();

                    TempReplacementLine.Reset();
                    TempReplacementLine.SetRange("Replacement Code", TempReplacementHeader.Code);
                    if TempReplacementLine.FindSet() then
                        repeat
                            recRef.GetTable(TempReplacementLine);
                            CalcAllBlobFields(recRef);
                            recRef.SetTable(replacementLine);
                            replacementLine.Insert();
                        until TempReplacementLine.Next() = 0;
                end;
            else
                Error('Type %1 not implemented', tempImportWorksheetBuffer.Type);
        end;
    end;

    local procedure CalcAllBlobFields(var targetRef: RecordRef)
    var
        i: Integer;
    begin
        // calculate all blob fields
        for i := 1 to targetRef.FieldCount do
            if targetRef.FieldIndex(i).Type = FieldType::Blob then
                targetRef.FieldIndex(i).CalcField();
    end;

    internal procedure RenameIncomingRecordsIfRequired(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary)
    begin
        tempImportWorksheetBuffer.Reset();
        if not tempImportWorksheetBuffer.FindSet() then
            exit;
        repeat
            RenameIncomingRecordIfRequired(tempImportWorksheetBuffer);
        until tempImportWorksheetBuffer.Next() = 0;
    end;

    local procedure RenameIncomingRecordIfRequired(var tempImportWorksheetBuffer: Record DMTImportWorksheetBuffer temporary)
    begin
        if tempImportWorksheetBuffer.mappedToID = 0 then
            exit;
        case tempImportWorksheetBuffer.Type of
            Enum::DMTBackupEntity::"Copy Table",
            Enum::DMTBackupEntity::"Proc.Plan Batch",
            Enum::DMTBackupEntity::Replacement:
                ;// No mapping required
            Enum::DMTBackupEntity::"Source File":
                begin
                    TempSourceFileStorage.get(tempImportWorksheetBuffer.SourceRecID);

                    TempImportConfigHeader.Reset();
                    TempImportConfigHeader.SetRange("Source File ID", TempSourceFileStorage."File ID");
                    TempImportConfigHeader.ModifyAll("Source File ID", tempImportWorksheetBuffer.mappedToID);

                    TempSourceFileStorage.Rename(tempImportWorksheetBuffer.mappedToID);
                    tempImportWorksheetBuffer.SourceRecID := TempSourceFileStorage.RecordId;
                    tempImportWorksheetBuffer.Modify();
                end;
            Enum::DMTBackupEntity::"Data Layout":
                begin
                    TempDataLayout.get(tempImportWorksheetBuffer.SourceRecID);

                    // Source File Storage Reference
                    TempSourceFileStorage.Reset();
                    TempSourceFileStorage.SetRange("Data Layout ID", TempDataLayout.ID);
                    TempSourceFileStorage.ModifyAll("Data Layout ID", tempImportWorksheetBuffer.mappedToID);

                    TempDataLayout.Rename(tempImportWorksheetBuffer.mappedToID);
                    tempImportWorksheetBuffer.SourceRecID := TempDataLayout.RecordId;
                    tempImportWorksheetBuffer.Modify();
                end;
            Enum::DMTBackupEntity::"Import Config":
                begin
                    TempImportConfigHeader.get(tempImportWorksheetBuffer.SourceRecID);

                    if (tempImportWorksheetBuffer.mappedToID <> TempImportConfigHeader.ID) and (tempImportWorksheetBuffer.mappedToID <> 0) then begin
                        TempImportConfigLine.Reset();
                        TempImportConfigLine.SetRange("Imp.Conf.Header ID", TempImportConfigHeader.ID);
                        while TempImportConfigLine.FindFirst() do begin
                            TempImportConfigLine.Rename(tempImportWorksheetBuffer.mappedToID, TempImportConfigLine."Target Field No.");
                        end;
                    end;

                    TempReplacementLine.Reset();
                    TempReplacementLine.SetRange("Imp.Conf.Header ID", TempImportConfigHeader.ID);
                    TempReplacementLine.ModifyAll("Imp.Conf.Header ID", tempImportWorksheetBuffer.mappedToID);

                    TempProcessingPlan.Reset();
                    if TempProcessingPlan.FindSet() then
                        repeat
                            if TempProcessingPlan.TypeSupportsImportConfigHeader() then
                                if TempProcessingPlan.ID = TempImportConfigHeader.ID then begin
                                    TempProcessingPlan.ID := tempImportWorksheetBuffer.mappedToID;
                                    TempProcessingPlan.Modify();
                                end;
                        until TempProcessingPlan.Next() = 0;

                    TempImportConfigHeader.Rename(tempImportWorksheetBuffer.mappedToID);
                    tempImportWorksheetBuffer.SourceRecID := TempImportConfigHeader.RecordId;
                    tempImportWorksheetBuffer.Modify();
                end;
            else
                Error('Type %1 not implemented', tempImportWorksheetBuffer);
        end;
    end;

    internal procedure MarkRecordForExport(recID: RecordId)
    var
        recIDList: List of [RecordId];
    begin
        // add table entry with empty list if not exists
        if not GlobalRecordIDList.ContainsKey(recID.TableNo) then
            GlobalRecordIDList.Add(recID.TableNo, recIDList);
        // add record id
        if not GlobalRecordIDList.Get(recID.TableNo).Contains(recID) then
            GlobalRecordIDList.Get(recID.TableNo).Add(recID);
    end;

    procedure DownloadFile(var tempBlob: Codeunit "Temp Blob"; FileName: Text; FileEncoding: TextEncoding): Text
    var
        FileMgt: Codeunit "File Management";
        IsDownloaded: Boolean;
        InStr: InStream;
        OutExt: Text;
        Path: Text;
        AllFilesDescriptionTxt: TextConst DEU = 'Alle Dateien (*.*)|*.*', ENU = 'All Files (*.*)|*.*';
        ExcelFileTypeTok: TextConst DEU = 'Excel-Dateien (*.xlsx)|*.xlsx', ENU = 'Excel Files (*.xlsx)|*.xlsx';
        ExportLbl: TextConst DEU = 'Export', ENU = 'Export';
        RDLFileTypeTok: TextConst DEU = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', ENU = 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc';
        TXTFileTypeTok: TextConst DEU = 'Textdateien (*.txt)|*.txt', ENU = 'Text Files (*.txt)|*.txt';
        XMLFileTypeTok: TextConst DEU = 'XML-Dateien (*.xml)|*.xml', ENU = 'XML Files (*.xml)|*.xml';
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        case UpperCase(FileMgt.GetExtension(FileName)) of
            'XLSX':
                OutExt := ExcelFileTypeTok;
            'XML':
                OutExt := XMLFileTypeTok;
            'TXT':
                OutExt := TXTFileTypeTok;
            'RDL', 'RDLC':
                OutExt := RDLFileTypeTok;
            'ZIP':
                OutExt := ZIPFileTypeTok;
        end;
        if OutExt = '' then
            OutExt := AllFilesDescriptionTxt
        else
            OutExt += '|' + AllFilesDescriptionTxt;

        tempBlob.CreateInStream(InStr, FileEncoding);
        IsDownloaded := DownloadFromStream(InStr, ExportLbl, Path, OutExt, FileName);
        if IsDownloaded then
            exit(FileName);
        exit('');
    end;

    procedure GetMediaFieldAsText(var FldRef: FieldRef; Base64Encode: Boolean; var MediaContentAsText: Text) OK: Boolean
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        MediaID: Guid;
        IStream: InStream;
    begin
        Clear(MediaContentAsText);
        if FldRef.Type <> FieldType::Media then
            exit(false);
        if not Evaluate(MediaID, Format(FldRef.Value)) then
            exit(false);
        if (Format(FldRef.Value) = '') then
            exit(true);
        if IsNullGuid(MediaID) then
            exit(true);
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue then begin
            TenantMedia.Content.CreateInStream(IStream);
            if Base64Encode then
                MediaContentAsText := Base64Convert.ToBase64(IStream)
            else
                IStream.ReadText(MediaContentAsText);
        end;
    end;

    procedure GetBlobFieldAsText(var FldRef: FieldRef; Base64Encode: Boolean; var BlobContentAsText: Text) OK: Boolean
    var
        TenantMedia: Record "Tenant Media";
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        OK := true;
        TenantMedia.Content := FldRef.Value;
        if not TenantMedia.Content.HasValue then
            exit(false);
        TenantMedia.Content.CreateInStream(IStream);
        if Base64Encode then
            BlobContentAsText := Base64Convert.ToBase64(IStream)
        else
            IStream.ReadText(BlobContentAsText);
    end;

    #region Import Buffer Globals
    var
        TempImportConfigLine: Record DMTImportConfigLine temporary;
        TempImportConfigHeader: Record DMTImportConfigHeader temporary;
        TempSourceFileStorage: Record DMTSourceFileStorage temporary;
        TempDataLayout: Record DMTDataLayout temporary;
        TempDataLayoutLine: Record DMTDataLayoutLine temporary;
        TempProcessingPlanBatch: Record DMTProcessingPlanBatch temporary;
        TempProcessingPlan: Record DMTProcessingPlan temporary;
        TempSetup: Record DMTSetup temporary;
        TempReplacementHeader: Record DMTReplacementHeader temporary;
        TempReplacementLine: Record DMTReplacementLine temporary;
        TempCopyTable: Record DMTCopyTable temporary;
    #endregion Import Buffer Globals
    var
        GlobalRecordIDList: Dictionary of [Integer, List of [RecordId]];
        ExcludedFields: Dictionary of [Integer, List of [Integer]];
}