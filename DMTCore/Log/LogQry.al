query 91001 DMTLogQry
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DMTLogEntry)
        {
            column(ImportConfigHeaderName; SourceFileName) { }
            column(QtyRecordID) { Method = Count; }
            column(SourceID; "Source ID") { }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}