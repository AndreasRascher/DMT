
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
                field("Requirement Type"; Rec."Requirement Sub Type") { ApplicationArea = All; }
                field("Name"; Rec."Name") { ApplicationArea = All; }
            }
        }
    }

    local procedure BuildNAVSourceTableFilter() sourceTableFilter: Text
    var
        Rec2: Record DMTProcessTemplateDetail;
    begin
        Rec2.Copy(Rec);
        if Rec2.IsEmpty then exit('');
        Rec2.SetFilter("NAV Source Table No.(Req.)", '<>0');
        if Rec2.FindSet() then
            repeat
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

    var
        NAVTableIDFilter: Text;
        NAVTableIDFilterVisible: Boolean;
}