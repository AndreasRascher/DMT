table 91014 DMTProcessingPlanBatch
{
    Caption = 'Processing Plan Batch', Comment = 'Verarbeitungsplan Buch.-Blattname';
    DataCaptionFields = Name, Description;
    LookupPageID = DMTProcessingPlanBatches;

    fields
    {
        field(1; Name; Code[20])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Name) { Clustered = true; }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        processingPlan: Record DMTProcessingPlan;
    begin
        processingPlan.SetRange("Journal Batch Name", Name);
        processingPlan.DeleteAll(true);
    end;

    // trigger OnRename()
    // var
    //     processingPlan: Record DMTProcessingPlan;
    // begin
    //     processingPlan.SetRange("Journal Batch Name", xRec.Name);
    //     while processingPlan.FindFirst() do
    //         processingPlan.Rename(Name, processingPlan."Line No.");
    // end;
}
