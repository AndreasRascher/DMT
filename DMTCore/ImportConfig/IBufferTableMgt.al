interface IBufferTableMgt
{
    procedure setImportConfigHeader(var ImportConfigHeader: record DMTImportConfigHeader);
    procedure checkHeaderIsSet();
    procedure InitBufferRef(var BufferRef: RecordRef);
    procedure LoadImportConfigLines(var tempImportConfigLine: Record DMTImportConfigLine temporary) OK: Boolean
    procedure CheckBufferTableIsNotEmpty()
    procedure ReadBufferTableColumnCaptions(var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    procedure CountRecordsInBufferTable() NoOfRecords: Integer
    procedure ShowBufferTable() OK: Boolean
    procedure DeleteAllBufferData()
}






