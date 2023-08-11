page 91019 DMTReplacementAssigmentsPart
{
    Caption = 'Assignments', Comment = 'de-DE=Zuordnung';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTReplacement;
    SourceTableView = where("Line Type" = const(Assignment));
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(AssignmentPerReplacement)
            {
                field(Overview_ImportConfigHeaderName; Rec."Data File Name") { ApplicationArea = All; }
                field(Overview_ImportConfigHeaderID; Rec."Imp.Conf.Header ID") { ApplicationArea = All; }
                field(Overview_ReplacementCode; Rec.Code) { ApplicationArea = All; TableRelation = DMTReplacement.Code where("Line Type" = const(Replacement)); }
                // field(Overview_Comparefields; GetCompareFieldsList())
                // {
                //     Caption = 'Compare Fields', Comment = 'de-DE=Vergleichswerte';
                //     ApplicationArea = All;
                //     trigger OnDrillDown()
                //     begin
                //         OnDrillDownCompareFields();
                //     end;
                // }
                // field(Overview_NewValueFields; GetNewValueFieldsList())
                // {
                //     Caption = 'New Value Fields', Comment = 'de-DE=Neue Werte';
                //     ApplicationArea = All;
                //     trigger OnDrillDown()
                //     begin
                //         OnDrillDownNewValueFields();
                //     end;
                // }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddFieldMapping)
            {
                Caption = 'Add Field Mapping', Comment = 'de-DE=Feldmapping hinzufügen';
                Image = Add;
                ApplicationArea = All;
                trigger OnAction()
                var
                    tempImportConfigLine: Record DMTImportConfigLine temporary;
                    ReplacementAssignment: Record DMTReplacement;
                    importConfigHeader: Record DMTImportConfigHeader;
                    FieldMappings: Page DMTFieldMappings;
                begin
                    FieldMappings.LookupMode(true);
                    FieldMappings.LoadOnlyAssignedFields();
                    if FieldMappings.RunModal() = Action::LookupOK then begin
                        FieldMappings.GetSelection(tempImportConfigLine);
                    end;
                    if tempImportConfigLine.FindSet() then
                        repeat
                            if not Rec.contains(Rec.Code, tempImportConfigLine) then begin
                                ReplacementAssignment.Reset();
                                ReplacementAssignment.Code := Rec.Code;
                                ReplacementAssignment."Line Type" := ReplacementAssignment."Line Type"::Assignment;
                                ReplacementAssignment."Imp.Conf.Header ID" := tempImportConfigLine."Imp.Conf.Header ID";
                                ReplacementAssignment."Target Table ID" := tempImportConfigLine."Target Table ID";
                                ReplacementAssignment."Compare Value 1 Field No." := tempImportConfigLine."Target Field No.";
                                ReplacementAssignment."Line No." := Rec.GetNextLineNo(ReplacementAssignment.Code, ReplacementAssignment."Line Type"::Assignment);
                                importConfigHeader.Get(ReplacementAssignment."Imp.Conf.Header ID");
                                ReplacementAssignment."Data File Name" := importConfigHeader."Source File Name";
                                ReplacementAssignment.Insert();
                            end;
                        until tempImportConfigLine.Next() = 0;
                end;
            }
            action(LoadListOfUniqueValues)
            {
                Caption = 'Import column values', comment = 'de-DE=Spaltenwerte importieren';
                Image = Column;
                ApplicationArea = All;
                trigger OnAction()
                var
                    genBuffTable: Record DMTGenBuffTable;
                    importConfigHeader: Record DMTImportConfigHeader;
                    importConfigLine: Record DMTImportConfigLine;
                    replacementRule: Record DMTReplacement;
                    uniqueValues: List of [Text];
                    uniqueValue: Text;
                begin
                    importConfigHeader.Get(rec."Imp.Conf.Header ID");
                    importConfigLine.Get(importConfigHeader.ID, rec."Compare Value 1 Field No.");
                    uniqueValues := genBuffTable.GetUniqueColumnValues(importConfigLine);
                    foreach uniqueValue in uniqueValues do begin
                        replacementRule.init();
                        replacementRule.Code := Rec.Code;
                        replacementRule."Line Type" := replacementRule."Line Type"::Rule;
                        replacementRule."Line No." := Rec.getNextLineNo(replacementRule.Code, replacementRule."Line Type");
                        replacementRule."Comp.Value 1" := CopyStr(uniqueValue, 1, MaxStrLen(rec."Comp.Value 1"));
                        replacementRule.Insert();
                    end;
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.FilterGroup(4);
        if Rec."Imp.Conf.Header ID" = 0 then
            if Rec.GetFilter("Imp.Conf.Header ID") <> '' then
                Rec."Imp.Conf.Header ID" := Rec.GetRangeMin("Imp.Conf.Header ID");
        if Rec."Target Table ID" = 0 then
            if Rec.GetFilter("Target Table ID") <> '' then
                Rec."Target Table ID" := Rec.GetRangeMin("Target Table ID");
        Rec.FilterGroup(0);
    end;

    // internal procedure GetCompareFieldsList() returnText: Text
    // var
    //     ImportConfigLine: Record DMTImportConfigLine;
    //     ClickToEditLbl: Label '<Click to Edit>';
    // begin
    //     if Rec.Code = '' then exit('');
    //     ImportConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
    //     ImportConfigLine.SetFilter("Source Field No.", '%1|%2', Rec."Compare Value 1 Field No.", Rec."Compare Value 2 Field No.");
    //     ImportConfigLine.FilterGroup(2);
    //     ImportConfigLine.SetFilter("Source Field No.", '<>0');
    //     ImportConfigLine.FilterGroup(0);
    //     if not ImportConfigLine.FindSet(false) then
    //         exit(ClickToEditLbl);
    //     repeat
    //         returnText += ',' + ImportConfigLine."Source Field Caption";
    //     until ImportConfigLine.Next() = 0;
    //     returnText := returnText.TrimStart(',');
    //     if returnText = '' then
    //         returnText := ClickToEditLbl;
    // end;

    // local procedure GetNewValueFieldsList() returnText: Text
    // var
    //     ImportConfigLine: Record DMTImportConfigLine;
    //     ClickToEditLbl: Label '<Click to Edit>';
    // begin
    //     if Rec.Code = '' then exit('');
    //     ImportConfigLine.SetRange("Imp.Conf.Header ID", Rec."Imp.Conf.Header ID");
    //     ImportConfigLine.SetFilter("Target Field No.", '%1|%2', Rec."New Value 1 Field No.", Rec."New Value 2 Field No.");
    //     if not ImportConfigLine.FindSet(false) then
    //         exit(ClickToEditLbl);
    //     repeat
    //         ImportConfigLine.CalcFields("Target Field Caption");
    //         returnText += ',' + ImportConfigLine."Target Field Caption";
    //     until ImportConfigLine.Next() = 0;
    //     returnText := returnText.TrimStart(',');
    //     if returnText = '' then
    //         returnText := ClickToEditLbl;
    // end;

    // internal procedure EditCompareFieldsList()
    // var
    //     ImportConfigHeader: Record DMTImportConfigHeader;
    //     SelectMultipleFields: Page DMTSelectMultipleFields;
    //     SelectedFields: List of [Integer];
    //     i: Integer;
    //     RunModalAction: Action;
    // begin
    //     if not ImportConfigHeader.Get(Rec."Imp.Conf.Header ID") then exit;
    //     SelectMultipleFields.InitSelectSourceFields(ImportConfigHeader, StrSubstNo('%1|%2', Rec."Compare Value 1 Field No.", Rec."Compare Value 2 Field No."));
    //     // SelectMultipleFields.LookupMode(true);        
    //     Commit();
    //     RunModalAction := SelectMultipleFields.RunModal();
    //     if RunModalAction = Action::OK then begin
    //         SelectedFields := SelectMultipleFields.GetSelectedSourceFieldIDList();
    //         Clear(Rec."Compare Value 1 Field No.");
    //         Clear(Rec."Compare Value 2 Field No.");
    //         for i := 1 to SelectedFields.Count do begin
    //             case true of
    //                 (i = 1):
    //                     Rec."Compare Value 1 Field No." := SelectedFields.Get(i);
    //                 (i = 2):
    //                     Rec."Compare Value 2 Field No." := SelectedFields.Get(i);
    //             end;
    //         end;
    //         Rec.Modify();
    //     end;
    // end;

    // local procedure EditNewValueFieldsList()
    // var
    //     ImportConfigHeader: Record DMTImportConfigHeader;
    //     SelectMultipleFields: Page DMTSelectMultipleFields;
    //     SelectedFields: List of [Integer];
    //     i: Integer;
    //     RunModalAction: Action;
    // begin
    //     if not ImportConfigHeader.Get(Rec."Imp.Conf.Header ID") then exit;
    //     SelectMultipleFields.InitSelectTargetFields(ImportConfigHeader, StrSubstNo('%1|%2', Rec."New Value 1 Field No.", Rec."New Value 2 Field No."));
    //     SelectMultipleFields.Editable := true;
    //     RunModalAction := SelectMultipleFields.RunModal();
    //     if RunModalAction = Action::OK then begin
    //         SelectedFields := SelectMultipleFields.GetTargetFieldIDList();
    //         Clear(Rec."New Value 1 Field No.");
    //         Clear(Rec."New Value 2 Field No.");
    //         for i := 1 to SelectedFields.Count do begin
    //             case true of
    //                 (i = 1):
    //                     Rec."New Value 1 Field No." := SelectedFields.Get(i);
    //                 (i = 2):
    //                     Rec."New Value 2 Field No." := SelectedFields.Get(i);
    //             end;
    //         end;
    //         Rec.Modify();
    //     end;
    // end;

    /// <summary>
    /// After selecting the compary fields, propose the targetfields assigned in the field mapping
    /// </summary>
    // local procedure IfTargetFieldsEmptyPopulateWithCompareFields()
    // var
    //     replacementHeader: Record DMTReplacement;
    // begin
    //     Rec.TestField("Line Type", Rec."Line Type"::Assignment);

    //     replacementHeader.Get(Rec."Line Type"::Replacement, Rec.Code, 0);
    //     if replacementHeader."No. of Compare Values" = replacementHeader."No. of Values to modify" then begin
    //         case replacementHeader."No. of Compare Values" of
    //             replacementHeader."No. of Compare Values"::"1":
    //                 begin
    //                     if Rec."New Value 1 Field No." = 0 then
    //                         Rec."New Value 1 Field No." := FindTargetFieldByCompareField(Rec."Imp.Conf.Header ID", Rec."Compare Value 1 Field No.");
    //                 end;

    //             replacementHeader."No. of Compare Values"::"2":
    //                 begin
    //                     if Rec."New Value 1 Field No." = 0 then
    //                         Rec."New Value 1 Field No." := FindTargetFieldByCompareField(Rec."Imp.Conf.Header ID", Rec."Compare Value 1 Field No.");
    //                     if Rec."New Value 2 Field No." = 0 then
    //                         Rec."New Value 2 Field No." := FindTargetFieldByCompareField(Rec."Imp.Conf.Header ID", Rec."Compare Value 2 Field No.");
    //                 end;
    //         end;
    //     end;
    // end;

    /// <summary>
    /// Get TargetFieldNo by ImportConfigHeader and source field id
    /// </summary>
    /// <returns>Returns 0 if not found</returns>
    // local procedure FindTargetFieldByCompareField(DataFieldID: Integer; SourceFieldNo: Integer) TargetFieldNo: Integer
    // var
    //     ImportConfigLine: Record DMTImportConfigLine;
    // begin
    //     if SourceFieldNo = 0 then
    //         exit(0);
    //     ImportConfigLine.SetRange("Imp.Conf.Header ID", DataFieldID);
    //     ImportConfigLine.SetRange("Source Field No.", SourceFieldNo);
    //     if ImportConfigLine.FindFirst() then
    //         if ImportConfigLine.Next() = 0 then
    //             TargetFieldNo := ImportConfigLine."Target Field No."
    //         else
    //             exit(0);
    // end;

    // local procedure OnDrillDownCompareFields()
    // begin
    //     if (Rec.Code <> '') then
    //         CurrPage.SaveRecord();
    //     EditCompareFieldsList();
    //     IfTargetFieldsEmptyPopulateWithCompareFields();
    // end;

    // local procedure OnDrillDownNewValueFields()
    // begin
    //     if (Rec.Code <> '') then
    //         CurrPage.SaveRecord();
    //     EditNewValueFieldsList();
    // end;
}