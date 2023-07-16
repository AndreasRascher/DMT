page 91006 DMTLayoutLinePart
{
    Caption = 'Lines', Comment = 'de-DE=Zeilen';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = DMTDataLayoutLine;

    layout
    {
        area(Content)
        {
            repeater(DefaultGroup)
            {
                Visible = (RepeaterVisibilty = RepeaterVisibilty::Default);
                field(DefaultGroup_ColumnName; Rec.ColumnName) { }
                field(DefaultGroup_DataType; Rec.DataType) { }
            }
            repeater(NAV)
            {
                Visible = (RepeaterVisibilty = RepeaterVisibilty::"NAV CSV");
                field(NAV_ColumnNo; Rec."Column No.") { }
                field(NAV_ColumnName; Rec.ColumnName) { }
                field(NAV_NAVDataType; Rec.NAVDataType) { }
                field(NAV_NAVLen; Rec.NAVLen) { }
                field(NAV_FieldCaption; Rec.NAVFieldCaption) { }
            }
            repeater(CustomCSV)
            {
                Visible = (RepeaterVisibilty = RepeaterVisibilty::"Custom CSV");
                field(CustomCSV_ColumnNo; Rec."Column No.") { }
                field(CustomCSV_ColumnName; Rec.ColumnName) { }
                field(CustomCSV_DataType; Rec.DataType) { }
            }
            repeater(Excel)
            {
                Visible = (RepeaterVisibilty = RepeaterVisibilty::Excel);
                field(Excel_ColumnNo; Rec."Column No.") { }
                field(Excel_ColumnName; Rec.ColumnName) { }
                field(Excel_DataType; Rec.DataType) { }
            }
        }
    }

    actions
    {
    }

    procedure SetRepeaterVisibility(DataLayout: Record DMTDataLayout)
    begin
        RepeaterVisibilty := RepeaterVisibilty::Default;
        case DataLayout.SourceFileFormat of
            DMTSourceFileFormat::"Custom CSV":
                RepeaterVisibilty := RepeaterVisibilty::"Custom CSV";
            DMTSourceFileFormat::"NAV CSV Export":
                RepeaterVisibilty := RepeaterVisibilty::"NAV CSV";
            DMTSourceFileFormat::Excel:
                RepeaterVisibilty := RepeaterVisibilty::Excel;
        end;
    end;

    procedure DoUpdate(SaveRecord: Boolean)
    begin
        CurrPage.Update(SaveRecord);
    end;

    var
        RepeaterVisibilty: Option Default,"NAV CSV","Custom CSV",Excel;

}