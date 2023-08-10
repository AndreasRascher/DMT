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
                    begin
                        if not shouldReadLine(CurrRowNoGlobal) then
                            currXMLport.Skip();

                        CurrentLineGlobal.Add(fieldContent);
                        // save first line with values info to find headline row no
                        if FirstRowWithValuesGlobal = 0 then
                            if fieldContent <> '' then
                                FirstRowWithValuesGlobal := CurrRowNoGlobal;
                    end;
                }
                // Called when starting new line
                trigger OnAfterInitRecord()
                begin
                    CurrRowNoGlobal += 1;
                    Line.Number := CurrRowNoGlobal; // required to raise onBeforeInsertRecord
                    if RowListGlobal.Count > 0 then begin
                        if (toRowNoGlobal <> 0) and (CurrRowNoGlobal > toRowNoGlobal) then
                            currXMLport.Break();
                        if not RowListGlobal.Contains(CurrRowNoGlobal) then
                            currXMLport.Skip();
                    end;
                    Clear(CurrentLineGlobal); // prepare new line
                end;
                // Called when finished line but only if dataitem key changed
                trigger OnBeforeInsertRecord()
                begin
                    ProcessLineAfterReceivingLastField();
                end;
            }
        }
    }

    requestpage
    {
    }

    internal procedure InitImportToGenBuffer(sourceFileStorage: Record DMTSourceFileStorage; importConfigHeader: Record DMTImportConfigHeader)
    begin
        HeadLineRowNoGlobal := importConfigHeader.GetDataLayout().HeadingRowNo;
        ImportConfigHeaderIDGlobal := importConfigHeader.ID;
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
        toRowNoGlobal := toRowNo;
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

    local procedure ProcessLineAfterReceivingLastField()
    begin
        if shouldReadLine(CurrRowNoGlobal) then
            case ReadModeGlobal of
                ReadModeGlobal::ReadOnly:
                    DataTable.Add(CurrentLineGlobal);
                ReadModeGlobal::ImportToGenBuffer:
                    begin
                        ImportLine(CurrentLineGlobal, (HeadLineRowNoGlobal = CurrRowNoGlobal), ImportFromFileNameGlobal);
                    end;
            end;
    end;

    local procedure ImportLine(currentLine: List of [Text]; IsColumnCaptionLine: Boolean; ImportFromFileName: Text[250]);
    var
        genBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
        CurrColIndex: Integer;
        cellValue: Text;
    begin
        if NextEntryNoGlobal = 0 then
            NextEntryNoGlobal := genBuffTable.GetNextEntryNo()
        else
            NextEntryNoGlobal += 1;

        genBuffTable.Init();
        genBuffTable."Entry No." := NextEntryNoGlobal;
        genBuffTable.IsCaptionLine := IsColumnCaptionLine;
        RecRef.GetTable(genBuffTable);
        foreach cellValue in currentLine do begin
            CurrColIndex += 1;
            //ToDo: Handle large Texts
            if not HasToLargeTextValuesGlobal then
                if Strlen(cellValue) > 250 then
                    HasToLargeTextValuesGlobal := true;
            RecRef.Field(1000 + CurrColIndex).Value := CopyStr(cellValue, 1, 250);
        end;

        RecRef.SetTable(genBuffTable);
        genBuffTable."Import from Filename" := ImportFromFileName;
        genBuffTable."Imp.Conf.Header ID" := ImportConfigHeaderIDGlobal;
        genBuffTable."Column Count" := CurrColIndex;
        genBuffTable.Insert();
    end;

    procedure HasTooLargeTextValues(): Boolean
    begin
        exit(HasToLargeTextValuesGlobal)
    end;

    local procedure shouldReadLine(rowNo: Integer): Boolean
    begin
        if (RowListGlobal.Count = 0) then
            exit(true);
        if RowListGlobal.Contains(rowNo) then
            exit(true);
        exit(false);
    end;

    var
        ReadModeGlobal: Option ReadOnly,ImportToGenBuffer;
        ImportFromFileNameGlobal: Text[250];
        HeadLineRowNoGlobal, FirstRowWithValuesGlobal, CurrRowNoGlobal, toRowNoGlobal, NextEntryNoGlobal, ImportConfigHeaderIDGlobal : Integer;
        DataTable: List of [List of [Text]];
        CurrentLineGlobal: List of [Text];
        RowListGlobal: list of [Integer];
        HasToLargeTextValuesGlobal: Boolean;
}