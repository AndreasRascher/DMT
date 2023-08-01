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
                    sourceFileStorage: Record DMTSourceFileStorage;
                    excelReader: Codeunit DMTExcelReader;
                    tempBlob: Codeunit "Temp Blob";
                    HeaderLine: List of [Text];
                    ColumnName: Text;
                begin
                    // select source
                    if Page.RunModal(0, sourceFileStorage) <> Action::LookupOK then
                        exit;
                    sourceFileStorage.TestField(Name);
                    sourceFileStorage.GetFileAsTempBlob(tempBlob);
                    BindSubscription(excelReader);
                    // read top 5 rows if undefined
                    if Rec.XLSHeadingRowNo = 0 then
                        excelReader.InitReadRows(sourceFileStorage, 1, 5)
                    else
                        excelReader.InitReadRows(sourceFileStorage, Rec.XLSHeadingRowNo, Rec.XLSHeadingRowNo);
                    ClearLastError();
                    excelReader.Run();
                    if GetLastErrorText() <> '' then
                        Error(GetLastErrorText());
                    HeaderLine := excelReader.GetHeadlineColumnValues();
                    if HeaderLine.Count = 0 then begin
                        Message('Keine Daten gefunden in Zeile %1', rec.XLSHeadingRowNo);
                    end;

                    if Rec.Name = '' then
                        Rec.Name := sourceFileStorage.Name;
                    if Rec.Name.EndsWith('.xlsx') and (Rec.SourceFileFormat = Rec.SourceFileFormat::" ") then
                        Rec.SourceFileFormat := Rec.SourceFileFormat::Excel;

                    CurrPage.Update(true);
                    // clear existing lines
                    dataLayoutLine.Reset();
                    dataLayoutLine.SetRange("Data Layout ID", Rec.ID);
                    dataLayoutLine.DeleteAll(true);
                    // add lines
                    foreach ColumnName in HeaderLine do begin
                        Clear(dataLayoutLine);
                        dataLayoutLine."Data Layout ID" := Rec.ID;
                        dataLayoutLine."Column No." := HeaderLine.IndexOf(ColumnName);
                        dataLayoutLine.ColumnName := CopyStr(ColumnName, 1, MaxStrLen(dataLayoutLine.ColumnName));
                        dataLayoutLine.Insert(true);
                    end;
                end;

            }
        }
        area(Promoted)
        {
            actionref(ImportHeadLineAsColumnNamesRef; ImportHeadLineAsColumnNames) { }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
    end;
}