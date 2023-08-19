codeunit 91019 ReplacementHandlerImpl implements IReplacementHandler
{
    SingleInstance = true;
    procedure InitBatchProcess(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        replacementAssignments, replacement : Record DMTReplacement;
    begin
        //load assigned replacements
        replacementAssignments.SetRange("Line Type", replacementAssignments."Line Type"::Assignment);
        replacementAssignments.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        if replacementAssignments.FindSet() then
            repeat
                // collect replacements
                if not TempReplacementGlobal.Get(TempReplacementGlobal."Line Type"::Replacement, replacementAssignments.Code) then begin
                    replacement.Get(TempReplacementGlobal."Line Type"::Replacement, replacementAssignments.Code);
                    TempReplacementGlobal := replacement;
                    TempReplacementGlobal.Insert();
                end;
                // collect replacement assignments
                if not TempReplacementAssignment.Get(replacementAssignments.RecordId) then begin
                    TempReplacementAssignment := replacementAssignments;
                    TempReplacementAssignment.Insert();
                end;
            until replacementAssignments.Next() = 0;

        // collect rules
        TempReplacementGlobal.Reset();
        if TempReplacementGlobal.FindSet() then
            repeat
                replacement.Reset();
                replacement.SetRange(Code, TempReplacementGlobal.Code);
                replacement.SetRange("Line Type", replacement."Line Type"::Rule);
                if replacement.FindSet() then
                    repeat
                        if not TempReplacementRule.get(replacement.RecordId) then begin
                            TempReplacementRule := replacement;
                            TempReplacementRule.Insert(false);
                        end;
                    until replacement.Next() = 0;
            until TempReplacementGlobal.Next() = 0;

        //         Workflow
        // - Regel anlegen(Code Beschreibung)
        // - Anzahl Felder definieren
        // - Regeln definieren
        // - Felder auswählen
        ImportConfigHeaderGlobal := ImportConfigHeader;
    end;

    procedure InitProcess(var SourceRef: RecordRef);
    var
        importConfigLine: Record DMTImportConfigLine;
        FromValue: Text;
    begin
        clear(ReplacementValues);
        if TempReplacementAssignment.FindFirst() then begin
            importConfigLine.get(TempReplacementAssignment."Imp.Conf.Header ID", TempReplacementAssignment."Compare Value 1 Field No.");
            FromValue := SourceRef.Field(importConfigLine."Source Field No.").Value;
            TempReplacementRule.Reset();
            TempReplacementRule.SetRange("Comp.Value 1", FromValue);
            if TempReplacementRule.FindFirst() then
                ReplacementValues.Add(TempReplacementAssignment."Compare Value 1 Field No.", TempReplacementRule."New Value 1");
        end;
    end;

    procedure HasReplacementsForTargetField(TargetFieldNo: Integer) HasReplacements: Boolean;
    begin
        HasReplacements := ReplacementValues.ContainsKey(TargetFieldNo);
    end;

    procedure GetReplacementValue(TargetFieldNo: Integer) TargetFieldValue: FieldRef;
    var
        RefHelper: Codeunit DMTRefHelper;
        rRef: RecordRef;
    begin
        rRef.Open(ImportConfigHeaderGlobal."Target Table ID");
        TargetFieldValue := rRef.Field(TargetFieldNo);
        RefHelper.AssignFixedValueToFieldRef(TargetFieldValue, ReplacementValues.Get(TargetFieldNo));
    end;

    procedure RemoveAssignmentOnDelete(var ImportConfigLine: Record DMTImportConfigLine)
    var
        replacement: Record DMTReplacement;
    begin
        replacement.SetRange("Line Type", replacement."Line Type"::Assignment);
        replacement.SetRange("Imp.Conf.Header ID", ImportConfigLine."Imp.Conf.Header ID");
        replacement.SetRange("Compare Value 1 Field No.", ImportConfigLine."Target Field No.");
        if not replacement.IsEmpty then
            replacement.DeleteAll(true);
    end;

    var
        TempReplacementGlobal, TempReplacementRule, TempReplacementAssignment : Record DMTReplacement temporary;
        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        ReplacementValues: Dictionary of [Integer, Text];
}