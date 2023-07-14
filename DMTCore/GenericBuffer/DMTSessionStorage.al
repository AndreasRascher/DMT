codeunit 91000 DMTSessionStorage
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

    var
        Captions: Dictionary of [Integer, Text];
}