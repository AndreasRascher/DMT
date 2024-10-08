query 50000 DMTLogQry
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DMTLogEntry)
        {
            column(SourceFileName; SourceFileName) { }
            column(QtyRecordID) { Method = Count; }
            column(SourceID; "Source ID") { }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}