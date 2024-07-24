codeunit 90014 DMTDataTableMgt
{

    procedure Steps_InitForTemplate(templateCode: Text)
    begin
        noOfColumnsGlobal := 2; // Type, Name
    end;

    procedure RequiredData_InitForTemplate(templateCode: Text)
    begin
        noOfColumnsGlobal := 3; // TableName, FieldName, Style
    end;

    procedure Requirements_InitForTemplate(templateCode: Text)
    begin
        noOfColumnsGlobal := 4; // Type, Name, NAV Source Table No, Style
    end;

    procedure Steps_Add(TypeText: text; Name: Text)
    begin
        addLine(TypeText, Name);
    end;

    procedure RequiredData_Add(TableName: Text; FieldName: Text; Style: Text)
    begin
        addLine(TableName, FieldName, Style);
    end;

    procedure Requirements_Add(TypeText: Text; Name: Text; NAVID: Integer; Style: Text)
    begin
        addLine(TypeText, Name, Format(NAVID), Style);
    end;

    procedure Count() NoOfSteps: Integer
    begin
        NoOfSteps := DataTable.Count;
    end;

    procedure Steps_GetTypeText(index: Integer) TypeText: Text
    begin
        exit(DataTable.Get(index).Get(1));
    end;

    procedure Steps_GetName(index: Integer) Name: Text
    begin
        exit(DataTable.Get(index).Get(2));
    end;

    procedure Requirements_GetTypeText(index: Integer): Text
    begin
        exit(DataTable.Get(index).Get(1));
    end;

    procedure Requirements_GetName(index: Integer): Text
    begin
        exit(DataTable.Get(index).Get(2));
    end;

    procedure RequiredData_GetTypeText(index: Integer): Text
    begin
        exit(DataTable.Get(index).Get(1));
    end;

    procedure RequiredData_GetName(index: Integer): Text
    begin
        exit(DataTable.Get(index).Get(2));
    end;

    local procedure addLine(Col1: Text; Col2: Text)
    var
        LineNew: List of [Text];
    begin
        LineNew.Add(Col1);
        LineNew.Add(Col2);
        DataTable.Add(DataTable.Count + 1, LineNew);
    end;

    local procedure addLine(Col1: Text; Col2: Text; Col3: Text)
    var
        LineNew: List of [Text];
    begin
        LineNew.Add(Col1);
        LineNew.Add(Col2);
        LineNew.Add(Col3);
        DataTable.Add(DataTable.Count + 1, LineNew);
    end;

    local procedure addLine(Col1: Text; Col2: Text; Col3: Text; Col4: Text)
    var
        LineNew: List of [Text];
    begin
        LineNew.Add(Col1);
        LineNew.Add(Col2);
        LineNew.Add(Col3);
        LineNew.Add(Col4);
        DataTable.Add(DataTable.Count + 1, LineNew);
    end;

    var
        DataTable: Dictionary of [Integer/*Index*/, List of [Text]];
        noOfColumnsGlobal: Integer;
}