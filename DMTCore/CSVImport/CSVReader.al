xmlport 91001 DMTCSVReader
{
    Caption = 'GenBufferImport';
    Direction = Import;
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
                    TextType = BigText;
                    trigger OnAfterAssignVariable()
                    begin
                        if not shouldReadLine(CurrRowNoGlobal) then
                            currXMLport.Skip();

                        CurrentLineGlobal.Add(fieldContent);
                        // save first line with values info to find headline row no
                        if FirstRowWithValuesGlobal = 0 then
                            if fieldContent.Length <> 0 then
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
        ReadModeGlobal := ReadModeGlobal::ImportToGenBuffer;
        genBuffAccessMgt.InitImportToGenBuffer(importConfigHeader);
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
    var
        HeadLineBigText: List of [BigText];
        columnCaption: BigText;
    begin
        if (DataTable.Count > 1) and (FirstRowWithValuesGlobal <> 0) then begin
            DataTable.Get(FirstRowWithValuesGlobal, HeadLineBigText);
        end else begin
            HeadLineBigText := DataTable.Get(1);
        end;
        // assumption: Columncaption is not larger than 49180 chars
        foreach columnCaption in HeadLineBigText do begin
            HeadLine.Add(Format(columnCaption));
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
                    genBuffAccessMgt.ImportLine(CurrentLineGlobal, CurrRowNoGlobal);
            end;
    end;

    procedure LargeTextColCaptions(): Dictionary of [Integer, Text];
    begin
        exit(genBuffAccessMgt.LargeTextColCaptions());
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
        genBuffAccessMgt: Codeunit DMTGenBuffAccessMgt;
        ReadModeGlobal: Option ReadOnly,ImportToGenBuffer;
        FirstRowWithValuesGlobal, CurrRowNoGlobal, toRowNoGlobal : Integer;
        DataTable: List of [List of [BigText]];
        CurrentLineGlobal: List of [BigText];
        RowListGlobal: list of [Integer];
}