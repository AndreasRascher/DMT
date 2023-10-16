codeunit 90011 DMTCodeGenerator
{

    procedure CreateALXMLPort(ImportConfigHeader: Record DMTImportConfigHeader) C: TextBuilder
    begin
        ImportConfigHeader.TestField("Import XMLPort ID");
        ImportConfigHeader.TestField("NAV Src.Table No.");
        ImportConfigHeader.TestField("NAV Src.Table Caption");
        C := CreateALXMLPort(ImportConfigHeader."Import XMLPort ID", ImportConfigHeader."NAV Src.Table No.", ImportConfigHeader."NAV Src.Table Caption");
    end;

    local procedure CreateALXMLPort(ImportXMLPortID: Integer; NAVSrcTableNo: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
        HasFieldsInFilter: Boolean;
    begin
        HasFieldsInFilter := FilterFields(DMTFieldBuffer, NAVSrcTableNo, false, DMTSetup."Import with FlowFields", false);
        C.AppendLine('xmlport ' + Format(ImportXMLPortID) + ' T' + Format(NAVSrcTableNo) + 'Import');
        C.AppendLine('{');
        DMTSetup.Get();
        if DMTSetup."Import with FlowFields" then
            C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + 'FlowField' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';')
        else
            C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';');
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
            C.AppendLine('            tableelement(' + GetCleanTableName(DMTFieldBuffer) + '; ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(DMTFieldBuffer) + ''';');
            DMTFieldBuffer.FindSet();
            repeat
                C.AppendLine('                fieldelement("' + GetCleanFieldName(DMTFieldBuffer) + '"; ' + GetCleanTableName(DMTFieldBuffer) + '."' + DMTFieldBuffer.FieldName + '") { FieldValidate = No; MinOccurs = Zero; }');
            until DMTFieldBuffer.Next() = 0;
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
        C.AppendLine('        ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + ': Record ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + ';');
        C.AppendLine('        LinesProcessedMsg: Label ''%1 Buffer\%2 lines imported'',locked=true;');
        C.AppendLine('    begin');
        C.AppendLine('        IF currXMLport.Filename <> '''' then //only for manual excecution');
        C.AppendLine('            MESSAGE(LinesProcessedMsg, ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + '.TABLECAPTION, ReceivedLinesCount);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    trigger OnPreXmlPort()');
        C.AppendLine('    var');
        C.AppendLine('        ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + ': Record ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + ';');
        C.AppendLine('    begin');
        C.AppendLine('        ClearBufferBeforeImportTable(' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + '.RECORDID.TABLENO);');
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

    procedure CreateALTable(ImportConfigHeader: Record DMTImportConfigHeader) C: TextBuilder
    begin
        ImportConfigHeader.TestField("Buffer Table ID");
        ImportConfigHeader.TestField("NAV Src.Table No.");
        ImportConfigHeader.TestField("NAV Src.Table Caption");
        C := CreateALTable(ImportConfigHeader."Target Table ID", ImportConfigHeader."Buffer Table ID", ImportConfigHeader."NAV Src.Table No.", ImportConfigHeader."NAV Src.Table Caption");
    end;

    local procedure CreateALTable(TargetTableID: Integer; BufferTableID: Integer; NAVSrcTableNo: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
        _FieldTypeText: Text;
    begin
        DMTSetup.Get();
        FilterFields(DMTFieldBuffer, NAVSrcTableNo, false, true, false);
        C.AppendLine('table ' + Format(BufferTableID) + ' ' + StrSubstNo('T%1Buffer', NAVSrcTableNo));
        C.AppendLine('{');
        C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';');
        C.AppendLine('  fields {');
        if FilterFields(DMTFieldBuffer, NAVSrcTableNo, false, DMTSetup."Import with FlowFields", false) then
            repeat
                case DMTFieldBuffer.Type of
                    DMTFieldBuffer.Type::RecordID:
                        _FieldTypeText := 'Text[250]'; // Import recordIDs as text to avoid validation issues on import
                    DMTFieldBuffer.Type::Code, DMTFieldBuffer.Type::Text:
                        _FieldTypeText := StrSubstNo('%1[%2]', DMTFieldBuffer.Type, DMTFieldBuffer.Len);
                    else
                        _FieldTypeText := Format(DMTFieldBuffer.Type);
                end;
                C.AppendLine(StrSubstNo('        field(%1; "%2"; %3)', DMTFieldBuffer."No.", DMTFieldBuffer.FieldName, _FieldTypeText));
                // field(1; "No."; Code[20])
                C.AppendLine('        {');
                C.AppendLine(StrSubstNo('            CaptionML = ENU = ''%1'', DEU = ''%2'';', DMTFieldBuffer.FieldName, DMTFieldBuffer."Field Caption"));

                if DMTFieldBuffer.Type = DMTFieldBuffer.Type::Option then begin
                    C.AppendLine('            OptionMembers = ' + DMTFieldBuffer.OptionString + ';');
                    C.AppendLine(StrSubstNo('            OptionCaptionML = ENU = ''%1'', DEU = ''%2'';', DelChr(DMTFieldBuffer.OptionString, '=', '"'), DelChr(DMTFieldBuffer.OptionCaption, '=', '"')));
                end;

                C.AppendLine('        }');

            until DMTFieldBuffer.Next() = 0;

        // AddTargetRecordExistsFlowField(TargetTableID, NAVSrcTableNo, DMTFieldBuffer, C);
        AddImportStatusFields(BufferTableID, DMTFieldBuffer, C);

        C.AppendLine('  }');
        C.AppendLine('    keys');
        C.AppendLine('    {');
        C.AppendLine('        key(Key1; ' + BuildKeyFieldsString(NAVSrcTableNo) + ')');
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

    local procedure GetCleanFieldName(var Field: Record DMTFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := DelChr(Field.FieldName, '=', '#&-%/\(),. ');
        // XMLPort Fieldelements cannot start with numbers
        if CleanFieldName <> '' then
            if CopyStr(CleanFieldName, 1, 1) in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] then
                CleanFieldName := '_' + CleanFieldName;
    end;

    local procedure GetCleanTableName(Field: Record DMTFieldBuffer) CleanFieldName: Text
    begin
        CleanFieldName := ConvertStr(Field.TableName, '&-%/\(),. ', '__________');
    end;

    procedure FilterFields(var fieldBuffer_FOUND: Record DMTFieldBuffer; tableNo: Integer; includeDisabled: Boolean; IncludeFlowFields: Boolean; IncludeBlob: Boolean) hasFields: Boolean
    var
        Debug: Integer;
    begin
        //* FilterField({TableNo}False{IncludeEnabled},False{IncludeFlowFields},False{IncludeBlob});
        Clear(fieldBuffer_FOUND);
        fieldBuffer_FOUND.SetRange(TableNo, tableNo);
        Debug := fieldBuffer_FOUND.Count;
        if not includeDisabled then
            fieldBuffer_FOUND.SetRange(Enabled, true);
        Debug := fieldBuffer_FOUND.Count;
        fieldBuffer_FOUND.SetFilter(Class, '%1|%2', fieldBuffer_FOUND.Class::Normal, fieldBuffer_FOUND.Class::FlowField);
        if not IncludeFlowFields then
            fieldBuffer_FOUND.SetRange(Class, fieldBuffer_FOUND.Class::Normal);
        if not IncludeBlob then
            fieldBuffer_FOUND.SetFilter(Type, '<>%1', fieldBuffer_FOUND.Type::BLOB);
        // Fields_Found.SetRange(FieldName, 'Picture');
        // if Fields_Found.FindFirst() then;
        Debug := fieldBuffer_FOUND.Count;
        fieldBuffer_FOUND.SetRange(FieldName);
        hasFields := fieldBuffer_FOUND.FindFirst();
    end;

    local procedure BuildKeyFieldsString(TableIDInNAV: Integer) KeyString: Text
    var
        FieldBuffer: Record DMTFieldBuffer;
        FieldID: Integer;
        FieldIds: List of [Text];
        FieldIDText: Text;
        OrderedKeyFieldNos: Text;
    begin
        FieldBuffer.SetRange(TableNo, TableIDInNAV);
        FieldBuffer.FindFirst();
        OrderedKeyFieldNos := FieldBuffer."Primary Key";
        if OrderedKeyFieldNos.Contains(',') then begin
            FieldIds := OrderedKeyFieldNos.Split(',');
        end else begin
            FieldIds.Add(OrderedKeyFieldNos);
        end;

        foreach FieldIDText in FieldIds do begin
            Evaluate(FieldID, FieldIDText);
            FieldBuffer.Get(TableIDInNAV, FieldID);
            KeyString += GetALFieldNameWithMasking(FieldBuffer.FieldName) + ',';
        end;
        KeyString := DelChr(KeyString, '>', ',');
    end;

    // local procedure AddTargetRecordExistsFlowField(TargetTableID: Integer; NAVSrcTableNo: Integer; var FieldBuffer: Record DMTFieldBuffer; var C: TextBuilder)
    // var
    //     refHelper: Codeunit DMTRefHelper;
    //     TargetRef: RecordRef;
    //     TargetTableName: Text;
    //     BufferKeyFieldNames, TargetKeyFieldNames : List of [Text];
    //     KeyFieldIndex: Integer;
    //     f: TextBuilder;
    // begin
    //     // FieldNoIsUsed
    //     if FieldBuffer.Get(NAVSrcTableNo, 59999) then
    //         exit;
    //     // FindTargetTableKeyInfo
    //     TargetRef.Open(TargetTableID);
    //     TargetTableName := QuoteValue(TargetRef.Name);
    //     for KeyFieldIndex := 1 to refHelper.GetListOfKeyFieldIDs(TargetRef).Count do
    //         TargetKeyFieldNames.Add(QuoteValue(TargetRef.KeyIndex(1).FieldIndex(KeyFieldIndex).Name));
    //     // FindSourceTableKeyInfo
    //     FieldBuffer.FindFirst();
    //     for KeyFieldIndex := 1 to FieldBuffer."Primary Key".Split(',').Count do
    //         if FieldBuffer.Get(FieldBuffer.TableNo, FieldBuffer."Primary Key".Split(',').Get(KeyFieldIndex)) then
    //             BufferKeyFieldNames.Add(QuoteValue(FieldBuffer.FieldName));

    //     if TargetKeyFieldNames.Count <> BufferKeyFieldNames.Count then
    //         exit;

    //     f.AppendLine('        field(59999; "DMT Target Record Exists"; Boolean)');
    //     f.AppendLine('        {');
    //     f.AppendLine('            CaptionML = ENU = ''DMT target record exists'', DEU = ''DMT Zieldatensatz vorhanden'';');
    //     f.AppendLine('            FieldClass = FlowField;');

    //     for KeyFieldIndex := 1 to TargetKeyFieldNames.Count do begin
    //         if KeyFieldIndex = 1 then
    //             f.Append('            CalcFormula = exist(' + TargetTableName + ' where(' + TargetKeyFieldNames.Get(KeyFieldIndex) + '= field(' + BufferKeyFieldNames.Get(KeyFieldIndex) + ')')
    //         else begin
    //             f.AppendLine('');
    //             f.Append('                                                     ' + TargetKeyFieldNames.Get(KeyFieldIndex) + '= field(' + BufferKeyFieldNames.Get(KeyFieldIndex) + ')');
    //         end;
    //         if KeyFieldIndex = TargetKeyFieldNames.Count then
    //             f.AppendLine('));')
    //         else
    //             f.Append(',')
    //     end;

    //     f.AppendLine('            Editable = false;');
    //     f.AppendLine('        }');
    //     C.Append(f.ToText());
    // end;

    local procedure AddImportStatusFields(BufferTableNo: Integer; var FieldBuffer: Record DMTFieldBuffer; var C: TextBuilder)
    var
        f: TextBuilder;
        freeFieldNos: List of [Text];
        fieldNoCandidate: Integer;
    begin
        for fieldNoCandidate := 51000 to 59999 do begin
            if not FieldBuffer.Get(BufferTableNo, fieldNoCandidate) then begin
                freeFieldNos.Add(format(fieldNoCandidate));
                if freeFieldNos.Count = 2 then
                    break;
            end;
        end;
        if freeFieldNos.Count < 2 then begin
            Message('No free field numbers found in table %1', BufferTableNo);
            exit;
        end;
        f.AppendLine('        field(' + freeFieldNos.Get(1) + ';"DMT Imported";Boolean) { CaptionML = ENU =''DMT Imported'', DEU = ''Importiert''; }');
        f.AppendLine('        field(' + freeFieldNos.Get(2) + '; "DMT RecId (Imported)"; RecordId) { CaptionML = ENU = ''DMT Record ID (Imported)'', DEU = ''Datensatz-ID (Importiert)''; }');
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

    procedure ImportNAVSchemaFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FieldImport: XmlPort "DMTFieldBufferImport";
        InStr: InStream;
        ImportFinishedMsg: Label 'Import finished', Comment = 'de-DE=Import abgeschlossen';
        FileName: Text;
    begin
        TempBlob.CreateInStream(InStr);
        if not UploadIntoStream('Select a Schema.csv file', '', Format(Enum::DMTFileFilter::CSV), FileName, InStr) then begin
            exit;
        end;
        FieldImport.SetSource(InStr);
        FieldImport.Import();

        Message(ImportFinishedMsg);
    end;

    local procedure GetALBufferTableName(importConfigHeader: Record DMTImportConfigHeader) Name: Text;
    begin
        Name := StrSubstNo('TABLE %1 - T%2Buffer.al', importConfigHeader."Buffer Table ID", importConfigHeader."NAV Src.Table No.");
    end;

    local procedure GetALXMLPortName(importConfigHeader: Record DMTImportConfigHeader) Name: Text;
    begin
        Name := StrSubstNo('XMLPORT %1 - T%2Import.al', importConfigHeader."Import XMLPort ID", importConfigHeader."NAV Src.Table No.");
    end;

    procedure DownloadAllALDataMigrationObjects()
    var
        importConfigHeader: Record DMTImportConfigHeader;
        DataCompression: Codeunit "Data Compression";
        ObjGen: Codeunit DMTCodeGenerator;
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        toFileName: Text;
        DefaultTextEncoding: TextEncoding;
    begin
        DefaultTextEncoding := TextEncoding::UTF8;
        importConfigHeader.SetRange("Use Separate Buffer Table", true);
        if importConfigHeader.FindSet() then begin
            DataCompression.CreateZipArchive();
            repeat
                //Table
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALTable(importConfigHeader).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, GetALBufferTableName(importConfigHeader));
                //XMLPort
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALXMLPort(importConfigHeader).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, GetALXMLPortName(importConfigHeader));
            until importConfigHeader.Next() = 0;
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr, DefaultTextEncoding);
        toFileName := 'BufferTablesAndXMLPorts.zip';
        DownloadFromStream(IStr, 'Download', 'ToFolder', Format(Enum::DMTFileFilter::ZIP), toFileName);
    end;

}
