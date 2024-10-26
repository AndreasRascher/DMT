page 91012 DMTCustomValueSettings
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(StartingNoFld; StartingNoGlobal)
                {
                    Caption = 'Starting No.', Comment = 'de-DE=Startnummer';
                    trigger OnValidate()
                    begin
                        CheckIfNoCanBeIncreased(StartingNoGlobal);
                    end;
                }
                field(LastUsedNoFld; LastUsedNoGlobal)
                {
                    Caption = 'Last Used No.', Comment = 'de-DE=Letzte verwendete Nr.';
                    trigger OnValidate()
                    begin
                        CheckIfNoCanBeIncreased(LastUsedNoGlobal);
                    end;
                }
            }
        }
    }

    actions { }

    procedure setImportConfigLine(var ImportConfigLine: Record DMTImportConfigLine)
    begin
        StartingNoGlobal := GetSetting_StartingNo(ImportConfigLine);
        LastUsedNoGlobal := GetSetting_LastUsedNo(ImportConfigLine);
    end;

    procedure saveCustomValueSettings(var ImportConfigLine: Record DMTImportConfigLine)
    begin
        SetSetting_StartingNo(ImportConfigLine, StartingNoGlobal);
        SetSetting_LastUsedNo(ImportConfigLine, LastUsedNoGlobal);
    end;

    procedure GetSetting_StartingNo(var ImportConfigLine: Record DMTImportConfigLine) PropertyValue: Text
    begin
        if not GetSetting(PropertyValue, 'StartingNo', ImportConfigLine) then
            exit('');
    end;

    procedure GetSetting_LastUsedNo(var ImportConfigLine: Record DMTImportConfigLine) PropertyValue: Text
    begin
        if not GetSetting(PropertyValue, 'LastUsedNo', ImportConfigLine) then
            exit('');
    end;


    local procedure GetSetting(var PropertyValue: Text; PropertyName: Text; var ImportConfigLine: Record DMTImportConfigLine) OK: Boolean
    var
        JObj: JsonObject;
        JToken: JsonToken;
        IStr: InStream;
    begin
        ImportConfigLine.CalcFields("Custom Value Settings");
        ImportConfigLine."Custom Value Settings".CreateInStream(IStr);
        if not ImportConfigLine."Custom Value Settings".HasValue then
            exit(false);
        JObj.ReadFrom(IStr);
        if not JObj.Contains(PropertyName) then
            exit(false);
        OK := JObj.Get(PropertyName, JToken);
        PropertyValue := JToken.AsValue().AsText();
    end;

    procedure ClearSettings(var importConfigLine: Record DMTImportConfigLine)
    begin
        Clear(importConfigLine."Custom Value Settings");
        importConfigLine.Modify();
    end;

    procedure SetSetting_StartingNo(var ImportConfigLine: Record DMTImportConfigLine; StartingNo: Text);
    begin
        SetSetting('StartingNo', StartingNo, ImportConfigLine);
    end;

    procedure SetSetting_LastUsedNo(var ImportConfigLine: Record DMTImportConfigLine; LastUsedNo: Text);
    begin
        SetSetting('LastUsedNo', LastUsedNo, ImportConfigLine);
    end;

    local procedure SetSetting(PropertyName: Text; PropertyValue: Text; var ImportConfigLine: Record DMTImportConfigLine);
    var
        JObj: JsonObject;
        IStr: InStream;
        OStr: OutStream;
    begin
        ImportConfigLine.CalcFields("Custom Value Settings");
        ImportConfigLine."Custom Value Settings".CreateInStream(IStr);
        if ImportConfigLine."Custom Value Settings".HasValue then
            JObj.ReadFrom(IStr);
        if JObj.Contains(PropertyName) then
            JObj.Remove(PropertyName);
        JObj.Add(PropertyName, PropertyValue);
        ImportConfigLine."Custom Value Settings".CreateOutStream(OStr);
        JObj.WriteTo(OStr);
        ImportConfigLine.Modify();
    end;

    procedure CheckIfNoCanBeIncreased(NoToIncrease: Text)
    var
        IncreasedNoDummy: Text;
        invalidStartingNoErr: Label 'Invalid Starting No. %1', Comment = 'de-DE=Ungültige Startnummer %1';
    begin
        if NoToIncrease = '' then
            exit;
        IncreasedNoDummy := IncStr(NoToIncrease);
        if increasedNoDummy = '' then begin
            Error(invalidStartingNoErr, NoToIncrease);
        end;
    end;

    internal procedure UpdateCustomValueDescription(var CurrentRec: Record DMTImportConfigLine)
    var
        StartingNo, LastUsedNo : Text;
    begin
        case CurrentRec."Custom Value Type" of
            CurrentRec."Custom Value Type"::" ":
                begin
                    CurrentRec."Custom Value" := '';
                    ClearSettings(CurrentRec);
                end;
            CurrentRec."Custom Value Type"::"Fixed Value":
                begin
                    CheckIfValidValueForTargetField(CurrentRec);
                    ClearSettings(CurrentRec);
                end;
            CurrentRec."Custom Value Type"::"No.Series":
                begin
                    StartingNo := GetSetting_StartingNo(CurrentRec);
                    LastUsedNo := GetSetting_LastUsedNo(CurrentRec);
                    if LastUsedNo <> '' then
                        CurrentRec."Custom Value" := '[Last Used:]' + LastUsedNo
                    else
                        if StartingNo <> '' then
                            CurrentRec."Custom Value" := '[Starting No:]' + StartingNo
                        else
                            CurrentRec."Custom Value" := '[undefinded]';
                end;
        end;
    end;

    internal procedure ValidateCustomValue(var importConfigLine: Record DMTImportConfigLine)
    begin
        case importConfigLine."Custom Value Type" of
            importConfigLine."Custom Value Type"::"Fixed Value":
                begin
                    CheckIfValidValueForTargetField(importConfigLine);
                    ClearSettings(importConfigLine);
                end;
            importConfigLine."Custom Value Type"::"No.Series":
                begin
                end;
        end;
    end;

    internal procedure RunNoSeriesDialog(Rec: Record DMTImportConfigLine)
    var
        customValueSettings: Page DMTCustomValueSettings;
    begin
        if rec."Custom Value Type" <> Rec."Custom Value Type"::"No.Series" then
            exit;
        customValueSettings.setImportConfigLine(Rec);
        customValueSettings.LookupMode(true);
        if customValueSettings.RunModal() in [Action::LookupOK, Action::OK] then
            customValueSettings.saveCustomValueSettings(Rec);
        customValueSettings.UpdateCustomValueDescription(Rec);
    end;


    procedure CheckIfValidValueForTargetField(var importConfigLine: Record DMTImportConfigLine)
    var
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
        ErrorMsg: Text;
    begin
        importConfigLine.TestField("Target Table ID");
        importConfigLine.TestField("Target Field No.");
        if importConfigLine."Custom Value" <> '' then begin
            RecRef.Open(importConfigLine."Target Table ID");
            FldRef := RecRef.Field(importConfigLine."Target Field No.");
            ErrorMsg := ConfigValidateMgt.EvaluateValue(FldRef, importConfigLine."Custom Value", false);
            if ErrorMsg <> '' then begin
                Error(ErrorMsg);
            end else begin
                importConfigLine."Custom Value" := Format(FldRef.Value);
            end;
        end;
    end;

    var
        StartingNoGlobal, LastUsedNoGlobal : Text;
}