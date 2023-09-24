interface IBufferTableMgt
{
    procedure setImportConfigHeader(var ImportConfigHeader: record DMTImportConfigHeader);
    procedure checkHeaderIsSet();
    procedure InitBufferRef(var BufferRef: RecordRef);
    procedure LoadImportConfigLines(var tempImportConfigLine: Record DMTImportConfigLine temporary) OK: Boolean
    procedure CheckBufferTableIsNotEmpty()
    procedure ReadBufferTableColumnCaptions(var BuffTableCaptions: Dictionary of [Integer, Text]) OK: Boolean
    procedure InitKeyFieldFilter(var BufferRef: RecordRef) FilterFields: Dictionary of [Integer/*FieldNo*/, Text/*TableCaption*/]
}






