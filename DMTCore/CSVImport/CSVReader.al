/// <summary>
/// Read CSV To List Of List
/// </summary>
xmlport 91001 DMTCSVReader
{
    Caption = 'GenBufferImport';
    Direction = Import;
    // FieldSeparator = ';';
    // FieldDelimiter = '"';
    // TextEncoding = UTF8;
    Format = VariableText;
    FormatEvaluate = Xml;
    TableSeparator = '<None>';

    schema
    {
        textelement(Root)
        {
            tableelement(Line; Integer)
            {
                UseTemporary = true;
                AutoReplace = true;

                textelement(FieldContent)
                {
                    Unbound = true;
                    trigger OnAfterAssignVariable()
                    var
                        Debug: Text;
                        CharMap: List of [Text];
                        i: Integer;
                    begin
                        if RowListGlobal.Count > 0 then
                            if not RowListGlobal.Contains(CurrRowNoGlobal) then
                                currXMLport.Skip();

                        if FieldContent.Contains('volltextsuche') then begin
                            for i := 1 to StrLen(FieldContent) do
                                CharMap.Add(StrSubstNo('%1-%2', FieldContent[i], FieldContent[i] * 1));
                            Debug := Format(currXMLport.FieldDelimiter);
                            Debug := Format(currXMLport.FieldSeparator);
                            Debug := Format(currXMLport.RecordSeparator);
                            Debug := Format(currXMLport.TextEncoding);
                        end;
                        case ReadModeGlobal of
                            ReadModeGlobal::ReadOnly:
                                begin
                                    CurrentLineGlobal.Add(fieldContent);
                                    // save first line with values info to find headline row no
                                    if FirstRowWithValuesGlobal = 0 then
                                        if fieldContent <> '' then
                                            FirstRowWithValuesGlobal := CurrRowNoGlobal;

                                end;
                            ReadModeGlobal::ImportToGenBuffer:
                                CollectLineAndInsertIntoToGenBufferTable(CurrRowNoGlobal, FieldContent)
                        end;
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin
                    ProcessLineAfterReceivingLastField();
                end;

                trigger OnAfterInitRecord()
                begin
                    CurrRowNoGlobal += 1;
                    CurrColIndex := 0;

                    if RowListGlobal.Count > 0 then
                        if not RowListGlobal.Contains(CurrRowNoGlobal) then
                            currXMLport.Skip();
                end;
            }
        }
    }

    requestpage
    {
    }

    trigger OnPostXmlPort()
    begin
    end;

    internal procedure InitImportToGenBuffer(sourceFileStorage: Record DMTSourceFileStorage; headLineRowNo: Integer)
    begin
        HeadLineRowNoGlobal := headLineRowNo;
        ImportFromFileNameGlobal := sourceFileStorage.Name;
        ReadModeGlobal := ReadModeGlobal::ImportToGenBuffer;
    end;

    internal procedure InitReadRows(fromRowNo: integer; toRowNo: Integer)
    var
        rowNo: Integer;
    begin
        for rowNo := fromRowNo to toRowNo do
            RowListGlobal.Add(rowNo);
        ReadModeGlobal := ReadModeGlobal::ReadOnly;
    end;

    internal procedure GetHeadlineColumnValues(var FirstRowWithValues: Integer) HeadLine: List of [Text]
    begin
        if (DataTable.Count > 1) and (FirstRowWithValuesGlobal <> 0) then begin
            DataTable.Get(FirstRowWithValuesGlobal, HeadLine);
        end else begin
            HeadLine := DataTable.Get(1);
        end;
        FirstRowWithValues := FirstRowWithValuesGlobal;
    end;

    procedure ProcessLineAfterReceivingLastField()
    begin
        if RowListGlobal.Count > 0 then
            if RowListGlobal.Contains(CurrRowNoGlobal) then
                case ReadModeGlobal of
                    ReadModeGlobal::ReadOnly:
                        begin
                            DataTable.Add(CurrentLineGlobal);
                            Clear(CurrentLineGlobal);
                        end;
                    ReadModeGlobal::ImportToGenBuffer:
                        ImportLine(CurrentLineGlobal, false, ImportFromFileNameGlobal);
                end;
    end;

    local procedure ImportLine(currentLine: List of [Text]; IsColumnCaptionLine: Boolean; ImportFromFileName: Text);
    var
        genBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
        NextEntryNo: Integer;
        CurrColIndex: Integer;
        cellValue: Text;
    begin
        NextEntryNo := genBuffTable.GetNextEntryNo();

        genBuffTable.Init();
        genBuffTable."Entry No." := NextEntryNo;
        genBuffTable.IsCaptionLine := IsColumnCaptionLine;
        RecRef.GetTable(genBuffTable);
        foreach cellValue in currentLine do begin
            CurrColIndex += 1;
            //ToDo: Handle large Texts
            RecRef.Field(1000 + CurrColIndex).Value := CopyStr(cellValue, 1, 250);
        end;

        RecRef.SetTable(genBuffTable);
        genBuffTable."Import from Filename" := CopyStr(ImportFromFileName, 1, MaxStrLen(genBuffTable."Import from Filename"));
        genBuffTable."Column Count" := CurrColIndex;
        genBuffTable.Insert();
    end;

    local procedure CollectLineAndInsertIntoToGenBufferTable(rowNo: Integer; cellValue: Text)
    begin
        if rowNo > CurrRowNoGlobal then begin
            if CurrRowNoGlobal > 0 then
                ImportLine(CurrentLineGlobal, (rowNo - 1) = HeadLineRowNoGlobal, ImportFromFileNameGlobal);
            // Progress_Update(rowNo);
            //start new line
            CurrRowNoGlobal := rowNo;
            Clear(CurrentLineGlobal);
        end;
        CurrentLineGlobal.Add(cellValue);
    end;


    var
        ReadModeGlobal: Option ReadOnly,ImportToGenBuffer;
        ImportFromFileNameGlobal: Text;
        HeadLineRowNoGlobal, FirstRowWithValuesGlobal, CurrRowNoGlobal : Integer;
        CurrColIndex: Integer;
        DataTable: List of [List of [Text]];
        CurrentLineGlobal: List of [Text];
        RowListGlobal: list of [Integer];
}