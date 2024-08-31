pageextension 90012 ProcessingPlan extends DMTProcessingPlan
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here    
        addlast(Processing)
        {
            action(GetNAVTableIDFilter)
            {
                Image = FilterLines;
                Caption = 'NAV Table ID Filter', Comment = 'de-DE=NAV-Tabellen-ID Filter';
                ToolTip = 'Creates a filter expression for NAV Table IDs based on selected lines', Comment = 'de-DE=Erstellt einen Filterausdruck für NAV-Tabellen-IDs basierend auf ausgewählten Zeilen';
                ApplicationArea = All;
                trigger OnAction()
                var
                    TempProcessingPlan_SelectedNew: Record DMTProcessingPlan temporary;
                    importConfigHeader: Record DMTImportConfigHeader;
                    FilterExpr: Text;
                begin
                    if not GetSelection(TempProcessingPlan_SelectedNew) then
                        exit;
                    if TempProcessingPlan_SelectedNew.FindSet() then
                        repeat
                            if TempProcessingPlan_SelectedNew.TypeSupportsProcessSelectedFieldsOnly() then
                                if importConfigHeader.Get(TempProcessingPlan_SelectedNew.ID) then
                                    importConfigHeader.Mark(true);
                        until TempProcessingPlan_SelectedNew.Next() = 0;
                    importConfigHeader.MarkedOnly(true);
                    FilterExpr := CreateTableIDFilter(importConfigHeader, importConfigHeader.FieldNo("NAV Src.Table No."));
                    Message(FilterExpr);
                end;
            }
            action(CopySelectedLinesToProcessTemplateSetup)
            {
                Image = Copy;
                Caption = 'Transfer to Process Template Setup', Comment = 'de-DE=In Prozessvorlage Einrichtung übernehmen';
                ToolTip = 'Copies selected lines to Process Template Setup', Comment = 'de-DE=Kopiert ausgewählte Zeilen in Prozessvorlage Einrichtung';
                ApplicationArea = All;
                trigger OnAction()
                var
                    TempProcessingPlan_SelectedNew: Record DMTProcessingPlan temporary;
                    processTemplateLib: Codeunit DMTProcessTemplateLib;
                begin
                    if not GetSelection(TempProcessingPlan_SelectedNew) then
                        exit;
                    processTemplateLib.CopySelectedLinesToProcessTemplateSetup(TempProcessingPlan_SelectedNew);

                end;
            }
        }
        addlast(LineActions)
        {
            actionref(GetNAVTableIDFilterRef; GetNAVTableIDFilter) { }
        }
    }

    procedure CreateTableIDFilter(var importConfigHeaderRec: Record DMTImportConfigHeader; FieldNo: Integer) FilterExpr: Text;
    var
        importConfigHeader: Record DMTImportConfigHeader;
        Integer: Record Integer;
        NoOfRecordsInFilter: Integer;
    begin
        importConfigHeader.Copy(importConfigHeaderRec);
        NoOfRecordsInFilter := importConfigHeaderRec.Count;
        if not importConfigHeader.FindSet(false) then
            exit('');
        repeat
            case FieldNo of
                importConfigHeader.FieldNo("Target Table ID"):
                    begin
                        if importConfigHeader."Target Table ID" <> 0 then
                            FilterExpr += StrSubstNo('%1|', importConfigHeader."Target Table ID");
                    end;
                importConfigHeader.FieldNo("NAV Src.Table No."):
                    begin
                        if importConfigHeader."NAV Src.Table No." <> 0 then
                            FilterExpr += StrSubstNo('%1|', importConfigHeader."NAV Src.Table No.");
                    end;
            end;
        until importConfigHeader.Next() = 0;
        FilterExpr := FilterExpr.TrimEnd('|');
        //Sort
        if FilterExpr <> '' then begin
            Integer.SetFilter(Number, FilterExpr);
            Clear(FilterExpr);
            if Integer.FindSet() then
                repeat
                    FilterExpr += StrSubstNo('%1|', Integer.Number);
                until Integer.Next() = 0;
            FilterExpr := FilterExpr.TrimEnd('|');
        end;
    end;
}