codeunit 91018 "DMTReplacementsMgt"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Table, Database::DMTImportConfigHeader, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure DMTImportConfigHeader_OnBeforeDeleteEvent(var Rec: Record DMTImportConfigHeader; RunTrigger: Boolean)
    var
        Replacement: Record DMTReplacement;
    begin
        if Rec.IsTemporary or not RunTrigger then exit;
        Replacement.SetRange("Imp.Conf.Header ID", Rec.ID);
        Replacement.SetRange(LineType, Replacement.LineType::Assignment);
        if not Replacement.IsEmpty then
            Replacement.DeleteAll();
    end;

    procedure InitFor(ImportConfigHeader: record DMTImportConfigHeader; var SourceRef: RecordRef; TargetTableID: Integer)
    var
        CompareFieldNumbers: List of [Integer];
    begin
        HasReplacements := false;
        if not IsInitialized then begin
            IsInitialized := true;
            if not LoadImportConfigHeaderAssignments(ReplacementAssignmentForImportConfigHeaderGlobal, ImportConfigHeader) then
                exit;
            if not LoadReplacementLines(ReplacementLineGlobal, ReplacementAssignmentForImportConfigHeaderGlobal) then
                exit;
            if not FindArgumentFieldNumbers(CompareFieldNumbers, ReplacementAssignmentForImportConfigHeaderGlobal) then
                exit;
        end;
        HasReplacements := FindReplacementValues(SourceRef, CompareFieldNumbers, TargetTableID);
    end;

    procedure HasReplacementForTargetField(TargetFieldNo: Integer) Result: Boolean
    begin
        Result := NewValueFieldNumbersGlobal.Contains(TargetFieldNo);
    end;

    internal procedure GetReplacmentValueFor(Number: Integer) ReturnField: FieldRef
    var
        Position: Integer;
    begin
        Position := NewValueFieldNumbersGlobal.IndexOf(Number);
        ReturnField := NewValueFieldArrayGlobal[Position];
    end;

    local procedure FindReplacementValues(var SourceRef: RecordRef; CompareFieldNumbers: List of [Integer]; TargetTableID: Integer) HasReplacementValues: Boolean
    var
        CompareFieldValueArray: array[16] of FieldRef;
    begin
        ReadCompareFields(CompareFieldValueArray, SourceRef, CompareFieldNumbers);
        HasReplacementValues := FindNewValueFields(NewValueFieldArrayGlobal, NewValueFieldNumbersGlobal, CompareFieldValueArray, CompareFieldNumbers, ReplacementLineGlobal, TargetTableID);
    end;

    local procedure LoadImportConfigHeaderAssignments(var ReplacementAssignmentForImportConfigHeader: Record DMTReplacement temporary; ImportConfigHeader: Record DMTImportConfigHeader) Found: Boolean
    var
        ReplacementAssignment: Record DMTReplacement;
        TempReplacementAssignment: Record DMTReplacement temporary;
    begin
        ReplacementAssignment.SetRange(LineType, ReplacementAssignment.LineType::Assignment);
        ReplacementAssignment.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        if not ReplacementAssignment.FindSet() then
            exit(false);
        repeat
            TempReplacementAssignment := ReplacementAssignment;
            TempReplacementAssignment.Insert();
        until ReplacementAssignment.Next() = 0;
        ReplacementAssignmentForImportConfigHeader.Copy(TempReplacementAssignment, true);
        Found := ReplacementAssignmentForImportConfigHeader.FindFirst();
    end;

    local procedure LoadReplacementLines(var TempReplacementLineNew: Record DMTReplacement temporary; var ReplacementAssignmentForImportConfigHeader: Record DMTReplacement temporary) Found: Boolean
    var
        ReplacementLine: Record DMTReplacement;
        TempReplacementLine: Record DMTReplacement temporary;
    begin
        if not ReplacementAssignmentForImportConfigHeader.FindSet() then
            exit(false);
        repeat
            ReplacementLine.SetRange(LineType, ReplacementLine.LineType::Line);
            ReplacementLine.SetRange("Replacement Code", ReplacementAssignmentForImportConfigHeader."Replacement Code");
            if ReplacementLine.FindSet() then
                repeat
                    if not TempReplacementLine.Get(ReplacementLine.RecordId) then begin
                        TempReplacementLine := ReplacementLine;
                        TempReplacementLine.Insert();
                    end;
                until ReplacementLine.Next() = 0;
        until ReplacementAssignmentForImportConfigHeader.Next() = 0;
        TempReplacementLineNew.Copy(TempReplacementLine, true);
        Found := TempReplacementLineNew.FindFirst();
    end;

    local procedure FindArgumentFieldNumbers(var ArgumentFieldNumbers: List of [Integer]; var ReplacementAssignmentForImportConfigHeader: Record DMTReplacement temporary) Found: Boolean
    var
        CompareFieldNo, i : Integer;
    begin
        Clear(ArgumentFieldNumbers);
        if not ReplacementAssignmentForImportConfigHeader.FindSet() then
            exit(false);
        repeat
            for i := 1 to 2 do begin
                case i of
                    1:
                        CompareFieldNo := ReplacementAssignmentForImportConfigHeader."Compare Value 1 Field No.";
                    2:
                        CompareFieldNo := ReplacementAssignmentForImportConfigHeader."Compare Value 2 Field No.";
                end;
                if CompareFieldNo <> 0 then
                    if not ArgumentFieldNumbers.Contains(CompareFieldNo) then
                        ArgumentFieldNumbers.Add(CompareFieldNo);
            end;
        until ReplacementAssignmentForImportConfigHeader.Next() = 0;
        Found := ArgumentFieldNumbers.Count > 0;
    end;

    local procedure ReadCompareFields(var ArgumentFieldRefArray: array[16] of FieldRef; var SourceRef: RecordRef; ArgumentFieldNumbers: List of [Integer])
    var
        i: Integer;
    begin
        Clear(ArgumentFieldRefArray);
        if ArgumentFieldNumbers.Count > ArrayLen(ArgumentFieldRefArray) then
            Error('ReadArgumentFieldValues: Too many arguments for FieldRefArray');
        for i := 1 to ArgumentFieldNumbers.Count do begin
            ArgumentFieldRefArray[i] := SourceRef.Field(ArgumentFieldNumbers.Get(i));
        end;
    end;

    local procedure FindNewValueFields(var NewValueFieldArray: array[16] of FieldRef; var NewValueFieldNumbers: List of [Integer]; CompareFieldValueArray: array[16] of FieldRef; CompareFieldNumbers: List of [Integer]; var TempReplacementLine: Record DMTReplacement temporary; TargetTableID: Integer) Found: Boolean
    var
        ReplacementHeader: Record DMTReplacement;
        DummyTargetRef: RecordRef;
        IsMatch: Boolean;
        ArrayPos: Integer;
    begin
        Clear(NewValueFieldArray);
        Clear(NewValueFieldNumbers);
        DummyTargetRef.Open(TargetTableID, true);
        TempReplacementLine.FindSet();
        repeat
            Clear(IsMatch);
            TempReplacementLine.TestField(LineType, TempReplacementLine.LineType::Line);
            // Get Header
            ReplacementHeader.Get(TempReplacementLine.LineType::Header, TempReplacementLine."Replacement Code", 0);
            // Get Assignment
            ReplacementAssignmentForImportConfigHeaderGlobal.reset();
            ReplacementAssignmentForImportConfigHeaderGlobal.SetRange("Replacement Code", TempReplacementLine."Replacement Code");
            ReplacementAssignmentForImportConfigHeaderGlobal.FindFirst();

            case ReplacementHeader."No. of Compare Values" of
                ReplacementHeader."No. of Compare Values"::"1":
                    begin
                        IsMatch := format(CompareFieldValueArray[1].Value) = TempReplacementLine."Comp.Value 1";
                    end;
                ReplacementHeader."No. of Compare Values"::"2":
                    begin
                        IsMatch := format(CompareFieldValueArray[1].Value) = TempReplacementLine."Comp.Value 1";
                        IsMatch := IsMatch and (format(CompareFieldValueArray[2].Value) = TempReplacementLine."Comp.Value 2");
                    end;
                else
                    error('unhandled case');
            end;

            if IsMatch then begin
                case ReplacementHeader."No. of Values to modify" of
                    ReplacementHeader."No. of Values to modify"::"1":
                        begin
                            ReplacementAssignmentForImportConfigHeaderGlobal.Testfield("New Value 1 Field No.");
                            NewValueFieldNumbers.Add(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            StoreArrayPosForTargetFieldNo(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            ArrayPos := GetArrayPosByTargetFieldNo(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos] := DummyTargetRef.Field(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos].Value(TempReplacementLine."New Value 1");
                        end;
                    ReplacementHeader."No. of Values to modify"::"2":
                        begin
                            ReplacementAssignmentForImportConfigHeaderGlobal.Testfield("New Value 1 Field No.");
                            NewValueFieldNumbers.Add(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            StoreArrayPosForTargetFieldNo(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            ArrayPos := GetArrayPosByTargetFieldNo(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos] := DummyTargetRef.Field(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos].Value(TempReplacementLine."New Value 1");

                            ReplacementAssignmentForImportConfigHeaderGlobal.Testfield("New Value 2 Field No.");
                            NewValueFieldNumbers.Add(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 2 Field No.");
                            StoreArrayPosForTargetFieldNo(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 2 Field No.");
                            ArrayPos := GetArrayPosByTargetFieldNo(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 2 Field No.");
                            NewValueFieldArray[ArrayPos] := DummyTargetRef.Field(ReplacementAssignmentForImportConfigHeaderGlobal."New Value 2 Field No.");
                            NewValueFieldArray[ArrayPos].Value(TempReplacementLine."New Value 2");
                        end;
                    else
                        error('unhandled case');
                end;
            end;
        until TempReplacementLine.Next() = 0;
        Found := NewValueFieldNumbers.Count > 0;
    end;

    local procedure LoadImportConfigLineForMatchingTableRelations(var TempImportConfigLineFound: Record DMTImportConfigLine temporary; RelatedTableID: Integer; TableNoFilter: Text) NoOfLinesFound: Integer
    var
        ImportConfigLine: Record DMTImportConfigLine;
        TableRelationsMetadata: Record "Table Relations Metadata";
        TempImportConfigLine: Record DMTImportConfigLine temporary;
    begin
        TableRelationsMetadata.SetRange("Condition Field No.", 0); // else Conditions (e.g.Bin) and tablerelation=Tablename conditions
        TableRelationsMetadata.SetFilter("Table ID", TableNoFilter);
        TableRelationsMetadata.SetRange("Related Table ID", RelatedTableID);
        TableRelationsMetadata.SetFilter("Related Field No.", '<>2000000000'); // no systemid relations
        // TableRelationsMetadata.SetRange("Related Field No.", 1);
        // Collect Matching Fields
        if TableRelationsMetadata.FindSet() then
            repeat
                ImportConfigLine.Reset();
                ImportConfigLine.SetRange("Target Table ID", TableRelationsMetadata."Table ID");
                ImportConfigLine.SetRange("Target Field No.", TableRelationsMetadata."Field No.");
                if ImportConfigLine.FindSet() then
                    repeat
                        TempImportConfigLine := ImportConfigLine;
                        if TempImportConfigLine.Insert() then;
                    until ImportConfigLine.Next() = 0;
            until TableRelationsMetadata.Next() = 0;
        TempImportConfigLineFound.Copy(TempImportConfigLine, true);
        NoOfLinesFound := TempImportConfigLineFound.Count;
    end;

    internal procedure proposeAssignments(ReplacementHeader: Record DMTReplacement)
    var
        TempImportConfigLineFound: array[2] of Record DMTImportConfigLine temporary;
        ImportConfigHeader: Record DMTImportConfigHeader;
        ReplacementAssignments: Record DMTReplacement;
        TableNoFilter: Text;
    begin
        ReplacementHeader.TestField(LineType, ReplacementHeader.LineType::Header);

        // Search Relations in Target Fields
        //ImportConfigHeader.SetFilter(ID, '48|106'); //debug
        if ImportConfigHeader.FindSet(false) then
            repeat
                TableNoFilter += StrSubstNo('%1|', ImportConfigHeader."Target Table ID");
            until ImportConfigHeader.Next() = 0;
        TableNoFilter := TableNoFilter.TrimEnd('|');
        // Filter Relations
        case ReplacementHeader."No. of Values to modify" of
            ReplacementHeader."No. of Values to modify"::"1":
                begin
                    ReplacementHeader.Testfield("Rel.to Table ID (New Val.1)");
                    LoadImportConfigLineForMatchingTableRelations(TempImportConfigLineFound[1], ReplacementHeader."Rel.to Table ID (New Val.1)", TableNoFilter);
                end;
            ReplacementHeader."No. of Values to modify"::"2":
                begin
                    ReplacementHeader.Testfield("Rel.to Table ID (New Val.1)");
                    LoadImportConfigLineForMatchingTableRelations(TempImportConfigLineFound[1], ReplacementHeader."Rel.to Table ID (New Val.1)", TableNoFilter);
                    ReplacementHeader.Testfield("Rel.to Table ID (New Val.2)");
                    LoadImportConfigLineForMatchingTableRelations(TempImportConfigLineFound[2], ReplacementHeader."Rel.to Table ID (New Val.2)", TableNoFilter);
                end;
            else
                Error('Unhandled Option');
        end;

        // Add Assignments if match for all fields exist
        ImportConfigHeader.Reset();
        ImportConfigHeader.SetFilter(ID, '48|106'); //debug
        if ImportConfigHeader.FindSet() then
            repeat
                ReplacementAssignments.Reset();
                ReplacementAssignments.SetRange("Replacement Code", ReplacementHeader."Replacement Code");
                if not ReplacementAssignments.filterAssignmentFor(ImportConfigHeader) then begin
                    case ReplacementHeader."No. of Values to modify" of
                        ReplacementHeader."No. of Values to modify"::"1":
                            begin
                                // Find Matching ImportConfigLine with Relations
                                TempImportConfigLineFound[1].Reset();
                                TempImportConfigLineFound[1].SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
                                TempImportConfigLineFound[1].SetRange("Target Table ID", ImportConfigHeader."Target Table ID");
                                if TempImportConfigLineFound[1].FindFirst() then begin
                                    Clear(ReplacementAssignments);
                                    ReplacementAssignments.LineType := ReplacementAssignments.LineType::Assignment;
                                    ReplacementAssignments."Replacement Code" := ReplacementHeader."Replacement Code";
                                    ReplacementAssignments."Imp.Conf.Header ID" := ImportConfigHeader.ID;
                                    ReplacementAssignments."Target Table ID" := ImportConfigHeader."Target Table ID";
                                    ReplacementAssignments."Compare Value 1 Field No." := TempImportConfigLineFound[1]."Source Field No.";
                                    ReplacementAssignments."New Value 1 Field No." := TempImportConfigLineFound[1]."Target Field No.";
                                    ReplacementAssignments.Insert(true);
                                    Commit();
                                end;
                            end;
                        ReplacementHeader."No. of Values to modify"::"2":
                            begin
                                // Find Matching ImportConfigLine with Relations
                                TempImportConfigLineFound[1].Reset();
                                TempImportConfigLineFound[1].SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
                                TempImportConfigLineFound[1].SetRange("Target Table ID", ImportConfigHeader."Target Table ID");
                                TempImportConfigLineFound[2].Reset();
                                TempImportConfigLineFound[2].SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
                                TempImportConfigLineFound[2].SetRange("Target Table ID", ImportConfigHeader."Target Table ID");
                                if TempImportConfigLineFound[1].FindFirst() and TempImportConfigLineFound[2].FindFirst() then begin
                                    Clear(ReplacementAssignments);
                                    ReplacementAssignments.LineType := ReplacementAssignments.LineType::Assignment;
                                    ReplacementAssignments."Replacement Code" := ReplacementHeader."Replacement Code";
                                    ReplacementAssignments."Imp.Conf.Header ID" := ImportConfigHeader.ID;
                                    ReplacementAssignments."Target Table ID" := ImportConfigHeader."Target Table ID";
                                    ReplacementAssignments."Compare Value 1 Field No." := TempImportConfigLineFound[1]."Source Field No.";
                                    ReplacementAssignments."New Value 1 Field No." := TempImportConfigLineFound[1]."Target Field No.";
                                    if ReplacementHeader."No. of Compare Values" in [ReplacementHeader."No. of Compare Values"::"2"] then
                                        ReplacementAssignments."Compare Value 2 Field No." := TempImportConfigLineFound[2]."Source Field No.";
                                    ReplacementAssignments."New Value 2 Field No." := TempImportConfigLineFound[2]."Target Field No.";
                                    ReplacementAssignments.Insert(true);
                                    Commit();
                                end;
                            end;
                        else
                            Error('Unhandled Option');
                    end;
                end;
            until ImportConfigHeader.Next() = 0

    end;

    procedure StoreArrayPosForTargetFieldNo(TargetFieldNo: Integer)
    begin
        // Stack new field nos
        if not FieldPosArrayPosMappingGlobal.ContainsKey(TargetFieldNo) then
            FieldPosArrayPosMappingGlobal.Add(TargetFieldNo, FieldPosArrayPosMappingGlobal.Values.Count + 1);
    end;

    procedure GetArrayPosByTargetFieldNo(TargetFieldNo: Integer) ArrayPos: Integer
    begin
        ArrayPos := FieldPosArrayPosMappingGlobal.Get(TargetFieldNo);
    end;


    var
        ReplacementAssignmentForImportConfigHeaderGlobal, ReplacementLineGlobal : Record DMTReplacement temporary;
        NewValueFieldArrayGlobal: array[16] of FieldRef;
        HasReplacements, IsInitialized : Boolean;
        NewValueFieldNumbersGlobal: List of [Integer];
        FieldPosArrayPosMappingGlobal: Dictionary of [Integer, Integer];

}