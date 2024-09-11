codeunit 50031 DMTDataTableMgt
{
    internal procedure setCaptions(caption1: Text; caption2: Text; caption3: Text)
    begin
        Clear(CaptionsList);
        CaptionsList.AddRange(caption1, caption2, caption3);
        Clear(Captions);
        Captions.Add(1, caption1);
        Captions.Add(2, caption2);
        Captions.Add(3, caption3);
        IsInitialized := true;
    end;

    internal procedure addLine(col1Content: Variant; col2Content: Variant; col3Content: Variant)
    var
        LineNew: List of [Text];
    begin
        LineNew.AddRange(format(col1Content, 0, 9), format(col2Content, 0, 9), format(col3Content, 0, 9));
        DataTable.Add(DataTable.Count + 1, LineNew);
        IsInitialized := true;
    end;

    internal procedure Get(columnCaption: Text; lineIndex: Integer; currContext: Text) columnContent: Text
    var
        columnIndex: Integer;
    begin
        if (currContext <> ContextGlobal) and (currContext <> '') then
            exit('');
        columnIndex := Captions.Values.IndexOf(columnCaption);
        if columnIndex = 0 then
            //Error('Column not found %1\Context: %2', ColumnCaption, ContextGlobal);
            exit('ColNotFound - ' + ContextGlobal);
        columnContent := Get(columnIndex, lineIndex, columnCaption, currContext);
    end;

    internal procedure Get(ColumnIndex: Integer; lineIndex: Integer; debugColumnCaptionContext: Text; currContext: Text) columnContent: Text
    var
        line: List of [Text];
    begin
        if (currContext <> ContextGlobal) and (currContext <> '') then
            exit('');
        if not DataTable.Get(lineIndex, line) then
            exit(StrSubstNo('ColValueNotFound (%1-%2)', debugColumnCaptionContext, ContextGlobal));
        if (ColumnIndex < 1) or (ColumnIndex > line.Count) then
            Error('hier');
        columnContent := line.Get(ColumnIndex);
    end;

    internal procedure Count(): Integer
    begin
        throwErrorIfNoInitalized();
        exit(DataTable.Count());
    end;

    internal procedure Dispose()
    begin
        Clear(CaptionsList);
        Clear(Captions);
        Clear(DataTable);
        Clear(ContextGlobal);
    end;

    internal procedure setContext(contextNew: Text)
    begin
        ContextGlobal := contextNew;
    end;

    internal procedure Constant_RequirementList(): Text
    begin
        exit('RequirementsList');
    end;

    internal procedure Constant_StepsView(): Text
    begin
        exit('StepsView');
    end;

    internal procedure Constant_ReqData(): Text
    begin
        exit('ReqData');
    end;

    local procedure throwErrorIfNoInitalized()
    begin
        if not IsInitialized then
            Error('Data table not initialized');
    end;

    var
        ContextGlobal: Text;
        CaptionsList: List of [Text];
        Captions: Dictionary of [Integer/*ColumnNo*/, Text/*Caption Text*/];
        DataTable: Dictionary of [Integer/*Index*/, List of [Text]];
        IsInitialized: Boolean;
}