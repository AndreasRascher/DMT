codeunit 91019 ReplacementHandlerImpl implements IReplacementHandler
{
    procedure InitBatchProcess(ImportConfigHeader: Record DMTImportConfigHeader);
    var
        replacementAssignments, replacementHeader : Record DMTReplacement;
    begin
        //load assigned replacements
        replacementAssignments.SetRange("Line Type", replacementAssignments."Line Type"::Assignment);
        replacementAssignments.SetRange("Imp.Conf.Header ID", ImportConfigHeader.ID);
        if replacementAssignments.FindSet() then
            repeat
                // collect replacement list              
                if not tempReplacementHeader.Get(tempReplacementHeader."Line Type"::Replacement, replacementAssignments.Code) then begin
                    replacementHeader.Get(tempReplacementHeader."Line Type"::Replacement, replacementAssignments.Code);
                    tempReplacementHeader := replacementHeader;
                    tempReplacementHeader.Insert();
                end;
            until replacementAssignments.Next() = 0;
        // collect rules
        // SetFieldIdssToWatch

        Workflow
- Regel anlegen(Code Beschreibung)
- Anzahl Felder definieren
- Regeln definieren
- Felder auswählen
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
        tempReplacementHeader, TempReplacementRule : Record DMTReplacement temporary;
}