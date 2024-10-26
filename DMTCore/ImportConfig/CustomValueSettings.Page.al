page 91012 DMTCustomValueSettings
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(StartingNo; StartingNo) { Caption = 'Starting No.', Comment = 'de-DE=Startnummer'; }
                field(LastUsedNo; LastUsedNo) { Caption = 'Last Used No.', Comment = 'de-DE=Letzte verwendete Nr.'; }
            }
        }
    }

    actions { }

    procedure setImportConfigLine(var ImportConfigLine: Record DMTImportConfigLine)
    begin
        StartingNo := ImportConfigLine.CustomValueSettings_Get('StartingNo');
        LastUsedNo := ImportConfigLine.CustomValueSettings_Get('LastUsedNo');
    end;

    procedure saveCustomValueSettings(var ImportConfigLine: Record DMTImportConfigLine)
    begin
        ImportConfigLine.CustomValueSettings_Set('StartingNo', StartingNo);
        ImportConfigLine.CustomValueSettings_Set('LastUsedNo', LastUsedNo);
    end;

    var
        StartingNo, LastUsedNo : Text;
}