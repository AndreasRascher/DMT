xmlport 90012 T5063Import
{
    CaptionML = DEU = 'Aktivitätengruppe(DMT)', ENU = 'Interaction Group(DMT)';
    Direction = Import;
    FieldSeparator = '<TAB>';
    FieldDelimiter = '<None>';
    TextEncoding = UTF8;
    Format = VariableText;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Root)
        {
            tableelement(Interaction_Group; T5063Buffer)
            {
                XmlName = 'Interaction_Group';
                fieldelement("Code"; Interaction_Group."Code") { FieldValidate = No; MinOccurs = Zero; }
                fieldelement("Description"; Interaction_Group."Description") { FieldValidate = No; MinOccurs = Zero; }
                trigger OnBeforeInsertRecord()
                begin
                    ReceivedLinesCount += 1;
                end;

                trigger OnAfterInitRecord()
                begin
                    if FileHasHeader then begin
                        FileHasHeader := false;
                        currXMLport.Skip();
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Umgebung)
                {
                    Caption = 'Environment', locked = true;
                    field(DatabaseName; GetDatabaseName()) { Caption = 'Database', locked = true; ApplicationArea = all; }
                    field(COMPANYNAME; COMPANYNAME) { Caption = 'Company', locked = true; ApplicationArea = all; }
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        T5063Buffer: Record T5063Buffer;
        LinesProcessedMsg: Label '%1 Buffer\%2 lines imported', locked = true;
    begin
        IF currXMLport.Filename <> '' then //only for manual excecution
            MESSAGE(LinesProcessedMsg, T5063Buffer.TABLECAPTION, ReceivedLinesCount);
    end;

    trigger OnPreXmlPort()
    var
        T5063Buffer: Record T5063Buffer;
    begin
        ClearBufferBeforeImportTable(T5063Buffer.RECORDID.TABLENO);
        FileHasHeader := true;
    end;

    var
        ReceivedLinesCount: Integer;
        FileHasHeader: Boolean;

    procedure RemoveSpecialChars(TextIn: Text[1024]) TextOut: Text[1024]
    var
        CharArray: Text[30];
    begin
        CharArray[1] := 9; // TAB
        CharArray[2] := 10; // LF
        CharArray[3] := 13; // CR
        exit(DELCHR(TextIn, '=', CharArray));
    end;

    local procedure ClearBufferBeforeImportTable(BufferTableNo: Integer)
    var
        BufferRef: RecordRef;
    begin
        //* Puffertabelle l”schen vor dem Import
        IF NOT currXMLport.IMPORTFILE then
            exit;
        IF BufferTableNo < 50000 then begin
            MESSAGE('Achtung: Puffertabellen ID kleiner 50000');
            exit;
        end;
        BufferRef.OPEN(BufferTableNo);
        IF NOT BufferRef.IsEmpty then
            BufferRef.DELETEALL();
    end;

    procedure GetDatabaseName(): Text[250]
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange("Server Instance ID", SERVICEINSTANCEID());
        ActiveSession.SetRange("Session ID", SESSIONID());
        ActiveSession.findfirst();
        exit(ActiveSession."Database Name");
    end;
}
