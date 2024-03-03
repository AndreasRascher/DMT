page 91019 DMTReplacementAssignmentPart
{
    Caption = 'Assignments', Comment = 'de-DE=Zuordnung';
    PageType = ListPart;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = DMTReplacementLine;
    SourceTableView = where("Line Type" = const(Assignment));
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater(Repeater_1_1)
            {
                Visible = not Source2Visible and not Target2Visible;
                field("Imp.Conf.Header ID"; Rec."Imp.Conf.Header ID")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field(SourceFileName_1_1; Rec."Source File Name") { }
                field(Source1FieldCaption_1_1; Rec."Source 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Source1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Target1FieldCaption_1_1; Rec."Target 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    Enabled = Target1Enabled;
                    ShowMandatory = true;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
            }
            repeater(Repeater_2_1)
            {
                Visible = Source2Visible and not Target2Visible;
                field(ImpConfHeaderID_2_1; Rec."Imp.Conf.Header ID")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field(Source1FieldCaption_2_1; Rec."Source 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Source1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Source2FieldCaption_2_1; Rec."Source 2 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Source2Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Target1FieldCaption_2_1; Rec."Target 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Target1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
            }
            repeater(Repeater_1_2)
            {
                Visible = not Source2Visible and Target2Visible;
                field(ImpConfHeaderID_1_2; Rec."Imp.Conf.Header ID")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field(Source1FieldCaption_1_2; Rec."Source 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Source1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Target1FieldCaption_1_2; Rec."Target 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Target1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Target2FieldCaption_1_2; Rec."Target 2 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Target2Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 2 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 2 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
            }
            repeater(Repeater_2_2)
            {
                Visible = Source2Visible and Target2Visible;
                field(ImpConfHeaderID_2_2; Rec."Imp.Conf.Header ID")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field(Source1FieldCaption_2_2; Rec."Source 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Source1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Source2FieldCaption_2_2; Rec."Source 2 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Source2Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source 2 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Source 2 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Target1FieldCaption_2_2; Rec."Target 1 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Target1Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 1 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
                field(Target2FieldCaption_2_2; Rec."Target 2 Field Caption")
                {
                    LookupPageId = DMTFieldLookup;
                    ShowMandatory = true;
                    Enabled = Target2Enabled;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target 2 Field Caption"), DataLayoutLineGlobal);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec.FieldNo("Target 2 Field Caption"), DataLayoutLineGlobal);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // ToDo
            action(SelectFieldMapping)
            {
                Caption = 'Select Field Mapping', Comment = 'de-DE=Feldmapping auswählen';
                Visible = SelectFieldMappingVisible;
                Image = Add;
                trigger OnAction()
                var
                    replacementHeader: Record DMTReplacementHeader;
                    replacementLine: Record DMTReplacementLine;
                    importConfigLine: Record DMTImportConfigLine;
                    importConfigLines: Page DMTImportConfigLines;
                begin
                    if not Rec.FindReplacementHeaderForPageRec(replacementHeader) then
                        Error('Replacement Header not found');
                    importConfigLines.Editable(false);
                    importConfigLines.LookupMode(true);
                    if replacementHeader."Rel.to Table ID (New Val.1)" <> 0 then
                        importConfigLine.SetRange("Target Table Relation", replacementHeader."Rel.to Table ID (New Val.1)");
                    if importConfigLines.RunModal() = Action::LookupOK then begin
                        if importConfigLines.GetSelection(TempImportConfigLine_Selected) then
                            repeat
                                replacementLine.init();
                                replacementLine.Validate("Imp.Conf.Header ID", TempImportConfigLine_Selected."Imp.Conf.Header ID");
                                replacementLine."Replacement Code" := replacementHeader.Code;
                                replacementLine."Line Type" := replacementLine."Line Type"::Assignment;
                                replacementLine."Line No." := replacementLine.GetNextLineNo(replacementHeader.Code, replacementLine."Line Type"::Assignment);
                                replacementLine."Source 1 Field No." := TempImportConfigLine_Selected."Source Field No.";
                                replacementLine."Source 1 Field Caption" := TempImportConfigLine_Selected."Source Field Caption";
                                replacementLine."Target 1 Field No." := TempImportConfigLine_Selected."Target Field No.";
                                TempImportConfigLine_Selected.CalcFields("Target Field Caption");
                                replacementLine."Target 1 Field Caption" := TempImportConfigLine_Selected."Target Field Caption";
                                replacementLine.Insert();
                            until TempImportConfigLine_Selected.Next() = 0;
                    end;
                end;
            }
            action(LoadListOfUniqueValues)
            {
                Caption = 'Import column values', comment = 'de-DE=Spaltenwerte importieren';
                Image = Column;
                trigger OnAction()
                var
                    replacementHeader: Record DMTReplacementHeader;
                    replacementLine: Record DMTReplacementLine;
                    genBuffTable: Record DMTGenBuffTable;
                    importConfigHeader: Record DMTImportConfigHeader;
                    importConfigLine: Record DMTImportConfigLine;
                    uniqueCombinationList: List of [List of [Text]];
                    uniqueCombination: List of [Text];
                    FieldIDs: List of [Integer];
                begin
                    if not Rec.FindReplacementHeaderForPageRec(replacementHeader) then
                        Error('Replacement Header not found');
                    rec.TestField("Imp.Conf.Header ID");
                    importConfigHeader.Get(rec."Imp.Conf.Header ID");
                    importConfigLine.Get(importConfigHeader.ID, rec."Target 1 Field No.");
                    FieldIDs.Add(rec."Source 1 Field No.");
                    if replacementHeader."No. of Source Values" = replacementHeader."No. of Source Values"::"2" then
                        FieldIDs.Add(rec."Source 2 Field No.");

                    importConfigHeader.BufferTableMgt().CheckBufferTableIsNotEmpty();
                    uniqueCombinationList := genBuffTable.GetUniqueColumnValues(rec."Imp.Conf.Header ID", FieldIDs);
                    if uniqueCombinationList.Count = 0 then
                        foreach uniqueCombination in uniqueCombinationList do begin
                            replacementLine.init();
                            replacementLine."Replacement Code" := replacementHeader.Code;
                            replacementLine."Line Type" := replacementLine."Line Type"::Rule;
                            replacementLine."Line No." := replacementLine.GetNextLineNo(replacementHeader.Code, replacementLine."Line Type"::Rule);
                            replacementLine."Comp.Value 1" := CopyStr(uniqueCombination.Get(1), 1, MaxStrLen(rec."Comp.Value 1"));
                            if FieldIDs.Count > 1 then
                                replacementLine."Comp.Value 2" := CopyStr(uniqueCombination.Get(2), 1, MaxStrLen(rec."Comp.Value 2"));
                            replacementLine.Insert();
                        end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        EnableControls();
    end;

    procedure EnableControls()
    begin
        Source1Enabled := Rec."Imp.Conf.Header ID" <> 0;
        Source2Enabled := Rec."Imp.Conf.Header ID" <> 0;
        Target1Enabled := Rec."Imp.Conf.Header ID" <> 0;
        Target2Enabled := Rec."Imp.Conf.Header ID" <> 0;
    end;

    procedure SetVisibility(replacementHeader: Record DMTReplacementHeader)
    begin
        Source2Visible := replacementHeader."No. of Source Values" = replacementHeader."No. of Source Values"::"2";
        Target2Visible := replacementHeader."No. of Values to modify" = replacementHeader."No. of Values to modify"::"2";
        SelectFieldMappingVisible := replacementHeader.IsMapping(1, 1);
        CurrPage.Update(Rec."Replacement Code" <> '');
    end;

    var
        TempImportConfigLine_Selected: Record DMTImportConfigLine temporary;
        DataLayoutLineGlobal: Record DMTDataLayoutLine;
        Source1Enabled, Source2Enabled, Target1Enabled, Target2Enabled : Boolean;
        Source2Visible, Target2Visible : Boolean;
        SelectFieldMappingVisible: Boolean;
        ImportConfigIsSet: Boolean;
}