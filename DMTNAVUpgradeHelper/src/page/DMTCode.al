page 50167 DMTCode
{
    Caption = 'Code', Locked = true;
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTableTemporary = true;
    SourceTable = Integer;
    SourceTableView = sorting(Number);
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(Settings)
            {
                field(SourceRecVarName; SourceRecVarName)
                {
                    Caption = 'Variable Name (Source Record)',
                    Comment = 'de-DE=Variablenname (Herkunftsdatensatz)';
                }
                field(TargetRecVarName; TargetRecVarName) { Caption = 'Variable Name (Target Record)'; }
            }
            repeater(GroupName)
            {
                field(Line; CodeLines.Get(Rec.Number))
                {
                    Caption = 'Code';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateCode)
            {
                Image = Create;

                trigger OnAction()
                begin
                    CodeLines := CreateImportConfigLineCodeBlock(CurrImportConfigHeader, SourceRecVarName, TargetRecVarName);
                    ResetLines();
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ResetLines();
    end;

    local procedure CreateImportConfigLineCodeBlock(ImportConfigHeader: Record DMTImportConfigHeader; _SourceRecVarName: Text; _TargetRecVarName: Text) CodeLines: List of [Text]
    var
        ImportConfigLine: Record DMTImportConfigLine;
        CodeGenerator: Codeunit DMTCodeGenerator;
        SourceFieldName, TargetFieldName : Text;
    begin
        if not ImportConfigHeader.FilterRelated(ImportConfigLine) then
            exit;
        ImportConfigLine.FindSet(false);
        repeat
            ImportConfigLine.CalcFields("Target Field Name");
            SourceFieldName := CodeGenerator.GetALFieldNameWithMasking(ImportConfigLine."Target Field Name");
            TargetFieldName := CodeGenerator.GetALFieldNameWithMasking(ImportConfigLine."Source Field Caption");
            case ImportConfigLine."Processing Action" of
                DMTFieldProcessingType::FixedValue:
                    begin
                        CodeLines.Add(StrSubstNo('%1.Validate(%2,''%3'');', _TargetRecVarName, TargetFieldName, ImportConfigLine."Fixed Value"));
                    end;
                DMTFieldProcessingType::Ignore:
                    begin
                        CodeLines.Add(StrSubstNo('//%1.Validate(%2,%3.%4);', _TargetRecVarName, TargetFieldName, _SourceRecVarName, SourceFieldName));
                    end;
                DMTFieldProcessingType::Transfer:
                    begin
                        CodeLines.Add(StrSubstNo('%1.Validate(%2,%3.%4);', _TargetRecVarName, TargetFieldName, _SourceRecVarName, SourceFieldName));
                    end;
            end;

        until ImportConfigLine.Next() = 0;
    end;


    local procedure ResetLines()
    var
        i: Integer;
    begin
        Rec.DeleteAll();
        for i := 1 to CodeLines.Count do begin
            Rec.Number := i;
            Rec.Insert();
        end;
    end;

    procedure InitForImportConfigLine(ImportConfigHeader: Record DMTImportConfigHeader)
    var
        TableMetadata: Record "Table Metadata";
    begin
        CurrImportConfigHeader := ImportConfigHeader;
        TableMetadata.Get(ImportConfigHeader."Target Table ID");
        SourceRecVarName := DelChr(TableMetadata.Name, '=', ' -') + 'Old';
        TargetRecVarName := DelChr(TableMetadata.Name, '=', ' -');
        CodeLines := CreateImportConfigLineCodeBlock(ImportConfigHeader, SourceRecVarName, TargetRecVarName);
        ResetLines();
    end;

    var
        CurrImportConfigHeader: Record DMTImportConfigHeader;
        CodeLines: List of [Text];
        SourceRecVarName, TargetRecVarName : Text;
}