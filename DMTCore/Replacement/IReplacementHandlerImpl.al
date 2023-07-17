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
                        TempReplacementRule := replacement;
                        TempReplacementRule.Insert(false);
                    until replacement.Next() = 0;
            until TempReplacementGlobal.Next() = 0;

        //         Workflow
        // - Regel anlegen(Code Beschreibung)
        // - Anzahl Felder definieren
        // - Regeln definieren
        // - Felder auswählen
    end;

    procedure InitProcess(var SourceRef: RecordRef);
    begin
    end;

    procedure HasReplacementsForTargetField(TargetFieldNo: Integer) HasReplacements: Boolean;
    begin
    end;

    procedure GetReplacementValue(TargetFieldNo: Integer) TargetFieldValue: FieldRef;
    begin
    end;

    procedure RemoveAssignmentOnDelete(var ImportConfigLine: Record DMTImportConfigLine)
    begin
    end;

    var
        TempReplacementGlobal, TempReplacementRule, TempReplacementAssignment : Record DMTReplacement temporary;
}