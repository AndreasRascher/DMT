// TODO:
// Sichten
// - Quellfelder mit Filter (Bei In Zieltabelle übertragen, im Verarbeitungsplan)
// - Zielfelder mit Vorgabewert ()
// - Ausgew. Felder verarbeiten (Zielfelder)
// Mehrfachauswahl via Action
// - Quellfelder
// - Zielfelder
page 91029 DMTSelectedFields
{
    Caption = 'PageName';
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = DMTFieldSelectionBuffer;
    SourceTableTemporary = true;
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Source Field Caption"; Rec."Source Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Source Field Caption"));
                        if Rec."Field No." <> 0 then
                            CurrPage.Update(true);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Source Field Caption"));
                    end;
                }
                field("Target Field Caption"; Rec."Target Field Caption")
                {
                    LookupPageId = DMTFieldLookUpV2;
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        Rec.OnAfterLookUpField(Selected, Rec.FieldNo("Target Field Caption"));
                    end;

                    trigger OnValidate()
                    begin
                        Rec.OnValidateOnAfterLookUp(Rec, Rec.FieldNo("Target Field Caption"));
                    end;
                }

            }
        }
        area(Factboxes)
        {

        }
    }
    trigger OnOpenPage()
    var
        importConfigHeader: Record DMTImportConfigHeader;
    begin
        // prepare Sample
        importConfigHeader.FindFirst();
        Rec.FilterGroup(4);
        Rec.SetRange("Imp.Conf.Header ID", importConfigHeader."ID");
        Rec.FilterGroup(0);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Type := Rec.Type::Source;
    end;


}