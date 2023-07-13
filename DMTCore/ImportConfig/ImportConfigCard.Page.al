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
                field(SourceFileID; Rec.SourceFileID) { ShowMandatory = true; }
                field("Data Layout Code"; Rec."Data Layout ID")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
                        CurrPage.LinePart.Page.DoUpdate(false);
                    end;
                }
                field("Target Table Caption"; Rec."Target Table Caption") { }
                field("Target Table ID"; Rec."Target Table ID") { ShowMandatory = true; }
                field("Use OnInsert Trigger"; Rec."Use OnInsert Trigger") { }
                field("Import Only New Records"; Rec."Import Only New Records") { }
            }
            group(TableInfo)
            {
                Caption = 'No. of Records in', Comment = 'de-DE=Anz. Datensätze in';
                field("No. of Records In Trgt. Table"; GetNoOfRecordsInTrgtTable())
                {
                    Caption = 'Target', Comment = 'de-DE=Ziel';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        Rec.ShowTableContent(Rec."Target Table ID");
                    end;
                }
                field("No.of Records in Buffer Table"; rec."No.of Records in Buffer Table")
                {
                    Caption = 'Buffer', Comment = 'de-DE=Puffer';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        genBuffTable: Record DMTGenBuffTable;
                    begin
                        if not genBuffTable.FilterBy(Rec) then
                            exit;
                        genBuffTable.ShowImportDataForFile(Rec);
                    end;
                }
            }
            part(LinePart; DMTImportConfigLinePart)
            {
                SubPageLink = "Imp.Conf.Header ID" = field(ID);
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportBufferDataFromFile)
            {
                Caption = 'Import to Buffer Table', Comment = 'Import in Puffertabelle';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    dataLayout: Record DMTDataLayout;
                    SourceFileImport: Interface ISourceFileImport;
                begin
                    dataLayout.Get(Rec."Data Layout ID");
                    SourceFileImport := dataLayout.SourceFileFormat;
                    SourceFileImport.ImportToBufferTable(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
        CurrPage.LinePart.Page.DoUpdate(false);
    end;

    internal procedure GetNoOfRecordsInTrgtTable(): Integer
    var
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
    begin
        if not TableMetadata.get(Rec."Target Table ID") then exit(0);
        RecRef.Open(Rec."Target Table ID");
        exit(RecRef.Count);
    end;

    // trigger OnAfterGetCurrRecord()
    // begin
    //     CurrPage.LinePart.Page.SetRepeaterProperties(Rec);
    //     CurrPage.LinePart.Page.DoUpdate(false);
    // end;
}