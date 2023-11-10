xmlport 91002 DMTCSVWriter
{
    Caption = 'CSVExport';
    Direction = Export;
    Format = VariableText;
    FormatEvaluate = Xml;
    TextEncoding = UTF8;
    TableSeparator = '<None>';
    FieldSeparator = '<TAB>';
    FieldDelimiter = '<None>';

    schema
    {
        textelement(Root)
        {
            tableelement(Line; Integer)
            {
                // UseTemporary = true;
                AutoReplace = true;
                textelement(FieldContent)
                {
                    Unbound = true;
                    TextType = BigText;
                    trigger OnBeforePassVariable()
                    begin
                        Clear(FieldContent); // is not cleared automatically between Fields
                        CurrFieldIndexGlobal += 1;
                        if Line.Number = 0 then begin
                            FieldContent.AddText(ExportFieldListGlobal.Values.Get(CurrFieldIndexGlobal));
                        end else begin
                            FieldContent.AddText(getFieldContentAsText(SourceRef, CurrFieldIndexGlobal));
                        end;
                        if IsLastField(CurrFieldIndexGlobal) then
                            currXMLport.BreakUnbound(); // new line
                    end;
                }

                trigger OnPreXmlItem()
                begin
                    Line.SetRange(Number, 0, SourceRef.Count);
                    initExportFieldList(SourceRef);
                end;

                trigger OnAfterGetRecord()
                begin
                    case true of
                        //headLine
                        (Line.Number = 0):
                            ;
                        // first line
                        (Line.Number = 1):
                            SourceRef.FindSet(false);
                        else
                            SourceRef.Next();
                    end;
                    CurrFieldIndexGlobal := 0;
                end;
            }
        }
    }

    requestpage { }

    internal procedure ExportTargetTableAsCSV(importConfigHeader: Record DMTImportConfigHeader)
    var
        FPBuilder: Codeunit DMTFPBuilder;
        tempBlob: Codeunit "Temp Blob";
        exportGenericCSV: XmlPort DMTCSVWriter;
        rRef: RecordRef;
        IStr: InStream;
        OStr: OutStream;
        FileName: Text;
    begin
        if importConfigHeader."Target Table ID" = 0 then exit;
        rRef.Open(importConfigHeader."Target Table ID");
        if not FPBuilder.RunModal(rRef, true) then
            exit;
        if not rRef.FindSet() then exit;
        exportGenericCSV.SetExportTable(rRef);
        tempBlob.CreateOutStream(OStr, TextEncoding::UTF8);
        exportGenericCSV.SetDestination(OStr);
        exportGenericCSV.Export();
        tempBlob.CreateInStream(IStr, TextEncoding::UTF8);
        Filename := importConfigHeader."Target Table Caption" + '.csv';
        DownloadFromStream(IStr, 'Download', 'ToFolder', Format(Enum::DMTFileFilter::CSV), FileName);
    end;

    local procedure IsLastField(fieldIndex: Integer): Boolean
    begin
        if ExportFieldListGlobal.Count = 0 then
            exit(true);
        if ExportFieldListGlobal.Count = fieldIndex then
            exit(true);
    end;


    local procedure initExportFieldList(var recRef: RecordRef)
    var
        field: FieldRef;
        i: Integer;
        IsExportField: Boolean;
    begin
        DMTSetup.GetRecordOnce();
        for i := 1 to recRef.FieldCount do begin
            field := recRef.FieldIndex(i);

            IsExportField := true;
            if (field.Class = FieldClass::FlowField) and not DMTSetup."Exports include FlowFields" then
                IsExportField := false;

            if IsExportField then
                if field.Type in [field.Type::Blob, field.Type::Media] then
                    ExportFieldListGlobal.Add(field.Number, field.Name + '[Base64]')
                else
                    ExportFieldListGlobal.Add(field.Number, field.Name);
        end;
    end;

    /// <summary>Get field value as text. Blob as base 64, Option as number </summary>
    local procedure getFieldContentAsText(var rRef: RecordRef; fieldIndex: Integer) _result: Text
    var
        fieldRecord: Record Field;
        tenantMedia: Record "Tenant Media";
        _tempBlob: Codeunit "Temp Blob";
        base64Convert: Codeunit "Base64 Convert";
        fRef: FieldRef;
        _integer: Integer;
        _boolean: Boolean;
        _decimal: Decimal;
        _date: Date;
        _time: Time;
        _iStream: InStream;
        _tab: Char;
        _Guid: Guid;
        JObj: JsonObject;
        fieldNo: Integer;
        char177: text[1];
        recRef: RecordRef;
    begin
        _tab := 9;
        fieldNo := ExportFieldListGlobal.Keys.Get(fieldIndex);
        fRef := rRef.Field(fieldNo);
        if fRef.Class = fRef.Class::FlowField then
            fRef.CalcField();
        //* returns values in xmlformat, handles problems with field.type optionstring bug
        case fRef.Type of
            FieldType::Boolean:
                begin
                    _boolean := fRef.Value;
                    _result := '0';
                    if _boolean then _result := '1';
                end;
            FieldType::Integer:
                begin
                    _integer := fRef.Value;
                    if _integer <> 0 then _result := Format(_integer, 0, 9);
                end;
            FieldType::Option:
                begin
                    _integer := fRef.Value;
                    _result := Format(_integer, 0, 9);
                end;
            FieldType::Decimal:
                begin
                    _decimal := fRef.Value;
                    if _decimal <> 0 then _result := Format(_decimal, 0, 9);
                end;
            FieldType::Date:
                begin
                    _date := fRef.Value;
                    if _date <> 0D then _result := Format(_date, 0, 9);
                end;
            FieldType::Time:
                begin
                    _time := fRef.Value;
                    if _time <> 0T then _result := Format(_time, 0, 9);
                end;
            FieldType::Text, FieldType::Code:
                begin
                    _result := fRef.Value;
                    _result := DelChr(_result, '=', _tab);
                end;
            FieldType::Guid:
                begin
                    _Guid := fRef.Value;
                    if not IsNullGuid(_Guid) then
                        _result := format(_Guid);
                end;
            FieldType::Blob:
                begin
                    fRef.CalcField();
                    _tempBlob.FromFieldRef(fRef);
                    if not _tempBlob.HasValue() then
                        exit('');
                    _tempBlob.CreateInStream(_iStream);
                    char177[1] := 177;
                    _result := 'base64:' + char177[1] + base64Convert.ToBase64(_iStream) + char177[1];
                end;
            FieldType::Media:
                begin
                    _Guid := fRef.Value;
                    if IsNullGuid(_Guid) then
                        exit('');
                    if not tenantMedia.Get(_Guid) then
                        exit('');
                    tenantMedia.CalcFields(Content);
                    if not tenantMedia.Content.HasValue() then
                        exit('');
                    recRef.GetTable(tenantMedia);
                    for _integer := 1 to recRef.FieldCount() do begin
                        fRef := recRef.FieldIndex(_integer);
                        if fRef.Class = FieldClass::Normal then begin
                            if fRef.Type = fRef.Type::Blob then begin
                                _tempBlob.FromFieldRef(fRef);
                                _tempBlob.CreateInStream(_iStream);
                                _result := base64Convert.ToBase64(_iStream);
                                JObj.Add(fRef.Name, _result);
                            end else begin
                                JObj.Add(fRef.Name, format(fRef.Value));
                            end;
                        end;
                    end;

                    JObj.WriteTo(_result);
                    char177[1] := 177;
                    _result := 'JSON:' + char177[1] + _result + char177[1];
                end;
            else
                _result := Format(fRef.Value, 0, 9);
        end; // END_CASE

        if (rRef.Number = Database::Field) and (fieldNo = fieldRecord.FieldNo(Type)) then begin
            rRef.SetTable(fieldRecord);
            if (fRef.Number = fieldRecord.FieldNo(Type)) then
                case fRef.Type of
                    FieldType::TableFilter:
                        _result := '0';
                    FieldType::RecordId:
                        _result := '1';
                    FieldType::Text:
                        _result := '2';
                    FieldType::Date:
                        _result := '3';
                    FieldType::Time:
                        _result := '4';
                    FieldType::DateFormula:
                        _result := '5';
                    FieldType::Decimal:
                        _result := '6';
                    // field.Type::Binary:
                    //     _result := '7';
                    FieldType::Blob:
                        _result := '8';
                    FieldType::Boolean:
                        _result := '9';
                    FieldType::Integer:
                        _result := '10';
                    FieldType::Code:
                        _result := '11';
                    FieldType::Option:
                        _result := '12';
                    FieldType::BigInteger:
                        _result := '13';
                    FieldType::Duration:
                        _result := '14';
                    FieldType::Guid:
                        _result := '15';
                    FieldType::DateTime:
                        _result := '16';
                    else
                        Error('unhandled Case - Field.Type to Int: %1', fRef.Type);
                end;
        end;
    end;

    procedure SetExportTable(recVariant: Variant)
    begin
        SourceRef.GetTable(recVariant);
    end;

    var
        DMTSetup: Record DMTSetup;
        SourceRef: RecordRef;
        ExportFieldListGlobal:
                Dictionary of [Integer, Text];
        CurrFieldIndexGlobal:
                Integer;

}