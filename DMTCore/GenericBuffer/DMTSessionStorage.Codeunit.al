codeunit 50000 DMTSessionStorage
{
    SingleInstance = true;
    procedure AddCaption(FieldNo: Integer; CaptionNew: Text)
    begin
        if Captions.ContainsKey(FieldNo) then
            Captions.Set(FieldNo, CaptionNew)
        else
            Captions.Add(FieldNo, CaptionNew);
    end;

    procedure GetCaption(FieldNo: Integer) Caption: Text
    begin
        if not Captions.Get(FieldNo, Caption) then
            exit;
    end;

    procedure HasCaption(FieldNo: Integer): Boolean
    begin
        exit(Captions.ContainsKey(FieldNo));
    end;

    procedure DisposeCaptions()
    begin
        Clear(Captions);
    end;

    procedure GetNoOfCaptions(): Integer
    begin
        exit(Captions.Keys.Count);
    end;

    procedure LastLineRead(LineNumber: Integer)
    begin
        LineNumberGlobal := LineNumber;
    end;

    procedure LastLineRead() LineNumber: Integer
    begin
        exit(LineNumberGlobal);
    end;

    internal procedure SetUnusedCaptions()
    var
        fieldNo: Integer;
    begin
        for fieldNo := 1000 to 1300 do begin
            if not HasCaption(fieldNo) then begin
                AddCaption(fieldNo, 'ΞunusedΞ');
            end;
        end;
    end;

    var
        Captions: Dictionary of [Integer, Text];
        LineNumberGlobal: Integer;
}