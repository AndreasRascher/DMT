codeunit 91012 DMTFPBuilder
{
    /// <summary>
    /// Filter page for RecordRef
    /// </summary>
    /// <returns>Continue - True when filterpage was closed with OK-Button</returns>
    procedure RunModal(var RecRef: RecordRef; ShowKeyFieldsAsFilterFields: Boolean) Continue: Boolean;
    begin
        Continue := RunModalInner(RecRef, InitKeyFieldFilter(RecRef), ShowKeyFieldsAsFilterFields);
    end;

    /// <summary>
    /// Filter page for DMT buffer tables
    /// </summary>
    /// <returns>Continue - True when filterpage was closed with OK-Button</returns>
    procedure RunModal(var RecRef: RecordRef; var ImportConfigHeader: Record DMTImportConfigHeader; ShowKeyFieldsAsFilterFields: Boolean) Continue: Boolean;
    begin
        Continue := RunModalInner(RecRef, InitKeyFieldFilter(RecRef, ImportConfigHeader), ShowKeyFieldsAsFilterFields);
    end;

    local procedure RunModalInner(var BufferRef: RecordRef; FilterFields: Dictionary of [Integer, Text]; ShowKeyFieldsAsFilterFields: Boolean) Continue: Boolean;
    var
        FPBuilder: FilterPageBuilder;
    begin
        FPBuilder.AddTable(BufferRef.Caption, BufferRef.Number);// ADD DATAITEM
        if BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SetView(BufferRef.Caption, BufferRef.GetView());
        if ShowKeyFieldsAsFilterFields then
            AddFilterFields(FPBuilder, FilterFields);
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RunModal();
        BufferRef.SetView(FPBuilder.GetView(BufferRef.Caption));
    end;

    local procedure InitKeyFieldFilter(var BufferRef: RecordRef; var ImportConfigHeader: Record DMTImportConfigHeader) FilterFields: Dictionary of [Integer/*FieldNo*/, Text/*TableCaption*/]
    var
        ImportConfigLine: Record DMTImportConfigLine;
        GenBuffTable: Record DMTGenBuffTable;
        Debug: Text;
    begin
        case true of
            // If Generic Buffer is Source
            (ImportConfigHeader.ID <> 0) and not ImportConfigHeader."Use Separate Buffer Table" and (ImportConfigHeader.FilterRelated(ImportConfigLine)):
                begin
                    // Init Captions
                    if GenBuffTable.FilterBy(ImportConfigHeader) then
                        if GenBuffTable.FindFirst() then
                            GenBuffTable.InitFirstLineAsCaptions(GenBuffTable);
                    Debug := GenBuffTable.FieldCaption(Fld001);
                    ImportConfigLine.SetRange("Is Key Field(Target)", true);
                    if ImportConfigLine.FindSet() then
                        repeat
                            FilterFields.Add(ImportConfigLine."Source Field No.", GenBuffTable.TableCaption);
                        until ImportConfigLine.Next() = 0;
                end;
            // Other
            else begin
                FilterFields := InitKeyFieldFilter(BufferRef);
            end;
        end;
    end;

    local procedure InitKeyFieldFilter(var BufferRef: RecordRef) FilterFields: Dictionary of [Integer/*FieldNo*/, Text/*TableCaption*/]
    var
        PrimaryKeyRef: KeyRef;
        Index: Integer;
    begin
        PrimaryKeyRef := BufferRef.KeyIndex(1);
        for Index := 1 to PrimaryKeyRef.FieldCount do
            FilterFields.Add(PrimaryKeyRef.FieldIndex(Index).Number, BufferRef.Caption);
    end;

    local procedure AddFilterFields(var FPBuilder: FilterPageBuilder; FilterFields: Dictionary of [Integer/*FieldNo*/, Text/*TableCaption*/])
    var
        FieldNo: Integer;
    begin
        foreach FieldNo in FilterFields.Keys do begin
            FPBuilder.AddFieldNo(FilterFields.Get(FieldNo), FieldNo);
        end;
    end;

    procedure GetFiltersFrom(var recRef: RecordRef) FilterDetailsJSON: Text
    var
        filtergroupIndex, fieldIndex : Integer;
        JObj, JResult : JsonObject;
        JFilters: JsonArray;
    begin
        for filtergroupIndex := -1 to 9 do begin
            recRef.FilterGroup(filtergroupIndex);
            if recRef.GetFilters <> '' then begin
                Clear(JFilters);
                for fieldIndex := 1 to recRef.FieldCount do begin
                    if recRef.FieldIndex(fieldIndex).GetFilter <> '' then begin
                        Clear(JObj);
                        JObj.Add(format(recRef.FieldIndex(fieldIndex).Number), recRef.FieldIndex(fieldIndex).GetFilter);
                        JFilters.Add(JObj);
                    end;
                    // JFilterGroupsWithFilters.Add(JObj);
                end;
                if JFilters.Count > 0 then
                    JResult.Add(StrSubstNo('Filtergroup %1', filtergroupIndex), JFilters);
            end;
        end;
        if JResult.Keys.Count > 0 then
            JResult.Add('RecordNumber', recRef.Number);
        JResult.WriteTo(FilterDetailsJSON);
    end;

    /// <summary>
    /// Initialize recordref for the given ImportConfigHeader (buffer table) and apply filters
    /// </summary>
    procedure OpenRecRefWithFilters(var recRef: RecordRef; ImportConfigHeaderID: Integer; FilterDetailsJSON: Text)
    var
        ImportConfigHeader: Record DMTImportConfigHeader;
    begin
        ImportConfigHeader.Get(ImportConfigHeaderID);
        ImportConfigHeader.InitBufferRef(RecRef);
        RestorFiltersForRecRef(recRef, FilterDetailsJSON, true);
    end;

    procedure RestorFiltersForRecRef(var recRef: RecordRef; FilterDetailsJSON: Text; IsRecRefOpen: Boolean)
    var
        FiltergroupIndex, FieldNo, ArrayIndex : Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        JFilters: JsonArray;
        Filter: Text;
    begin
        if FilterDetailsJSON = '' then
            exit;

        JObj.ReadFrom(FilterDetailsJSON);
        JObj.Get('RecordNumber', JToken);
        if not IsRecRefOpen then
            recRef.Open(JToken.AsValue().AsInteger());
        for FiltergroupIndex := -1 to 9 do begin
            Clear(JToken);
            if JObj.Get(StrSubstNo('Filtergroup %1', FiltergroupIndex), JToken) then begin
                JFilters := JToken.AsArray();
                recRef.FilterGroup(FiltergroupIndex);
                for ArrayIndex := 1 to JFilters.Count do begin
                    JFilters.Get(ArrayIndex - 1, JToken);
                    Evaluate(FieldNo, JToken.AsObject().Keys.Get(1));
                    Filter := JToken.AsObject().Values.Get(1).AsValue().AsText();
                    recRef.Field(FieldNo).SetFilter(Filter);
                end;
            end;
        end;
    end;

}