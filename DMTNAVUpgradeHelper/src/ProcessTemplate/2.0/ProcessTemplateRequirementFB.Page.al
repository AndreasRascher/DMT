
page 90014 ProcessTemplateRequirementFB
{
    Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
    PageType = ListPart;
    SourceTable = DMTProcessTemplateDetail;
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
            field(NAVSourceTableFilter; NAVTableIDFilter) { Caption = 'NAV Table Filter', Comment = 'de-DE=NAV Tabellenfilter'; }

            repeater(RequirementList)
            {
                Caption = 'Requirements', Comment = 'de-DE=Vorraussetzungen';
                field("Requirement Type"; Rec.Type) { ApplicationArea = All; StyleExpr = lineStyle; }
                field("Name"; Rec."Name") { ApplicationArea = All; StyleExpr = lineStyle; }
            }
        }
    }

    local procedure BuildNAVSourceTableFilter() sourceTableFilter: Text
    var
        Rec2: Record DMTProcessTemplateDetail;
        processTemplateLib: Codeunit DMTProcessTemplateLib;
        debug: Integer;
    begin
        debug := Rec.Count;
        Rec2.Copy(Rec, true);
        debug := Rec2.Count;
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
        // Table Filter for copy & paste
        NAVTableIDFilter := BuildNAVSourceTableFilter();
        NAVTableIDFilterVisible := NAVTableIDFilter <> '';
        exit(found);
    end;

    trigger OnAfterGetRecord()
    var
        processTemplateLib: Codeunit DMTProcessTemplateLib;
    begin
        case true of
            (rec.Type = rec.Type::SourceFile) and
            processTemplateLib.IsNAVSourceTableEmpty(rec."NAV Source Table No.(Req.)"):
                lineStyle := Format(Enum::DMTFieldStyle::Grey);
            (rec.Type = rec.Type::SourceFile) and
            processTemplateLib.IsSourceFileAvailable(Rec.Name):
                lineStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            (rec.Type = rec.Type::SourceFile) and
            not processTemplateLib.IsSourceFileAvailable(Rec.Name):
                lineStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            else
                lineStyle := Format(Enum::DMTFieldStyle::None);
        end;
    end;

    internal procedure Set(var processTemplateSetup: Record DMTProcessTemplateSetup)
    var
        sourceFileNames: Dictionary of [Text/*Filename*/, Integer/*NAVTableNo*/];
        codeunits, targetTables : List of [Integer];
        Codeunit: Integer;
        sourceFileName: Text;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        sourceFileNames := processTemplateSetup.getTemplateSourceFileNames();
        foreach sourceFileName in sourceFileNames.Keys do begin
            Rec.InsertNew(processTemplateSetup.getInitializedTemplateCode());
            Rec.Type := Rec.Type::SourceFile;
            Rec."Name" := CopyStr(sourceFileName, 1, MaxStrLen(Rec."Name"));
            Rec."NAV Source Table No.(Req.)" := sourceFileNames.Get(sourceFileName);
            Rec.Modify();
        end;

        codeunits := processTemplateSetup.getTemplateCodeunits();
        foreach Codeunit in codeunits do begin
            Rec.InsertNew(processTemplateSetup.getInitializedTemplateCode());
            Rec.Type := Rec.Type::Codeunit;
            Rec.Name := StrSubstNo('Codeunit %1', Codeunit);
            Rec.Modify();
        end;

        targetTables := processTemplateSetup.getTargetTables();
        foreach Codeunit in targetTables do begin
            Rec.InsertNew(processTemplateSetup.getInitializedTemplateCode());
            Rec.Type := Rec.Type::Table;
            Rec.Name := StrSubstNo('Table %1', Codeunit);
            Rec.Modify();
        end;

        CurrPage.Update(false);
    end;

    var
        lineStyle: Text;
        NAVTableIDFilter: Text;
        NAVTableIDFilterVisible: Boolean;
}