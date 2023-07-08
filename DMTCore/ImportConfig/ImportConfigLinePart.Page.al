page 91009 ImportConfigLinePart
{
    Caption = 'Lines', Comment = 'de-DE=Zeilen';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTImportConfigLine;

    layout
    {
        area(Content)
        {
            label(AssignDataLayout)
            {
                Caption = 'Assign a data layout to assign fields.',
                Comment = 'de-DE=Weisen Sie ein Datenlayout zu um eine Felderzuordnung einzurichten.';
                Visible = not HasDataLayoutAssigned;
            }
            repeater(LineRepeater)
            {
                Editable = HasDataLayoutAssigned;
                field("Target Table ID"; Rec."Target Table ID") { }
                field("Target Field No."; Rec."Target Field No.") { }
                field("Target Field Caption"; Rec."Target Field Caption") { }
            }
        }
    }

    actions
    {
    }

    procedure SetRepeaterProperties(ImportConfigHeader: Record DMTImportConfigHeader)
    begin
        HasDataLayoutAssigned := ImportConfigHeader."Data Layout Code" <> '';
    end;

    procedure DoUpdate(SaveRecord: Boolean)
    begin
        CurrPage.Update(SaveRecord);
    end;

    var
        HasDataLayoutAssigned: Boolean;
}