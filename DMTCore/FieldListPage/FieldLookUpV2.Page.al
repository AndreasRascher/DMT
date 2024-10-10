page 91028 DMTFieldLookUpV2
{
    Caption = 'DMTFieldLookUp';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTFieldSelectionBuffer;
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
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        tempFieldSelectionBuffer: Record DMTFieldSelectionBuffer temporary;
        currFilter: Text;
        importConfigHeaderID: Integer;
        currType: Option " ","Source","Target";
    begin
        ReadFilters();
        if isLoaded then exit;
        // Read Table Relation Field Filter
        Rec.FilterGroup(4);
        currFilter := Rec.Getfilter("Imp.Conf.Header ID");
        if Rec.Getfilter("Imp.Conf.Header ID") = '' then
            exit(false);
        Evaluate(importConfigHeaderID, currFilter);
        //importConfigHeaderID := Rec.GetRangeMin("Imp.Conf.Header ID");
        // Read Table Relation Const Filter
        Rec.FilterGroup(0);
        currFilter := Rec.GetFilter(Type);
        if Rec.GetFilter(Type) = '' then
            exit(false);
        currType := Rec.GetRangeMin(Type);

        importConfigHeader.Get(importConfigHeaderID);
        importConfigLine.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        if importConfigLine.findset(false) then
            repeat
                case currType of
                    currType::Source:
                        begin
                            tempFieldSelectionBuffer.Type := tempFieldSelectionBuffer.Type::Source;
                            tempFieldSelectionBuffer."Field No." := importConfigLine."Source Field No.";
                            tempFieldSelectionBuffer."Field Caption" := importConfigLine."Source Field Caption";
                            tempFieldSelectionBuffer.Insert();
                        end;
                    currType::Target:
                        begin
                            importConfigLine.CalcFields("Target Field Name", "Target Field Caption");
                            tempFieldSelectionBuffer.Type := tempFieldSelectionBuffer.Type::Target;
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
        hasLines := Rec.Count > 0;
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

    // procedure LoadLines()
    // var
    //     TempDataLayoutLine: Record DMTDataLayoutLine temporary;
    //     ImportConfigHeader: Record DMTImportConfigHeader;
    //     ImportConfigLine: Record DMTImportConfigLine;
    //     importConfigMgt: Codeunit DMTImportConfigMgt;
    //     BuffTableCaptions: Dictionary of [Integer, Text];
    //     importConfigID: Integer;
    //     FieldLookUpMode: Option "Look Up Source","Look Up Target";
    //     TargetFieldNames: Dictionary of [Integer, Text];
    // begin
    //     if IsLoaded then exit;
    //     Clear(BuffTableCaptions);
    //     ReadImportConfigIDFromTableRelationFilter(importConfigID, FieldLookUpMode);
    //     case true of
    //         (importConfigID <> 0) and (FieldLookUpMode = FieldLookUpMode::"Look Up Source"):
    //             begin
    //                 ImportConfigHeader.Get(importConfigID);
    //                 ImportConfigHeader.BufferTableMgt().ReadBufferTableColumnCaptions(BuffTableCaptions);
    //                 CopyColumnCaptionsToTempDataLayoutLine(TempDataLayoutLine, BuffTableCaptions);
    //                 Rec.Copy(TempDataLayoutLine, true);
    //                 IsLoaded := true;
    //             end;
    //         (importConfigID <> 0) and (FieldLookUpMode = FieldLookUpMode::"Look Up Target"):
    //             begin
    //                 ImportConfigHeader.Get(importConfigID);
    //                 ImportConfigLine.SetRange("Imp.Conf.Header ID", importConfigID);
    //                 TargetFieldNames := importConfigMgt.CreateTargetFieldNamesDict(ImportConfigLine, false);
    //                 CopyColumnCaptionsToTempDataLayoutLine(TempDataLayoutLine, TargetFieldNames);
    //                 Rec.Copy(TempDataLayoutLine, true);
    //                 IsLoaded := true;
    //             end;
    //         else
    //             Error('unhandled case');
    //     end;

    var
        isLoaded: Boolean;

}