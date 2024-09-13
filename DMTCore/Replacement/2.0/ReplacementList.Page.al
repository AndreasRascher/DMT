page 50022 DMTReplacementList
{
    Caption = 'DMT Replacement List', Comment = 'de-DE=DMT Ersetzungen';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTReplacementHeader;
    CardPageId = DMTReplacementCard;
    DataCaptionFields = Code, Description;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("No. of Rules"; Rec."No. of Rules") { ApplicationArea = All; }
            }
        }
    }
}