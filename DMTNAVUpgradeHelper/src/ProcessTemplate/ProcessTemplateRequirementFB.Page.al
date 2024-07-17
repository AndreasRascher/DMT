
page 90014 ProcessTemplateRequirementFB
{
    Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
    PageType = ListPart;
    SourceTable = DMTProcessTemplateDetail;
    SourceTableView = where(Type = const(Requirement));
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    ApplicationArea = All;
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            // group(NAVSourceTableFilterGroup)
            // {
            // Visible = NAVTableIDFilterVisible;
            // ShowCaption = false;
            field(NAVSourceTableFilter; NAVTableIDFilter) { Caption = 'NAV Table Filter', Comment = 'de-DE=NAV Tabellenfilter'; }
            // }
            repeater(RequirementList)
            {
                Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
                field("Requirement Type"; Rec."Requirement Sub Type") { ApplicationArea = All; StyleExpr = lineStyle; }
                field("Name"; Rec."Name") { ApplicationArea = All; StyleExpr = lineStyle; }
            }
        }
    }

    local procedure BuildNAVSourceTableFilter() sourceTableFilter: Text
    var
        Rec2: Record DMTProcessTemplateDetail;
        processTemplateLib: Codeunit DMTProcessTemplateLib;
    begin
        Rec2.Copy(Rec);
        if Rec2.IsEmpty then exit('');
        Rec2.SetFilter("NAV Source Table No.(Req.)", '<>0');
        if Rec2.FindSet() then
            repeat
                if not processTemplateLib.IsNAVSourceTableEmpty(Rec2."NAV Source Table No.(Req.)") then
                    sourceTableFilter += StrSubstNo('%1|', Rec2."NAV Source Table No.(Req.)");
            until Rec2.Next() = 0;
        sourceTableFilter := sourceTableFilter.TrimEnd('|');
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        found: Boolean;
    begin
        found := Rec.find(Which);
        NAVTableIDFilter := BuildNAVSourceTableFilter();
        NAVTableIDFilterVisible := NAVTableIDFilter <> '';
        exit(found);
    end;

    trigger OnAfterGetRecord()
    var
        processTemplateLib: Codeunit DMTProcessTemplateLib;
    begin
        case true of
            (rec."Requirement Sub Type" = rec."Requirement Sub Type"::SourceFile) and
            processTemplateLib.IsNAVSourceTableEmpty(rec."NAV Source Table No.(Req.)"):
                lineStyle := Format(Enum::DMTFieldStyle::Grey);
            (rec."Requirement Sub Type" = rec."Requirement Sub Type"::SourceFile) and
            processTemplateLib.IsSourceFileAvailable(Rec):
                lineStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            (rec."Requirement Sub Type" = rec."Requirement Sub Type"::SourceFile) and
            not processTemplateLib.IsSourceFileAvailable(Rec):
                lineStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            else
                lineStyle := Format(Enum::DMTFieldStyle::None);
        end;
    end;

    var
        lineStyle: Text;
        NAVTableIDFilter: Text;
        NAVTableIDFilterVisible: Boolean;
}