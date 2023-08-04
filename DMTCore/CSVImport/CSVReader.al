/// <summary>
/// Read CSV To List Of List
/// </summary>
xmlport 91001 DMTCSVReader
{
    Caption = 'GenBufferImport';
    Direction = Import;
    FieldSeparator = ';';
    FieldDelimiter = '"';

    TextEncoding = UTF8;
    Format = VariableText;
    FormatEvaluate = Xml;

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
                        Line: List of [Text];
                    begin
                        CurrColIndex += 1;
                        if DataTable.Get(LineNo, Line) then begin
                            Line.Add(FieldContent);
                            DataTable.Set(LineNo, Line);
                        end else begin
                            Line.Add(FieldContent);
                            DataTable.Add(Line);
                        end;
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin

                end;

                trigger OnAfterInitRecord()
                begin
                    LineNo += 1;
                    CurrColIndex := 0;
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
        sourceFileStorage.GetFileAsTempBlob(TempBlobGlobal);
        HeadLineRowNoGlobal := headLineRowNo;
        ImportFromFileNameGlobal := sourceFileStorage.Name;
        ReadModeGlobal := ReadModeGlobal::ImportToGenBuffer;
    end;

    var
        TempBlobGlobal: Codeunit "Temp Blob";
        ReadModeGlobal: Option ReadOnly,ImportToGenBuffer;
        ImportFromFileNameGlobal: Text;
        HeadLineRowNoGlobal: Integer;
        CurrColIndex: Integer;
        LineNo: Integer;
        DataTable: List of [List of [Text]];

}