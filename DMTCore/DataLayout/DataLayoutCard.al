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
                Caption = 'General', Comment = 'de-DE=Allgemein';
                field(ID; Rec.ID) { Visible = false; }
                field(Name; Rec.Name) { }
                field("Has Heading Row"; Rec."Has Heading Row") { }
                field(HeadingRowNo; Rec.HeadingRowNo) { }
                field(SourceFileFormat; Rec.SourceFileFormat)
                {
                    trigger OnValidate()
                    begin
                        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
                        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
                    end;
                }
                field(Default; Rec.Default) { }

            }
            // group(NAV)
            // {
            //     Visible = IsNAVExport;
            //     field(NAVTableID; Rec.NAVTableID) { }
            //     field(NAVTableCaption; Rec.NAVTableCaption) { }
            //     field(NAVNoOfRecords; Rec.NAVNoOfRecords) { }
            // }
            group(Excel)
            {
                Visible = Rec.SourceFileFormat = Rec.SourceFileFormat::Excel;
                field(XLSDefaultSheetName; Rec.XLSDefaultSheetName) { }
            }
            group(CustomCSV)
            {
                Visible = Rec.SourceFileFormat = Rec.SourceFileFormat::"Custom CSV";
                field(CSVFieldSeparator; Rec.CSVFieldSeparator) { }
                field(CSVFieldDelimiter; Rec.CSVFieldDelimiter)
                {
                    trigger OnAssistEdit()
                    var
                        Choice: Integer;
                        Choices: List of [Text];
                        ChoicesText: Text;
                    begin
                        ChoicesText := '<None>,<TAB>';
                        Choices := ChoicesText.Split(',');
                        Choice := StrMenu(ChoicesText);
                        if Choice <> 0 then
                            Rec.CSVFieldDelimiter += Choices.Get(Choice);
                    end;
                }
            }
            field(CSVLineSeparator; Rec.CSVLineSeparator)
            {
                trigger OnAssistEdit()
                var
                    Choice: Integer;
                    Choices: List of [Text];
                    ChoicesText: Text;
                begin
                    ChoicesText := '<None>,<CR/LF>,<CR>,<LF>,<TAB>';
                    Choices := ChoicesText.Split(',');
                    Choice := StrMenu(ChoicesText);
                    if Choice <> 0 then
                        Rec.CSVLineSeparator += Choices.Get(Choice);
                end;
            }
            field(CSVTextEncoding; Rec.CSVTextEncoding) { }

            part(DMTLayoutLinePart; DMTLayoutLinePart)
            {
                SubPageLink = "Data Layout ID" = field(ID);
                Enabled = not Rec."Has Heading Row";
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportHeadLineAsColumnNames)
            {
                Caption = 'Import column names', Comment = 'de-DE=Spaltenüberschriften importieren';
                ToolTip = 'Import column names from column headers', Comment = 'de-DE=Spaltennamen aus Spaltenüberschriften importieren';
                Image = ImportExcel;
                ApplicationArea = All;
                Visible = Rec."Has Heading Row";

                trigger OnAction()
                var
                    dataLayoutLine: Record DMTDataLayoutLine;
                    sourceFileStorage: Record DMTSourceFileStorage;
                    // tempBlob: Codeunit "Temp Blob";
                    ISourceFileImport: Interface ISourceFileImport;
                    FirstRowWithValues: Integer;
                    HeaderLine: List of [Text];
                    ColumnName: Text;
                begin
                    // select source
                    if Page.RunModal(0, sourceFileStorage) <> Action::LookupOK then
                        exit;
                    sourceFileStorage.TestField(Name);
                    // sourceFileStorage.GetFileAsTempBlob(tempBlob);

                    ISourceFileImport := Rec.SourceFileFormat;
                    ISourceFileImport.ReadHeadline(sourceFileStorage, rec, FirstRowWithValues, HeaderLine);
                    if HeaderLine.Count = 0 then begin
                        Message('Keine Daten gefunden in Zeile %1', rec.HeadingRowNo);
                    end;
                    // Set first row with values as headlines
                    if rec.HeadingRowNo = 0 then
                        rec.HeadingRowNo := FirstRowWithValues;

                    if Rec.Name = '' then
                        Rec.Name := sourceFileStorage.Name;

                    CurrPage.Update(true); // save rec
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
        IsNAVExport := setup.IsNAVExport();
        CurrPage.DMTLayoutLinePart.Page.SetRepeaterVisibility(Rec);
        CurrPage.DMTLayoutLinePart.Page.DoUpdate(false);
    end;

    var
        setup: Record DMTSetup;
        IsNAVExport: Boolean;
}