page 91011 DMTDataLayoutCard
{
    Caption = 'DMT Data Layout', Comment = 'de-DE=DMT Datenlayout';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTDataLayout;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-De=Allgemein';
                field(ID; Rec.ID) { Visible = false; }
                field(Name; Rec.Name) { }
                field(SourceFileFormat; Rec.SourceFileFormat)
                {
                    trigger OnValidate()
                    begin
                        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
                        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
                    end;
                }

                group(NAV)
                {
                    field(NAVTableID; Rec.NAVTableID) { }
                }
            }
            part(DMTLayoutLinePart; DMTLayoutLinePart)
            {
                SubPageLink = "Data Layout ID" = field(ID);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportHeadLineAsColumnNames)
            {
                Caption = 'Import column names from column headers', Comment = 'de-DE=Spaltennamen aus Spaltenüberschriften importieren';
                Image = ImportExcel;
                ApplicationArea = All;

                trigger OnAction()
                var
                    dataLayoutLine: Record DMTDataLayoutLine;
                    ExcelMgt: Codeunit DMTExcelMgt;
                    HeaderLine: Dictionary of [Text, Integer];
                    ColumnName: Text;
                begin
                    ExcelMgt.LoadFileWithDialog();
                    HeaderLine := ExcelMgt.GetHeaderLine();
                    if Rec.Name = '' then
                        Rec.Name := CopyStr(ExcelMgt.SelectedFileName(), 1, MaxStrLen(Rec.Name));

                    foreach columnName in HeaderLine.Keys do begin
                        Clear(dataLayoutLine);

                        dataLayoutLine."Data Layout ID" := Rec.ID;
                        dataLayoutLine."Column No." := HeaderLine.Get(ColumnName);
                        dataLayoutLine.ColumnName := CopyStr(ColumnName, 1, MaxStrLen(dataLayoutLine.ColumnName));

                        dataLayoutLine.Insert(true);
                    end;
                end;

            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
    end;
}