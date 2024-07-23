
page 90016 ProcessTemplateDataReqsFB
{
    Caption = 'Data Requirements', Comment = 'de-DE=Erforderliche Daten';
    PageType = ListPart;
    SourceTable = DMTProcessTemplateSetup;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    SourceTableView = where(Type = filter("Req. Setup"));
    layout
    {
        area(Content)
        {
            repeater(RequirementList)
            {
                Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
                field("Target Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; Caption = 'Table', Comment = 'de-DE=Tabelle'; StyleExpr = lineStyle; }
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; StyleExpr = lineStyle; }
            }
        }
    }

    // internal procedure Set(var processTemplateSetup: Record DMTProcessTemplateSetup)
    trigger OnAfterGetRecord()
    var
        dataTypeMgt: Codeunit "Data Type Management";
        recordRef: RecordRef;
        fieldRef: FieldRef;
        recordFound: Boolean;
        fieldFound: Boolean;
        fieldHasValue: Boolean;
    begin
        recordRef.Open(Rec."Target Table ID");
        recordFound := recordRef.FindFirst();
        fieldFound := dataTypeMgt.FindFieldByName(recordRef, fieldRef, Rec."Field Name");
        fieldHasValue := format(fieldRef.Value) <> '';
        case true of
            (not recordFound) or (not fieldHasValue):
                lineStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            fieldHasValue:
                lineStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            else
                lineStyle := Format(Enum::DMTFieldStyle::None);
        end;

    end;

    var
        lineStyle: Text;
}