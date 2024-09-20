codeunit 90000 DMTSource
{
    procedure Set(importConfigHeader: Record DMTImportConfigHeader; ProcessErrorsOnly: Boolean)
    begin
        if importConfigHeader.UseGenericBufferTable() then
            SourceTypeGlobal := SourceTypeGlobal::GenBuffer
        else
            SourceTypeGlobal := SourceTypeGlobal::Buffertable;
    end;

    procedure SetRecordLimit(RecordLimit: Integer)
    begin

    end;

    procedure EditView()
    begin

    end;

    procedure MoveNext() hasNext: Boolean
    begin

    end;

    var
        bufferRefGlobal: RecordRef;
        SourceTypeGlobal: Option RecordIDList,GenBuffer,Buffertable;
}