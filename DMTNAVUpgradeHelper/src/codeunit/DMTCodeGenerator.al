codeunit 50028 DMTCodeGenerator
{

    procedure CreateALXMLPort(importConfigHeader: Record DMTImportConfigHeader) C: TextBuilder
    var
    begin
        case importConfigHeader."Separate Buffer Table Objects" of
            importConfigHeader."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)":
                begin
                    ImportConfigHeader.TestField("Buffer Table ID");
                    ImportConfigHeader.TestField("Import XMLPort ID");
                    ImportConfigHeader.TestField("NAV Src.Table No.");
                    ImportConfigHeader.TestField("NAV Src.Table Caption");
                    C := CreateALXMLPortFromNAVSchema(ImportConfigHeader."Import XMLPort ID", ImportConfigHeader."NAV Src.Table No.", ImportConfigHeader."NAV Src.Table Caption");
                end;
            importConfigHeader."Separate Buffer Table Objects"::"Use existing buffer table & generate XMLPort only":
                begin
                    ImportConfigHeader.TestField("Buffer Table ID");
                    ImportConfigHeader.TestField("Import XMLPort ID");
                    C := CreateXMLPortFromExistingBufferTable(importConfigHeader."Import XMLPort ID", importConfigHeader."Buffer Table ID")
                end;
        end;
    end;

    local procedure CreateALXMLPortFromNAVSchema(ImportXMLPortID: Integer; NAVSrcTableNo: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
        HasFieldsInFilter: Boolean;
    begin
        HasFieldsInFilter := FilterFieldsInNAVSchema(DMTFieldBuffer, NAVSrcTableNo, false, DMTSetup."Exports include FlowFields", false);
        C.AppendLine('xmlport ' + Format(ImportXMLPortID) + ' T' + Format(NAVSrcTableNo) + 'Import');
        C.AppendLine('{');
        DMTSetup.Get();
        if DMTSetup."Exports include FlowFields" then
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
            C.AppendLine('            tableelement(' + GetCleanTableName(DMTFieldBuffer.TableName) + '; ' + StrSubstNo('T%1Buffer', NAVSrcTableNo) + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(DMTFieldBuffer.TableName) + ''';');
            DMTFieldBuffer.FindSet();
            repeat
                C.AppendLine('                fieldelement("' + GetCleanFieldName(DMTFieldBuffer.FieldName) + '"; ' + GetCleanTableName(DMTFieldBuffer.TableName) + '."' + DMTFieldBuffer.FieldName + '") { FieldValidate = No; MinOccurs = Zero; }');
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

    local procedure CreateXMLPortFromExistingBufferTable(ImportXMLPortID: Integer; BufferTableID: Integer) C: TextBuilder
    var
        TableMetadata: Record "Table Metadata";
        field: Record Field;
        DMTSetup: Record DMTSetup;
        HasFieldsInFilter: Boolean;
        bufferTableCaption: Text;
        bufferTableName: Text;
    begin
        TableMetadata.Get(BufferTableID);
        bufferTableName := TableMetadata.Name;
        bufferTableCaption := TableMetadata.Caption;

        HasFieldsInFilter := FilterFields(field, BufferTableID, false, DMTSetup."Exports include FlowFields", false);
        C.AppendLine('xmlport ' + Format(ImportXMLPortID) + ' T' + Format(BufferTableID) + 'Import');
        C.AppendLine('{');
        DMTSetup.Get();
        if DMTSetup."Exports include FlowFields" then
            C.AppendLine('    CaptionML= DEU = ''' + bufferTableCaption + '(DMT)' + 'FlowField' + ''', ENU = ''' + field.TableName + '(DMT)' + ''';')
        else
            C.AppendLine('    CaptionML= DEU = ''' + bufferTableCaption + '(DMT)' + ''', ENU = ''' + field.TableName + '(DMT)' + ''';');
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
            C.AppendLine('            tableelement(' + GetCleanTableName(field.TableName) + '; ' + bufferTableName + ')');
            C.AppendLine('            {');
            C.AppendLine('                XmlName = ''' + GetCleanTableName(field.TableName) + ''';');
            field.FindSet();
            repeat
                C.AppendLine('                fieldelement("' + GetCleanFieldName(field.FieldName) + '"; ' + GetCleanTableName(field.TableName) + '."' + field.FieldName + '") { FieldValidate = No; MinOccurs = Zero; }');
            until field.Next() = 0;
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
        C.AppendLine('        LinesProcessedMsg: Label ''%1 Buffer\%2 lines imported'',locked=true;');
        C.AppendLine('    begin');
        C.AppendLine('        IF currXMLport.Filename <> '''' then //only for manual excecution');
        C.AppendLine('            MESSAGE(LinesProcessedMsg, ' + bufferTableName + '.TABLECAPTION, ReceivedLinesCount);');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    trigger OnPreXmlPort()');
        C.AppendLine('    begin');
        C.AppendLine('        ClearBufferBeforeImportTable(' + bufferTableName + '.RECORDID.TABLENO);');
        C.AppendLine('        FileHasHeader := true;');
        C.AppendLine('    end;');
        C.AppendLine('');
        C.AppendLine('    var');
        C.AppendLine('        ReceivedLinesCount: Integer;');
        C.AppendLine('        FileHasHeader: Boolean;');
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
        C := CreateALTable(ImportConfigHeader."Buffer Table ID", ImportConfigHeader."NAV Src.Table No.", ImportConfigHeader."NAV Src.Table Caption");
    end;

    local procedure CreateALTable(BufferTableID: Integer; NAVSrcTableNo: Integer; NAVSrcTableCaption: Text) C: TextBuilder
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        DMTSetup: Record DMTSetup;
        _FieldTypeText: Text;
    begin
        DMTSetup.Get();
        FilterFieldsInNAVSchema(DMTFieldBuffer, NAVSrcTableNo, false, true, false);
        C.AppendLine('table ' + Format(BufferTableID) + ' ' + StrSubstNo('T%1Buffer', NAVSrcTableNo));
        C.AppendLine('{');
        C.AppendLine('    CaptionML= DEU = ''' + NAVSrcTableCaption + '(DMT)' + ''', ENU = ''' + DMTFieldBuffer.TableName + '(DMT)' + ''';');
        C.AppendLine('  fields {');
        if FilterFieldsInNAVSchema(DMTFieldBuffer, NAVSrcTableNo, false, DMTSetup."Exports include FlowFields", false) then
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

    local procedure GetCleanFieldName(fieldName: Text) CleanFieldName: Text
    begin
        CleanFieldName := DelChr(fieldName, '=', '#&-%/\(),. ');
        // XMLPort Fieldelements cannot start with numbers
        if CleanFieldName <> '' then
            if CopyStr(CleanFieldName, 1, 1) in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] then
                CleanFieldName := '_' + CleanFieldName;
    end;

    local procedure GetCleanTableName(tableName: Text) CleanFieldName: Text
    begin
        CleanFieldName := ConvertStr(tableName, '&-%/\(),. ', '__________');
    end;

    procedure FilterFieldsInNAVSchema(var fieldBuffer_FOUND: Record DMTFieldBuffer; tableNo: Integer; includeDisabled: Boolean; IncludeFlowFields: Boolean; IncludeBlob: Boolean) hasFields: Boolean
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

    procedure FilterFields(var field_FOUND: Record field; tableNo: Integer; includeDisabled: Boolean; IncludeFlowFields: Boolean; IncludeBlob: Boolean) hasFields: Boolean
    var
        recRef: RecordRef;
        Debug: Integer;
        excludeSystemFieldsFilter: Text;
    begin
        recRef.Open(tableNo);
        excludeSystemFieldsFilter := StrSubstNo('<>%1&<>%2&<>%3&<>%4&<>%5', recRef.SystemCreatedAtNo,
                                                                  recRef.SystemCreatedByNo,
                                                                  recRef.SystemIdNo,
                                                                  recRef.SystemModifiedAtNo,
                                                                  recRef.SystemModifiedByNo);

        Clear(field_FOUND);
        field_FOUND.SetRange(TableNo, tableNo);
        field_FOUND.SetFilter("No.", excludeSystemFieldsFilter);
        Debug := field_FOUND.Count;
        if not includeDisabled then
            field_FOUND.SetRange(Enabled, true);
        Debug := field_FOUND.Count;
        field_FOUND.SetFilter(Class, '%1|%2', field_FOUND.Class::Normal, field_FOUND.Class::FlowField);
        if not IncludeFlowFields then
            field_FOUND.SetRange(Class, field_FOUND.Class::Normal);
        if not IncludeBlob then
            field_FOUND.SetFilter(Type, '<>%1', field_FOUND.Type::BLOB);
        Debug := field_FOUND.Count;
        field_FOUND.SetRange(FieldName);
        hasFields := field_FOUND.FindFirst();
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
        if importConfigHeader."Separate Buffer Table Objects" = importConfigHeader."Separate Buffer Table Objects"::"Use existing buffer table & generate XMLPort only" then
            Name := StrSubstNo('XMLPORT %1 - T%2Import.al', importConfigHeader."Import XMLPort ID", importConfigHeader."Target Table ID")
        else
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
        doCreateALTable, doCreateALXMLPort : boolean;
    begin
        DefaultTextEncoding := TextEncoding::UTF8;
        importConfigHeader.SetFilter("Separate Buffer Table Objects", '<>%1', importConfigHeader."Separate Buffer Table Objects"::None);
        importConfigHeader.FindSet();  // Fehlermeldung wenn keine Einrichtung passt
        // if importConfigHeader.FindSet() then begin
        DataCompression.CreateZipArchive();
        repeat
            doCreateALTable := importConfigHeader."Separate Buffer Table Objects" in [importConfigHeader."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)"];
            doCreateALXMLPort := importConfigHeader."Separate Buffer Table Objects" in [importConfigHeader."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)",
                                                                                    importConfigHeader."Separate Buffer Table Objects"::"Use existing buffer table & generate XMLPort only"];
            //Table
            if doCreateALTable then begin
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALTable(importConfigHeader).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, GetALBufferTableName(importConfigHeader));
            end;
            //XMLPort
            if doCreateALXMLPort then begin
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALXMLPort(importConfigHeader).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, GetALXMLPortName(importConfigHeader));
            end;
        until importConfigHeader.Next() = 0;
        // end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr, DefaultTextEncoding);
        toFileName := 'BufferTablesAndXMLPorts.zip';
        DownloadFromStream(IStr, 'Download', 'ToFolder', Format(Enum::DMTFileFilter::ZIP), toFileName);
    end;

}
