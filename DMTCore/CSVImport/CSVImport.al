/// <summary>
/// Read CSV To List Of List
/// </summary>
xmlport 91001 DMTCSVImport

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
        layout
        {
            area(Content)
            {
                // group(GroupName)
                // {
                //     field(Name; SourceExpression)
                //     {
                //     }
                // }
            }
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        ReadDataExport(1);
    end;

    local procedure ReadDataExport(HeaderLine: Integer)
    var
        Customer: Record Customer;
        LineNo: Integer;
        FieldValue: Text;
        ColNo: Integer;
    begin
        for LineNo := HeaderLine + 1 to DataTable.Count do begin
            ColNo := 2;
            FieldValue := DataTable.get(LineNo).Get(ColNo);
            if Customer.Get(FieldValue) then
                FindContact(Customer."No.");
        end;
    end;

    local procedure FindContact(CustomerNo: Code[20])
    var
        Contact: Record Contact;
    begin
        // To something...
    end;

    var
        CurrColIndex: Integer;
        LineNo: Integer;
        DataTable: List of [List of [Text]];

}