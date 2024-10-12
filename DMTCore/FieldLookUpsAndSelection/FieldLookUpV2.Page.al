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
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; }
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
        if rec.GetFilter("Table No.") = '' then
            exit(false);
        tableNo := Rec.GetRangeMin("Table No.");
        targetRef.Open(tableNo);
        for i := 1 to targetRef.FieldCount do
            if targetRef.FieldIndex(i).Active then
                if (targetRef.FieldIndex(i).Class = targetRef.FieldIndex(i).Class::Normal) then begin
                    tempFieldSelectionBuffer.LookUpType := tempFieldSelectionBuffer.LookUpType::TargetFields;
                    tempFieldSelectionBuffer."Field No." := targetRef.FieldIndex(i).Number;
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
        currFilter: Text;
        currType: Option " ","Source","Target";
        importConfigHeaderID: Integer;
    begin
        OK := true;
        Rec.FilterGroup(4);
        currFilter := Rec.Getfilter("Imp.Conf.Header ID");
        if Rec.Getfilter("Imp.Conf.Header ID") = '' then
            exit(false);
        Evaluate(importConfigHeaderID, currFilter);
        //importConfigHeaderID := Rec.GetRangeMin("Imp.Conf.Header ID");
        // Read Table Relation Const Filter
        Rec.FilterGroup(0);
        currFilter := Rec.GetFilter(LookUpType);
        if Rec.GetFilter(LookUpType) = '' then
            exit(false);
        currType := Rec.GetRangeMin(LookUpType);

        importConfigHeader.Get(importConfigHeaderID);
        importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        if importConfigLine.findset(false) then
            repeat
                case currType of
                    currType::Source:
                        begin
                            tempFieldSelectionBuffer.LookUpType := tempFieldSelectionBuffer.LookUpType::SourceFields;
                            tempFieldSelectionBuffer."Field No." := importConfigLine."Source Field No.";
                            tempFieldSelectionBuffer."Field Caption" := importConfigLine."Source Field Caption";
                            tempFieldSelectionBuffer.Insert();
                        end;
                    currType::Target:
                        begin
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

    var
        isLoaded: Boolean;

}