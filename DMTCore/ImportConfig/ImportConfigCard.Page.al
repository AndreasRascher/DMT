page 91008 DMTImportConfigCard
{
    Caption = 'DMT Import Config Card', Comment = 'de-DE=Importkonfiguration Karte';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigHeader;
    DelayedInsert = true;
    DataCaptionExpression = Rec."Target Table Caption";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'de-DE=Allgemein';
                field(ID; Rec.ID) { Visible = false; }
                field("Target Table Caption"; Rec."Target Table Caption")
                {
                    ShowMandatory = true;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.TargetTableCaption_OnAfterLookup(Selected);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.TargetTableCaption_OnValidate();
                        SaveRecordIfMandatoryFieldsAreFilled();
                        CurrPage.TableInfoFactBox.Page.DoUpdate(Rec);
                        CurrPage.LogFactBox.Page.DoUpdate(Rec);
                    end;
                }
                field("Source File Name"; Rec."Source File Name")
                {
                    ShowMandatory = true;

                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.SourceFileName_OnAfterLookup(Selected);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.SourceFileName_OnValidate();
                        SaveRecordIfMandatoryFieldsAreFilled();
                    end;
                }
                field("Target Table ID"; Rec."Target Table ID") { Visible = false; }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { }
                field("Import Only New Records"; Rec."Import Only New Records") { }
                field("Skip Records with User Changes"; Rec."Skip Records with User Changes")
                {
                    ToolTip = 'Skip records which have been changed after the import.', Comment = 'de-DE=Datensätze überspringen, die vom Benutzer geändert wurden';
                    Visible = false; // TODO: Fertig entwickeln und dann sichtbar machen
                }
                field("Separate Buffer Table Objects"; Rec."Separate Buffer Table Objects") { }
                group(SeperateBufferObjects)
                {
                    Caption = 'Buffer Table Objects', Comment = 'de-DE=Puffertabellen Objekte';
                    Visible = Rec."Separate Buffer Table Objects" <> Rec."Separate Buffer Table Objects"::None;
                    field("Buffer Table ID"; Rec."Buffer Table ID")
                    {
                        StyleExpr = Rec.BufferTableIDStyle;
                        trigger OnValidate()
                        begin
                            Rec.UpdateIndicators();
                        end;
                    }
                    field("Import XMLPort ID"; Rec."Import XMLPort ID")
                    {
                        StyleExpr = Rec.ImportXMLPortIDStyle;
                        trigger OnValidate()
                        begin
                            Rec.UpdateIndicators();
                        end;
                    }
                }
            }
            part(LinePart; DMTImportConfigLinePart)
            {
                SubPageLink = "Imp.Conf.Header ID" = field(ID);
            }
        }
        area(FactBoxes)
        {
            part(TableInfoFactBox; DMTImportConfigFactBox)
            {
                ApplicationArea = All;
                Caption = 'Info', Comment = 'de-DE=Info';
            }
            part(LogFactBox; DMTImportConfigFactBox)
            {
                ApplicationArea = All;
                Caption = 'Log', Comment = 'de-DE=Protokoll';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportBufferDataFromFile)
            {
                Caption = 'Import to Buffer Table', Comment = 'de-DE=Import in Puffertabelle';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_ImportBufferDataFromFile(Rec);
                    CurrPage.TableInfoFactBox.Page.DoUpdate(Rec);
                    CurrPage.LogFactBox.Page.DoUpdate(Rec);
                end;
            }
            action(DeleteRecordsInTargetTable)
            {
                Caption = 'Delete Records In Target Table', Comment = 'de-DE=Datensätze in Zieltabelle löschen';
                ApplicationArea = All;
                Image = "Invoicing-Delete";
                Promoted = false;

                trigger OnAction()
                var
                    ChangeRecordWithPerm: Codeunit DMTChangeRecordWithPerm;
                begin
                    ChangeRecordWithPerm.DeleteRecordsInTargetTable(Rec);
                    // Rec.UpdateBufferRecordCount();
                    CurrPage.TableInfoFactBox.Page.Update(false);
                end;
            }

            action(CountLines)
            {
                Caption = 'Count Lines in Target', Comment = 'de-DE=Zeilen zählen (Zieltab.)';
                ApplicationArea = All;
                Image = CalcWorkCenterCalendar;
                trigger OnAction()
                var
                    FPBuilder: Codeunit DMTFPBuilder;
                    RecRef: RecordRef;
                    TargetTableView, TargetTableFilter : Text;
                    NoOfLinesInFilterLbl: Label 'Filter:%1 \ No. of Lines in Filter: %2', Comment = 'de-DE=Filter:%1 \ Anzahl Zeilen im Filter: %2';
                begin
                    RecRef.Open(Rec."Target Table ID");
                    if TargetTableView <> '' then
                        RecRef.SetView(TargetTableView);
                    if FPBuilder.RunModal(RecRef) then begin
                        TargetTableView := RecRef.GetView();
                        TargetTableFilter := RecRef.GetFilters;
                        Message(NoOfLinesInFilterLbl, TargetTableFilter, RecRef.Count);
                    end;
                end;
            }
            action(CountLinesInSource)
            {
                Caption = 'Count Lines in Buffer', Comment = 'de-DE=Zeilen zählen (Puffertab.)';
                ApplicationArea = All;
                Image = CalcWorkCenterCalendar;
                trigger OnAction()
                var
                    FPBuilder: Codeunit DMTFPBuilder;
                    RecRef: RecordRef;
                    NoOfLinesInFilterLbl: Label 'Filter:%1 \ No. of Lines in Filter: %2', Comment = 'de-DE=Filter:%1 \ Anzahl Zeilen im Filter: %2';
                    TargetTableFilter, TargetTableView : Text;
                begin
                    Rec.BufferTableMgt().InitBufferRef(RecRef);
                    if TargetTableView <> '' then
                        RecRef.SetView(TargetTableView);
                    if FPBuilder.RunModal(RecRef) then begin
                        TargetTableView := RecRef.GetView();
                        TargetTableFilter := RecRef.GetFilters;
                        Message(NoOfLinesInFilterLbl, TargetTableFilter, RecRef.Count);
                    end;
                end;
            }

            action(TransferToTargetTable)
            {
                Caption = 'Import to Target Table', Comment = 'de-DE=In Zieltabelle übertragen';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_TransferToTargetTable(Rec);
                end;
            }
            action(UpdateFields)
            {
                Caption = 'Update Fields', Comment = 'de-DE=Felder aktualisieren';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    DMTSetup.getDefaultImportConfigPageActionImplementation().ImportConfigCard_UpdateFields(Rec);
                end;
            }
            action(RetryBufferRecordsWithError)
            {
                Caption = 'Retry Records With Error', Comment = 'de-DE=Fehler erneut verarbeiten';
                ApplicationArea = All;
                Image = TransferOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    importConfigMgt: Codeunit DMTImportConfigMgt;
                begin
                    importConfigMgt.PageAction_RetryBufferRecordsWithError(Rec);
                end;
            }
            action(OpenLog)
            {
                Caption = 'Log', Comment = 'de-DE=Protokoll';
                ApplicationArea = All;
                Image = ErrorLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Log: Codeunit DMTLog;
                begin
                    Log.ShowLogEntriesFor(Rec);
                end;
            }
            action(CheckTransferedRecords)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Check Transfered Records', Comment = 'de-DE=Übertragene Datensätze Prüfen';

                trigger OnAction()
                var
                    Migrate: Codeunit DMTMigrate;
                    CollationProblems: Dictionary of [RecordId, RecordId];
                    RecordMapping: Dictionary of [RecordId, RecordId];
                    NotTransferedRecords: List of [RecordId];
                begin
                    // RecordMapping := DMTImport.CreateSourceToTargetRecIDMapping(Rec, NotTransferedRecords);
                    CollationProblems := Migrate.FindCollationProblems(RecordMapping);
                    Message('No. of Records not Transfered: %1\' +
                            'No. of Collation Problems: %2', NotTransferedRecords.Count, CollationProblems.Count);
                end;
            }
            action(CreateCode)
            {
                Caption = 'Create AL Mapping Code', Comment = 'de-DE=Mapping AL Code erstellen';
                ApplicationArea = All;
                Image = CodesList;
                // trigger OnAction()
                // var
                //     DMTCode: Page DMTCode;
                // begin
                //     DMTCode.InitForImportConfigLine(Rec);
                //     DMTCode.Run();
                // end;
            }
            action(ExportTargetTableToCSV)
            {
                Caption = 'Export target table to CSV', Comment = 'de-DE=Zieltabelle als CSV exportieren';
                ApplicationArea = All;
                Image = CodesList;
                trigger OnAction()
                var
                    csvWriter: XmlPort DMTCSVWriter;
                begin
                    csvWriter.ExportTargetTableAsCSV(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.LinePart.Page.DoUpdate(false);
        Rec.UpdateIndicators();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.TableInfoFactBox.Page.ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(Rec);
        CurrPage.TableInfoFactBox.Page.Update(false);
        CurrPage.LogFactBox.Page.ShowAsLogAndUpdateOnAfterGetCurrRecord(Rec);
        CurrPage.LogFactBox.Page.Update(false);
    end;

    local procedure SaveRecordIfMandatoryFieldsAreFilled()
    begin
        if Rec.ID = 0 then
            if (Rec."Source File ID" > 0) then
                if (Rec."Target Table ID" > 0) then
                    CurrPage.SaveRecord();

    end;

    var
        DMTSetup: Record DMTSetup;
}