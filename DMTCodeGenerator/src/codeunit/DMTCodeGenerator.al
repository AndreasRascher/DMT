codeunit 90000 DMTCodeGenerator
{

    procedure CreateALXMLPort(ImportConfigHeader: Record DMTImportConfigHeader) C: TextBuilder
    begin
        ImportConfigHeader.TestField("Import XMLPort ID");
        ImportConfigHeader.GetDataLayout().TestField(NAVTableID);
        ImportConfigHeader.GetDataLayout().TestField(NAVTableCaption);
        C := CreateALXMLPort(ImportConfigHeader."Import XMLPort ID", ImportConfigHeader.GetDataLayout(), ImportConfigHeader.GetDataLayout().NAVTableID, ImportConfigHeader.GetDataLayout().NAVTableCaption);
    end;

    local procedure CreateALXMLPort(ImportXMLPortID: Integer; dataLayout: Record DMTDataLayout; NAVTableID: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTDataLayoutLine: Record DMTDataLayoutLine;
        DMTSetup: Record DMTSetup;
        HasFieldsInFilter: Boolean;
    begin
        HasFieldsInFilter := FilterFields(DMTDataLayoutLine, dataLayout, false, DMTSetup."Import with FlowFields", false);
        C.AppendLine('xmlport ' + Format(ImportXMLPortID) + ' T' + Format(dataLayout.NAVTableID) + 'Import');
        C.AppendLine('{');
        DMTSetup.Get();
        if DMTSetup."Import with FlowFields" then
            C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + 'FlowField' + ''', ENU = ''' + DMTDataLayoutLine.TableName + '(DMT)' + ''';')
        else
            C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + DMTDataLayoutLine.TableName + '(DMT)' + ''';');
        C.AppendLine('    Direction = Import;');
        C.AppendLine('    FieldSeparator = ''<TAB>'';');
        C.AppendLine('    FieldDelimiter = ''<None>'';');
        C.AppendLine('    TextEncoding = UTF8;');
        C.AppendLine('    Format = VariableText;');
        C.AppendLine('    FormatEvaluate = Xml;');
        C.AppendLine('');
        C.AppendLine('    schema');
        C.AppendLine('    {');
        C.AppendLine('        textelement(Root)');
        C.AppendLine('        {');

        if HasFieldsInFilter then begin
            C.AppendLine('            tableelement(' + GetCleanTableName(DMTDataLayoutLine) + '; ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(DMTDataLayoutLine) + ''';');
            DMTDataLayoutLine.FindSet();
            repeat
                C.AppendLine('                fieldelement("' + GetCleanFieldName(DMTDataLayoutLine) + '"; ' + GetCleanTableName(DMTDataLayoutLine) + '."' + DMTDataLayoutLine.ColumnName + '") { FieldValidate = No; MinOccurs = Zero; }');
            until DMTDataLayoutLine.Next() = 0;
        end;

        C.AppendLine('                trigger OnBeforeInsertRecord()');
        C.AppendLine('                begin');
        C.AppendLine('                    ReceivedLinesCount += 1;');
        C.AppendLine('                end;');
        C.AppendLine('');
        C.AppendLine('                trigger OnAfterInitRecord()');
        C.AppendLine('                begin');
        C.AppendLine('                    if FileHasHeader then begin');
        C.AppendLine('                        FileHasHeader := false;');
        C.AppendLine('                        currXMLport.Skip();');
        C.AppendLine('                    end;');
        C.AppendLine('                end;');
        C.AppendLine('            }');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    requestpage');
        C.AppendLine('    {');
        C.AppendLine('        layout');
        C.AppendLine('        {');
        C.AppendLine('            area(content)');
        C.AppendLine('            {');
        C.AppendLine('                group(Umgebung)');
        C.AppendLine('                {');
        C.AppendLine('                    Caption = ''Environment'',locked=true;');
        C.AppendLine('                    field(DatabaseName; GetDatabaseName()) { Caption = ''Database'',locked=true; ApplicationArea = all; }');
        C.AppendLine('                    field(COMPANYNAME; COMPANYNAME) { Caption = ''Company'',locked=true; ApplicationArea = all; }');
        C.AppendLine('                }');
        C.AppendLine('            }');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    trigger OnPostXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + ': Record ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + ';');
        C.AppendLine('        LinesProcessedMsg: Label ''%1 Buffer\%2 lines imported'',locked=true;');
        C.AppendLine('    begin');
        C.AppendLine('        IF currXMLport.Filename <> '''' then //only for manual excecution');
        C.AppendLine('            MESSAGE(LinesProcessedMsg, ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + '.TABLECAPTION, ReceivedLinesCount);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    trigger OnPreXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + ': Record ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + ';');
        C.AppendLine('    begin');
        C.AppendLine('        ClearBufferBeforeImportTable(' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID) + '.RECORDID.TABLENO);');
        C.AppendLine('        FileHasHeader := true;');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    var');
        C.AppendLine('        ReceivedLinesCount: Integer;');
        C.AppendLine('        FileHasHeader: Boolean;');
        C.AppendLine('');
        // C.AppendLine('    procedure GetFieldCaption(_TableNo: Integer;');
        // C.AppendLine('    _FieldNo: Integer) _FieldCpt: Text[1024]');
        // C.AppendLine('    var');
        // C.AppendLine('        _Field: Record "Field";');
        // C.AppendLine('    begin');
        // C.AppendLine('        IF _TableNo = 0 then exit('''');');
        // C.AppendLine('        IF _FieldNo = 0 then exit('''');');
        // C.AppendLine('        IF NOT _Field.GET(_TableNo, _FieldNo) then exit('''');');
        // C.AppendLine('        _FieldCpt := _Field."Field Caption";');
        // C.AppendLine('    end;');
        // C.AppendLine('');
        C.AppendLine('    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]');
        C.AppendLine('    var');
        C.AppendLine('        CharArray: Text[30];');
        C.AppendLine('    begin');
        C.AppendLine('        CharArray[1] := 9; // TAB');
        C.AppendLine('        CharArray[2] := 10; // LF');
        C.AppendLine('        CharArray[3] := 13; // CR');
        C.AppendLine('        exit(DELCHR(TextIn, ''='', CharArray));');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)');
        C.AppendLine('    var');
        C.AppendLine('        BufferRef: RecordRef;');
        C.AppendLine('    begin');
        C.AppendLine('        //* Puffertabelle l”schen vor dem Import');
        C.AppendLine('        IF NOT currXMLport.IMPORTFILE then');
        C.AppendLine('            exit;');
        C.AppendLine('        IF BufferTableNo < 50000 then begin');
        C.AppendLine('            MESSAGE(''Achtung: Puffertabellen ID kleiner 50000'');');
        C.AppendLine('            exit;');
        C.AppendLine('        end;');
        C.AppendLine('        BufferRef.OPEN(BufferTableNo);');
        C.AppendLine('        IF NOT BufferRef.IsEmpty then');
        C.AppendLine('            BufferRef.DELETEALL();');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    procedure GetDatabaseName(): Text[250]');
        C.AppendLine('    var');
        C.AppendLine('        ActiveSession: Record "Active Session";');
        C.AppendLine('    begin');
        C.AppendLine('        ActiveSession.SetRange("Server Instance ID", SERVICEINSTANCEID());');
        C.AppendLine('        ActiveSession.SetRange("Session ID", SESSIONID());');
        C.AppendLine('        ActiveSession.findfirst();');
        C.AppendLine('        exit(ActiveSession."Database Name");');
        C.AppendLine('    end;');
        C.AppendLine('}');
    end;

    procedure CreateALTable(ImportConfigHeader: Record DMtImportConfigHeader) C: TextBuilder
    begin
        ImportConfigHeader.TestField("Buffer Table ID");
        ImportConfigHeader.GetDataLayout().TestField(NAVTableID);
        ImportConfigHeader.GetDataLayout().TestField(NAVTableCaption);
        C := CreateALTable(ImportConfigHeader."Target Table ID", ImportConfigHeader."Buffer Table ID", ImportConfigHeader.GetDataLayout(), ImportConfigHeader.GetDataLayout().NAVTableCaption);
    end;

    local procedure CreateALTable(TargetTableID: Integer; BufferTableID: Integer; dataLayout: Record DMTDataLayout; NAVSrcTableCaption: Text) C: TextBuilder
    var
        dataLayoutLine: Record DMTDataLayoutLine;
        DMTSetup: Record DMTSetup;
        _FieldTypeText: Text;
    begin
        DMTSetup.Get();
        FilterFields(dataLayoutLine, dataLayout, false, true, false);
        C.AppendLine('table ' + Format(BufferTableID) + ' ' + StrSubstNo('T%1Buffer', dataLayout.NAVTableID));
        C.AppendLine('{');
        C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + dataLayoutLine.TableName + '(DMT)' + ''';');
        C.AppendLine('  fields {');
        if FilterFields(dataLayoutLine, dataLayout, false, DMTSetup."Import with FlowFields", false) then
            repeat
                case dataLayoutLine.NAVDataType of
                    dataLayoutLine.NAVDataType::RecordID:
                        _FieldTypeText := 'Text[250]'; // Import recordIDs as text to avoid validation issues on import
                    dataLayoutLine.NAVDataType::Code, dataLayoutLine.NAVDataType::Text:
                        _FieldTypeText := StrSubstNo('%1[%2]', dataLayoutLine.NAVDataType, dataLayoutLine.NAVLen);
                    else
                        _FieldTypeText := Format(dataLayoutLine.NAVDataType);
                end;
                C.AppendLine(StrSubstNo('        field(%1; "%2"; %3)', dataLayoutLine."Column No.", dataLayoutLine.ColumnName, _FieldTypeText));
                // field(1; "No."; Code[20])
                C.AppendLine('        {');
                C.AppendLine(StrSubstNo('            CaptionML = ENU = ''%1'', DEU = ''%2'';', dataLayoutLine.ColumnName, dataLayoutLine.ColumnName));

                if dataLayoutLine.NAVDataType = dataLayoutLine.NAVDataType::Option then begin
                    C.AppendLine('            OptionMembers = ' + dataLayoutLine.NAVOptionString + ';');
                    C.AppendLine(StrSubstNo('            OptionCaptionML = ENU = ''%1'', DEU = ''%2'';', DelChr(dataLayoutLine.NAVOptionString, '=', '"'), DelChr(dataLayoutLine.NAVOptionCaption, '=', '"')));
                end;

                C.AppendLine('        }');

            until dataLayoutLine.Next() = 0;
        AddTargetRecordExistsFlowField(TargetTableID, dataLayout, dataLayoutLine, C);
        C.AppendLine('  }');
        C.AppendLine('    keys');
        C.AppendLine('    {');
        C.AppendLine('        key(Key1; ' + BuildKeyFieldsString(dataLayout.NAVTableID) + ')');
        C.AppendLine('        {');
        C.AppendLine('            Clustered = true;');
        C.AppendLine('        }');
        C.AppendLine('    }');
        C.AppendLine('');
        C.AppendLine('    fieldgroups');
        C.AppendLine('    {');
        C.AppendLine('    }');
        C.AppendLine('}');
    end;

    procedure DownloadFile(Content: TextBuilder; toFileName: Text)
    var
        tempBlob: Codeunit "Temp Blob";
        iStr: InStream;
        oStr: OutStream;
    begin
        tempBlob.CreateOutStream(oStr, TextEncoding::UTF8);  // Import / Export as UTF-8
        oStr.WriteText(Content.ToText());
        tempBlob.CreateInStream(iStr);
        toFileName := DelChr(toFileName, '=', '#&-%/\(), ');
        DownloadFromStream(iStr, 'Download', 'ToFolder', Format(Enum::DMTFileFilter::All), toFileName);
    end;

    local procedure GetCleanFieldName(var Field: Record DMTDataLayoutLine) CleanFieldName: Text
    begin
        CleanFieldName := DelChr(Field.ColumnName, '=', '#&-%/\(),. ');
        // XMLPort Fieldelements cannot start with numbers
        if CleanFieldName <> '' then
            if CopyStr(CleanFieldName, 1, 1) in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] then
                CleanFieldName := '_' + CleanFieldName;
    end;

    local procedure GetCleanTableName(Field: Record DMTDataLayoutLine) CleanFieldName: Text
    begin
        CleanFieldName := ConvertStr(Field.TableName, '&-%/\(),. ', '__________');
    end;

    procedure FilterFields(var DataLayoutLine_FOUND: Record DMTDataLayoutLine; DataLayout: Record DMTDataLayout; includeDisabled: Boolean; IncludeFlowFields: Boolean; IncludeBlob: Boolean) hasFields: Boolean
    var
        Debug: Integer;
    begin
        //* FilterField({TableNo}False{IncludeEnabled},False{IncludeFlowFields},False{IncludeBlob});
        Clear(DataLayoutLine_FOUND);
        DataLayoutLine_FOUND.SetRange("Data Layout ID", DataLayout.ID);
        Debug := DataLayoutLine_FOUND.Count;
        if not includeDisabled then
            DataLayoutLine_FOUND.SetRange(NAVEnabled, true);
        Debug := DataLayoutLine_FOUND.Count;
        DataLayoutLine_FOUND.SetFilter(NAVClass, '%1|%2', DataLayoutLine_FOUND.NAVClass::Normal, DataLayoutLine_FOUND.NAVClass::FlowField);
        if not IncludeFlowFields then
            DataLayoutLine_FOUND.SetRange(NAVClass, DataLayoutLine_FOUND.NAVClass::Normal);
        if not IncludeBlob then
            DataLayoutLine_FOUND.SetFilter(NAVDataType, '<>%1', DataLayoutLine_FOUND.NAVDataType::BLOB);
        // Fields_Found.SetRange(FieldName, 'Picture');
        // if Fields_Found.FindFirst() then;
        Debug := DataLayoutLine_FOUND.Count;
        DataLayoutLine_FOUND.SetRange(ColumnName);
        hasFields := DataLayoutLine_FOUND.FindFirst();
    end;

    local procedure BuildKeyFieldsString(TableIDInNAV: Integer) KeyString: Text
    var
        DataLayoutLine: Record DMTDataLayoutLine;
        DataLayout: record DMTDataLayout;
        FieldID: Integer;
        FieldIds: List of [Text];
        FieldIDText: Text;
        OrderedKeyFieldNos: Text;
    begin
        DataLayout.SetRange(NAVTableID, TableIDInNAV);
        DataLayout.FindFirst();
        OrderedKeyFieldNos := DataLayout.NAVPrimaryKey;
        if OrderedKeyFieldNos.Contains(',') then begin
            FieldIds := OrderedKeyFieldNos.Split(',');
        end else begin
            FieldIds.Add(OrderedKeyFieldNos);
        end;

        foreach FieldIDText in FieldIds do begin
            Evaluate(FieldID, FieldIDText);
            DataLayoutLine.Get(TableIDInNAV, FieldID);
            KeyString += GetALFieldNameWithMasking(DataLayoutLine.ColumnName) + ',';
        end;
        KeyString := DelChr(KeyString, '>', ',');
    end;

    local procedure AddTargetRecordExistsFlowField(TargetTableID: Integer; DataLayout: Record DMTDataLayout; var DataLayoutLine: Record DMTDataLayoutLine; var C: TextBuilder)
    var
        RefHelper: Codeunit DMTRefHelper;
        TargetRef: RecordRef;
        TargetTableName: Text;
        BufferKeyFieldNames, TargetKeyFieldNames : List of [Text];
        KeyFieldIndex: Integer;
        f: TextBuilder;
    begin

        // FieldNoIsReservedForNewField
        if DataLayoutLine.Get(DataLayout.ID, 59999) then
            exit;
        // FindTargetTableKeyInfo
        TargetRef.Open(TargetTableID);
        TargetTableName := QuoteValue(TargetRef.Name);
        for KeyFieldIndex := 1 to RefHelper.GetListOfKeyFieldIDs(TargetRef).Count do
            TargetKeyFieldNames.Add(QuoteValue(TargetRef.KeyIndex(1).FieldIndex(KeyFieldIndex).Name));
        // FindSourceTableKeyInfo
        DataLayoutLine.FindFirst();
        for KeyFieldIndex := 1 to DataLayout.NAVPrimaryKey.Split(',').Count do
            if DataLayoutLine.Get(DataLayout.NAVTableID, DataLayout.NAVPrimaryKey.Split(',').Get(KeyFieldIndex)) then
                BufferKeyFieldNames.Add(QuoteValue(DataLayoutLine.ColumnName));

        if TargetKeyFieldNames.Count <> BufferKeyFieldNames.Count then
            exit;

        f.AppendLine('        field(59999; "DMT Target Record Exists"; Boolean)');
        f.AppendLine('        {');
        f.AppendLine('            CaptionML = ENU = ''DMT target record exists'', DEU = ''DMT Zieldatensatz vorhanden'';');
        f.AppendLine('            FieldNAVClass = FlowField;');

        for KeyFieldIndex := 1 to TargetKeyFieldNames.Count do begin
            if KeyFieldIndex = 1 then
                f.Append('            CalcFormula = exist(' + TargetTableName + ' where(' + TargetKeyFieldNames.Get(KeyFieldIndex) + '= field(' + BufferKeyFieldNames.Get(KeyFieldIndex) + ')')
            else begin
                f.AppendLine('');
                f.Append('                                                     ' + TargetKeyFieldNames.Get(KeyFieldIndex) + '= field(' + BufferKeyFieldNames.Get(KeyFieldIndex) + ')');
            end;
            if KeyFieldIndex = TargetKeyFieldNames.Count then
                f.AppendLine('));')
            else
                f.Append(',')
        end;

        f.AppendLine('            Editable = false;');
        f.AppendLine('        }');
        C.Append(f.ToText());
    end;

    local procedure QuoteValue(TextValue: Text): Text
    var
        DummyText: Text;
    begin
        DummyText := DelChr(TextValue.ToLower(), '=', 'abcdefghijklmnopqrstuvwxyz');
        DummyText := DelChr(DummyText, '=', '0123456789');
        if DummyText <> '' then
            exit('"' + TextValue + '"')
        else
            exit(TextValue);
    end;

    procedure GetALFieldNameWithMasking(FieldName: Text) MaskedFieldName: Text
    var
        LettersTok: Label 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', Locked = true;
    begin
        if DelChr(FieldName, '=', LettersTok) = '' then
            MaskedFieldName := FieldName
        else
            MaskedFieldName := '"' + FieldName + '"';
    end;

    // procedure ImportNAVSchemaFile()
    // var
    //     TempBlob: Codeunit "Temp Blob";
    //     FieldImport: XmlPort "DMT NAVFieldBufferImport";
    //     InStr: InStream;
    //     ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
    //     FileName: Text;
    // begin
    //     TempBlob.CreateInStream(InStr);
    //     if not UploadIntoStream('Select a Schema.csv file', '', Format(Enum::DMTFileFilter::CSV), FileName, InStr) then begin
    //         exit;
    //     end;
    //     FieldImport.SetSource(InStr);
    //     FieldImport.Import();

    //     migrateNAVSchemaToDataLayout();

    //     Message(ImportFinishedMsg);
    // end;

    // local procedure migrateNAVSchemaToDataLayout()
    // var
    //     dataLayout: Record DMTDataLayout;
    //     dataLayoutLine: Record DMTDataLayoutLine;
    //     NAVFieldBuffer: Record "DMT NAVFieldBuffer";
    //     TableIDs: List of [Integer];
    //     TableID: Integer;
    // begin
    //     if NAVFieldBuffer.IsEmpty then exit;
    //     while NAVFieldBuffer.FindFirst() do begin
    //         TableIDs.Add(NAVFieldBuffer.TableNo);
    //         NAVFieldBuffer.SetFilter(TableNo, StrSubstNo('>%1', NAVFieldBuffer.TableNo));
    //     end;
    //     foreach TableID in TableIDs do begin
    //         // delete old
    //         dataLayout.Reset();
    //         dataLayout.SetRange(NAVTableID, TableID);
    //         if dataLayout.FindFirst() then
    //             dataLayout.DeleteAll(true);
    //         // load fields
    //         NAVFieldBuffer.Reset();
    //         NAVFieldBuffer.FindSet(false);
    //         NAVFieldBuffer.SetRange(TableNo, TableID);
    //         NAVFieldBuffer.FindSet();
    //         // add header
    //         Clear(dataLayout);
    //         dataLayout.Name := NAVFieldBuffer.TableName;
    //         dataLayout.SourceFileFormat := dataLayout.SourceFileFormat::"NAV CSV Export";
    //         dataLayout.NAVTableID := NAVFieldBuffer.TableNo;
    //         dataLayout.NAVNoOfRecords := NAVFieldBuffer."No. of Records";
    //         dataLayout.NAVPrimaryKey := NAVFieldBuffer."Primary Key";
    //         dataLayout.NAVTableCaption := NAVFieldBuffer."Table Caption";
    //         dataLayout.Insert(true);
    //         repeat
    //             Clear(dataLayoutLine);

    //             dataLayoutLine."Data Layout ID" := dataLayout.ID;
    //             dataLayoutLine."Column No." := NAVFieldBuffer."No.";
    //             dataLayoutLine.ColumnName := NAVFieldBuffer.FieldName;
    //             dataLayoutLine.NAVFieldCaption := NAVFieldBuffer."Field Caption";
    //             dataLayoutLine."NAV Primary Key" := NAVFieldBuffer."Primary Key";
    //             dataLayoutLine."NAV Table Caption" := NAVFieldBuffer."Table Caption";
    //             dataLayoutLine.NAVClass := NAVFieldBuffer.Class;
    //             dataLayoutLine.NAVDataType := NAVFieldBuffer.Type;
    //             dataLayoutLine.NAVEnabled := NAVFieldBuffer.Enabled;
    //             dataLayoutLine.NAVLen := NAVFieldBuffer.Len;

    //             dataLayoutLine.Insert(true);
    //         until NAVFieldBuffer.Next() = 0;
    //     end;
    // end;

}
