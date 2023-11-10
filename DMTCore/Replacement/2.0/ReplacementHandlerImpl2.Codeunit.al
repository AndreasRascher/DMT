codeunit 91021 ReplacementHandlerImpl2 implements IReplacementHandler
{
    SingleInstance = true;
    procedure InitBatchProcess(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        replacementHeader: Record DMTReplacementHeader;
        replacementRule, replacementAssignments : Record DMTReplacementLine;
    begin
        //load assigned replacements
        replacementAssignments.SetRange("Line Type", replacementAssignments."Line Type"::Assignment);
        replacementAssignments.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        if replacementAssignments.CopyToTemp(TempAssignmentGlobal) = 0 then
            exit;
        TempAssignmentGlobal.FindSet();
        repeat
            // collect replacements
            if not tempReplacementHeaderGlobal.Get(TempAssignmentGlobal."Replacement Code") then begin
                replacementHeader.Get(TempAssignmentGlobal."Replacement Code");
                tempReplacementHeaderGlobal := replacementHeader;
                tempReplacementHeaderGlobal.Insert();
            end;
        until TempAssignmentGlobal.Next() = 0;

        // collect rules
        tempReplacementHeaderGlobal.Reset();
        if tempReplacementHeaderGlobal.FindSet() then
            repeat
                replacementRule.SetRange("Replacement Code", tempReplacementHeaderGlobal.Code);
                replacementRule.SetRange("Line Type", replacementRule."Line Type"::Rule);
                if replacementRule.FindSet() then
                    repeat
                        if not TempReplacementRule.get(replacementRule.RecordId) then begin
                            TempReplacementRule := replacementRule;
                            TempReplacementRule.Insert(false);
                        end;
                    until replacementRule.Next() = 0;
            until tempReplacementHeaderGlobal.Next() = 0;

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
        FromValue1, FromValue2 : Text;
    begin
        clear(ReplacementValuesGlobal);
        // foreach Assignment
        if not TempAssignmentGlobal.FindSet() then
            exit;
        repeat
            tempReplacementHeaderGlobal.Get(TempAssignmentGlobal."Replacement Code");

            // find matching rules
            TempReplacementRule.Reset();
            TempReplacementRule.SetRange("Replacement Code", TempAssignmentGlobal."Replacement Code");
            case true of
                tempReplacementHeaderGlobal.IsMapping(1, 1), tempReplacementHeaderGlobal.IsMapping(1, 2):
                    begin
                        checkAssignmentIsValid(TempAssignmentGlobal);
                        importConfigLine.get(TempAssignmentGlobal."Imp.Conf.Header ID", TempAssignmentGlobal."Target 1 Field No.");
                        FromValue1 := SourceRef.Field(importConfigLine."Source Field No.").Value;
                        TempReplacementRule.SetRange("Comp.Value 1", FromValue1);
                    end;
                tempReplacementHeaderGlobal.IsMapping(2, 1), tempReplacementHeaderGlobal.IsMapping(2, 2):
                    begin
                        checkAssignmentIsValid(TempAssignmentGlobal);
                        importConfigLine.get(TempAssignmentGlobal."Imp.Conf.Header ID", TempAssignmentGlobal."Target 1 Field No.");
                        FromValue1 := SourceRef.Field(importConfigLine."Source Field No.").Value;
                        TempReplacementRule.SetRange("Comp.Value 1", FromValue1);

                        importConfigLine.get(TempAssignmentGlobal."Imp.Conf.Header ID", TempAssignmentGlobal."Target 2 Field No.");
                        FromValue2 := SourceRef.Field(importConfigLine."Source Field No.").Value;
                        TempReplacementRule.SetRange("Comp.Value 2", FromValue2);
                    end;
            end;
            // Add replacement values from matching rules
            if TempReplacementRule.FindFirst() then begin
                ReplacementValuesGlobal.Add(TempAssignmentGlobal."Target 1 Field No.", TempReplacementRule."New Value 1");
                if (tempReplacementHeaderGlobal."No. of Values to modify" = tempReplacementHeaderGlobal."No. of Values to modify"::"2") then
                    ReplacementValuesGlobal.Add(TempAssignmentGlobal."Target 2 Field No.", TempReplacementRule."New Value 2");
            end;
        until TempAssignmentGlobal.Next() = 0;
    end;

    procedure HasReplacementsForTargetField(TargetFieldNo: Integer) HasReplacements: Boolean;
    begin
        HasReplacements := ReplacementValuesGlobal.ContainsKey(TargetFieldNo);
    end;

    procedure GetReplacementValue(TargetFieldNo: Integer) TargetFieldValue: FieldRef;
    var
        RefHelper: Codeunit DMTRefHelper;
        rRef: RecordRef;
    begin
        rRef.Open(ImportConfigHeaderGlobal."Target Table ID");
        TargetFieldValue := rRef.Field(TargetFieldNo);
        RefHelper.AssignFixedValueToFieldRef(TargetFieldValue, ReplacementValuesGlobal.Get(TargetFieldNo));
    end;

    procedure RemoveAssignmentOnDelete(var ImportConfigLine: Record DMTImportConfigLine)
    var
        replacementLine: Record DMTReplacementLine;
    begin
        replacementLine.SetRange("Imp.Conf.Header ID", ImportConfigLine."Imp.Conf.Header ID");
        replacementLine.SetRange("Line Type", replacementLine."Line Type"::Assignment);
        replacementLine.SetRange("Target 1 Field No.", ImportConfigLine."Target Field No.");
        if not replacementLine.IsEmpty then
            replacementLine.DeleteAll();

        replacementLine.Reset();
        replacementLine.SetRange("Imp.Conf.Header ID", ImportConfigLine."Imp.Conf.Header ID");
        replacementLine.SetRange("Line Type", replacementLine."Line Type"::Assignment);
        replacementLine.SetRange("Target 2 Field No.", ImportConfigLine."Target Field No.");
        if not replacementLine.IsEmpty then
            replacementLine.DeleteAll();
    end;

    local procedure checkAssignmentIsValid(TempAssignment: Record DMTReplacementLine temporary)
    var
        importConfigHeader: Record DMTImportConfigHeader;
        importConfigLine: Record DMTImportConfigLine;
        InvalidHeaderAssignmentErr: Label 'Invalid assignment in replacement "%1". An import configuration with the ID %2 does not exist.',
                            Comment = 'de-DE=Ungültige Zuordnung in Ersetzung "%1". Eine Importkonfiguration mit der ID %2 ist nicht verhanden.';
        InvalidFieldAssignmentErr: Label 'Invalid assignment in replacement "%1". An import configuration "%2" with the field ID "%3" does not exist.',
                            Comment = 'de-DE=Ungültige Zuordnung in Ersetzung "%1". Eine Importkonfiguration "%2" mit der Feld ID "%3" ist nicht verhanden.';
    begin
        if not importConfigHeader.Get(TempAssignment."Imp.Conf.Header ID") then
            Error(InvalidHeaderAssignmentErr, TempAssignment."Replacement Code", TempAssignment."Imp.Conf.Header ID");

        if not importConfigLine.get(TempAssignment."Imp.Conf.Header ID", TempAssignment."Target 1 Field No.") then
            Error(InvalidFieldAssignmentErr, TempAssignment."Replacement Code", TempAssignment."Imp.Conf.Header ID", TempAssignment."Target 1 Field No.");

        if true in [tempReplacementHeaderGlobal.IsMapping(2, 1), tempReplacementHeaderGlobal.IsMapping(2, 2)] then begin
            if not importConfigLine.get(TempAssignment."Imp.Conf.Header ID", TempAssignment."Target 2 Field No.") then
                Error(InvalidFieldAssignmentErr, TempAssignment."Replacement Code", TempAssignment."Imp.Conf.Header ID", TempAssignment."Target 2 Field No.");
        end;
    end;

    var
        TempAssignmentGlobal, TempReplacementRule : Record DMTReplacementLine temporary;
        tempReplacementHeaderGlobal: Record DMTReplacementHeader temporary;
        ImportConfigHeaderGlobal: Record DMTImportConfigHeader;
        ReplacementValuesGlobal: Dictionary of [Integer, Text];
}