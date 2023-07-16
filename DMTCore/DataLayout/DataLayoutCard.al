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

            }
            group(NAV)
            {
                Visible = Rec.SourceFileFormat = Rec.SourceFileFormat::"NAV CSV Export";
                field(NAVTableID; Rec.NAVTableID) { }
                field(NAVTableCaption; Rec.NAVTableCaption) { }
                field(NAVNoOfRecords; Rec.NAVNoOfRecords) { }
            }
            group(Excel)
            {
                Visible = Rec.SourceFileFormat = Rec.SourceFileFormat::Excel;
                field(XLSHeadingRowNo; Rec.XLSHeadingRowNo) { }
                field(XLSDefaultSheetName; Rec.XLSDefaultSheetName)
                {
                    trigger OnDrillDown()
                    begin
                        Rec.LookupDefaultExcelSheetName()
                    end;
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
                    ExcelMgt.InitFileStreamFromUpload();
                    ExcelMgt.ReadSheet(Rec.XLSDefaultSheetName);
                    HeaderLine := ExcelMgt.ReadHeaderLine(Rec.XLSHeadingRowNo);
                    if Rec.Name = '' then
                        Rec.Name := CopyStr(ExcelMgt.SelectedFileName(), 1, MaxStrLen(Rec.Name));

                    foreach ColumnName in HeaderLine.Keys do begin
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