page 91028 DMTFieldLookUpV2
{
    Caption = 'DMTFieldLookUp';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTFieldLookUpBuffer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.") { ApplicationArea = All; }
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; Visible = FieldNameVisible; }
                field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; }
            }
        }
        area(Factboxes)
        {

        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        loadLines();
        exit(Rec.find(Which));
    end;

    local procedure loadLines() hasLines: Boolean
    begin
        ReadFilters();
        if isLoaded then exit;
        // Read Table Relation Field Filter
        loadLinesForTableID();
        loadLinesForImportConfig();
        hasLines := Rec.Count > 0;
        isLoaded := true;
    end;

    local procedure ReadFilters()
    var
        i: Integer;
        filters: Dictionary of [Integer, Text];
        views: Dictionary of [Integer, Text];
    begin
        for i := 0 to 10 do begin
            Rec.FilterGroup(i);
            filters.Add(i, Rec.GetFilters);
            views.Add(i, Rec.GetView());
        end;
    end;

    local procedure loadLinesForTableID() OK: Boolean
    var
        tempFieldSelectionBuffer: Record DMTFieldLookUpBuffer temporary;
        targetRef: RecordRef;
        tableNo: Integer;
        i: Integer;
    begin
        OK := true;
        Rec.FilterGroup(4);

        if not readFilterValue(tableNo, Rec, Rec.FieldNo("Table No."), 0) then
            if not readFilterValue(tableNo, Rec, Rec.FieldNo("Table No."), 4) then
                exit(false);
        targetRef.Open(tableNo);
        for i := 1 to targetRef.FieldCount do
            if targetRef.FieldIndex(i).Active then
                if (targetRef.FieldIndex(i).Class = targetRef.FieldIndex(i).Class::Normal) then begin
                    tempFieldSelectionBuffer.LookUpType := tempFieldSelectionBuffer.LookUpType::TargetFields;
                    tempFieldSelectionBuffer."Field No." := targetRef.FieldIndex(i).Number;
                    tempFieldSelectionBuffer."Field Name" := CopyStr(targetRef.FieldIndex(i).Name, 1, MaxStrLen(tempFieldSelectionBuffer."Field Name"));
                    tempFieldSelectionBuffer."Field Caption" := CopyStr(targetRef.FieldIndex(i).Caption, 1, MaxStrLen(tempFieldSelectionBuffer."Field Caption"));
                    tempFieldSelectionBuffer.Insert();
                end;
        Rec.FilterGroup(0);
        Rec.Copy(tempFieldSelectionBuffer, true);
    end;

    local procedure loadLinesForImportConfig() OK: Boolean
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        tempFieldSelectionBuffer: Record DMTFieldLookUpBuffer temporary;
        currType: Option " ","Source","Target";
        importConfigHeaderID, currTypeInt : Integer;
    begin
        OK := true;
        if not readFilterValue(importConfigHeaderID, Rec, Rec.FieldNo("Imp.Conf.Header ID"), 0) then
            if not readFilterValue(importConfigHeaderID, Rec, Rec.FieldNo("Imp.Conf.Header ID"), 4) then
                exit(false);

        if not readFilterValue(currTypeInt, Rec, Rec.FieldNo(LookUpType), 0) then
            if not readFilterValue(currTypeInt, Rec, Rec.FieldNo(LookUpType), 4) then
                exit(false);
        currType := currTypeInt;

        importConfigHeader.Get(importConfigHeaderID);
        importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        if importConfigLine.findset(false) then
            repeat
                case currType of
                    currType::Source:
                        begin
                            FieldNameVisible := false;
                            if (importConfigLine."Source Field No." <> 0) then begin // not every target field is mapped
                                tempFieldSelectionBuffer.LookUpType := tempFieldSelectionBuffer.LookUpType::SourceFields;
                                tempFieldSelectionBuffer."Field No." := importConfigLine."Source Field No.";
                                tempFieldSelectionBuffer."Field Caption" := importConfigLine."Source Field Caption";
                                tempFieldSelectionBuffer.Insert();
                            end;
                        end;
                    currType::Target:
                        begin
                            FieldNameVisible := true;
                            importConfigLine.CalcFields("Target Field Name", "Target Field Caption");
                            tempFieldSelectionBuffer.LookUpType := tempFieldSelectionBuffer.LookUpType::TargetFields;
                            tempFieldSelectionBuffer."Field No." := importConfigLine."Target Field No.";
                            tempFieldSelectionBuffer."Field Name" := importConfigLine."Target Field Name";
                            tempFieldSelectionBuffer."Field Caption" := importConfigLine."Target Field Caption";
                            tempFieldSelectionBuffer.Insert();
                        end;
                    else
                        error('unhandled case');
                end;
            until importConfigLine.next() = 0;
        Rec.FilterGroup(0);
        Rec.copy(tempFieldSelectionBuffer, true);
    end;

    local procedure readFilterValue(var filterValue: Integer; var fieldLookUpBuffer: Record DMTFieldLookUpBuffer temporary; filterfieldNo: Integer; searchInfiltergroup: Integer) hasFilter: Boolean
    var
        recRef: RecordRef;
    begin
        hasFilter := true;
        recRef.GetTable(fieldLookUpBuffer);
        recRef.FilterGroup(searchInfiltergroup);
        if recRef.Field(filterfieldNo).GetFilter = '' then
            exit(false);
        filterValue := recRef.Field(filterfieldNo).GetRangeMin;
    end;

    var
        isLoaded: Boolean;
        FieldNameVisible: Boolean;

}