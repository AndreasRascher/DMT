page 91012 DMTCustomValueSettings
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(NoSeriensSetup)
            {
                Caption = 'No. Series Setup', Comment = 'de-DE=Nummernserie-Einstellungen';
                field(NoSeriesType; NoSeriesTypeGlobal)
                {
                    Caption = 'No. Series Type', comment = 'de-DE=Nummernserien-Typ';
                    OptionCaption = 'Starting No.,BC No. Series', Comment = 'de-DE=Startnummer,BC Nummernserie';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
            group(BCNoSeries)
            {
                Visible = (NoSeriesTypeGlobal = NoSeriesTypeGlobal::"BC No. Series");
                field(BcNoSeriesCode; BcNoSeriesCodeGlobal)
                {
                    Caption = 'BC No. Series', Comment = 'de-DE=BC Nummernserie';
                    TableRelation = "No. Series";
                    ShowMandatory = true;
                }
            }
            group(StartingNoGrp)
            {
                Caption = 'Starting No.', Comment = 'de-DE=Startnummer';
                Visible = (NoSeriesTypeGlobal = NoSeriesTypeGlobal::"Starting No.");

                field(StartingNoFld; StartingNoGlobal)
                {
                    Caption = 'Starting No.', Comment = 'de-DE=Startnummer';
                    trigger OnValidate()
                    begin
                        CheckIfNoCanBeIncreased(StartingNoGlobal, '');
                    end;
                }
                field(LastUsedNoFld; LastUsedNoGlobal)
                {
                    Caption = 'Last Used No.', Comment = 'de-DE=Letzte verwendete Nr.';
                    trigger OnValidate()
                    begin
                        CheckIfNoCanBeIncreased('', LastUsedNoGlobal);
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
        BcNoSeriesCodeGlobal := GetSetting_BcNoSeriesCode(ImportConfigLine);
        if Evaluate(NoSeriesTypeGlobal, GetSetting_NoSeriesType(ImportConfigLine)) then;
    end;

    procedure saveCustomValueSettings(var ImportConfigLine: Record DMTImportConfigLine)
    begin
        case NoSeriesTypeGlobal of
            NoSeriesTypeGlobal::"Starting No.":
                begin
                    ClearSettings(ImportConfigLine);
                    SetSetting_NoSeriesType_StartingNo(ImportConfigLine);
                    SetSetting_StartingNo(ImportConfigLine, StartingNoGlobal);
                    SetSetting_LastUsedNo(ImportConfigLine, LastUsedNoGlobal);
                end;
            NoSeriesTypeGlobal::"BC No. Series":
                begin
                    ClearSettings(ImportConfigLine);
                    SetSetting_NoSeriesType_BCNoSeries(ImportConfigLine);
                    SetSetting_BcNoSeriesCode(ImportConfigLine, BcNoSeriesCodeGlobal);
                end;
            else
                Error('undefinded No Series Type');
        end;
    end;

    procedure GetSetting_StartingNo(var ImportConfigLine: Record DMTImportConfigLine) PropertyValue: Text
    begin
        if not IsNoSeriesTypeStartingNo(ImportConfigLine) then
            exit('');
        if not GetSetting(PropertyValue, 'StartingNo', ImportConfigLine) then
            exit('');
    end;

    procedure GetSetting_LastUsedNo(var ImportConfigLine: Record DMTImportConfigLine) PropertyValue: Text
    begin
        if not GetSetting(PropertyValue, 'LastUsedNo', ImportConfigLine) then
            exit('');
    end;

    procedure GetSetting_BcNoSeriesCode(var ImportConfigLine: Record DMTImportConfigLine) PropertyValueCode: Code[20]
    var
        PropertyValue: Text;
    begin
        if not GetSetting(PropertyValue, 'BcNoSeriesCode', ImportConfigLine) then
            exit('');
        PropertyValueCode := CopyStr(PropertyValue, 1, MaxStrLen(PropertyValueCode));
    end;

    local procedure GetSetting_NoSeriesType(var ImportConfigLine: Record DMTImportConfigLine) PropertyValue: Text
    begin
        if not GetSetting(PropertyValue, 'NoSeriesType', ImportConfigLine) then
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

    procedure SetSetting_BcNoSeriesCode(var ImportConfigLine: Record DMTImportConfigLine; BcNoSeriesCodeNew: Text);
    begin
        SetSetting('BcNoSeriesCode', BcNoSeriesCodeNew, ImportConfigLine);
    end;

    procedure SetSetting_NoSeriesType_StartingNo(var ImportConfigLine: Record DMTImportConfigLine);
    begin
        SetSetting('NoSeriesType', Format(NoSeriesTypeGlobal::"Starting No."), ImportConfigLine);
    end;

    procedure SetSetting_NoSeriesType_BCNoSeries(var ImportConfigLine: Record DMTImportConfigLine);
    begin
        SetSetting('NoSeriesType', Format(NoSeriesTypeGlobal::"BC No. Series"), ImportConfigLine);
    end;

    procedure SetSetting_NoSeriesType(var ImportConfigLine: Record DMTImportConfigLine; noSeriesTypeNew: Text);
    begin
        SetSetting('NoSeriesType', noSeriesTypeNew, ImportConfigLine);
    end;

    local procedure SetSetting(PropertyName: Text; PropertyValue: Text; var ImportConfigLine: Record DMTImportConfigLine);
    var
        JObj: JsonObject;
        IStr: InStream;
        OStr: OutStream;
        ImportConfigLine2: Record DMTImportConfigLine;
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
        if ImportConfigLine.IsTemporary then
            if ImportConfigLine2.Get(ImportConfigLine.RecordId) then begin
                ImportConfigLine.CalcFields("Custom Value Settings");
                ImportConfigLine2."Custom Value Settings" := ImportConfigLine."Custom Value Settings";
                ImportConfigLine2.Modify();
            end;
    end;

    procedure CheckIfNoCanBeIncreased(StartingNo: Text; LastUsedNo: Text)
    var
        IncreasedNoDummy: Text;
        invalidStartingNoErr: Label 'Invalid Starting No. %1', Comment = 'de-DE=Ungültige Startnummer %1';
        invalidLastUsedNoErr: Label 'Invalid Last Used No. %1', Comment = 'de-DE=Ungültige Letzte verwendete Nr. %1';
    begin
        if StartingNo <> '' then begin
            IncreasedNoDummy := IncStr(StartingNo);
            if increasedNoDummy = '' then
                Error(invalidStartingNoErr, StartingNo);
        end;
        if LastUsedNo <> '' then begin
            IncreasedNoDummy := IncStr(LastUsedNo);
            if increasedNoDummy = '' then
                Error(invalidLastUsedNoErr, LastUsedNo);
        end;
    end;

    internal procedure UpdateCustomValueDescription(var CurrentRec: Record DMTImportConfigLine)
    var
        noSeries: Record "No. Series";
        LastUsedNo, StartingNo : Text;
        lastUsedLbl: Label '[Last Used No:]', Comment = 'de-DE=[Letzte Nr. verwendet:]';
        startingNoLbl: Label '[Starting No:]', Comment = 'de-DE=[Startnummer:]';
        undefinedLbl: Label '[undefinded]', Comment = 'de-DE=[undefiniert]';
        bcNoSeriesLbl: Label '[BC No. Series:]', Comment = 'de-DE=[BC Nr.-Serie:]';
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
                    case true of
                        isNoSeriesTypeStartingNo(CurrentRec):
                            begin
                                StartingNo := GetSetting_StartingNo(CurrentRec);
                                LastUsedNo := GetSetting_LastUsedNo(CurrentRec);
                                if LastUsedNo <> '' then
                                    CurrentRec."Custom Value" := lastUsedLbl + LastUsedNo
                                else
                                    if StartingNo <> '' then
                                        CurrentRec."Custom Value" := startingNoLbl + StartingNo
                                    else
                                        CurrentRec."Custom Value" := undefinedLbl;

                            end;
                        IsNoSeriesTypeBCNoSeries(CurrentRec):
                            begin
                                CurrentRec."Custom Value" := undefinedLbl;

                                BcNoSeriesCodeGlobal := GetSetting_BcNoSeriesCode(CurrentRec);
                                if (BcNoSeriesCodeGlobal <> '') then
                                    if noSeries.Get(BcNoSeriesCodeGlobal) then
                                        CurrentRec."Custom Value" := bcNoSeriesLbl + ' ' + noSeries.Description;
                            end;
                    end;
                end;
        end;
    end;

    procedure IsNoSeriesTypeStartingNo(ImportConfigLine: Record DMTImportConfigLine) OK: Boolean
    begin
        OK := GetSetting_NoSeriesType(ImportConfigLine) = Format(NoSeriesTypeGlobal::"Starting No.");
    end;

    procedure IsNoSeriesTypeBCNoSeries(ImportConfigLine: Record DMTImportConfigLine) OK: Boolean
    begin
        OK := GetSetting_NoSeriesType(ImportConfigLine) = Format(NoSeriesTypeGlobal::"BC No. Series");
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

    internal procedure RunNoSeriesDialog(var Rec: Record DMTImportConfigLine)
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

    internal procedure finalizeNoSeries(noSeriesSettings: Dictionary of [RecordId, Dictionary of [Text, Text]])
    var
        importConfigLine: Record DMTImportConfigLine;
        NoSeries: Codeunit "No. Series";
        recID: RecordId;
        dummy: Text;
    begin
        if noSeriesSettings.Count = 0 then
            exit;
        foreach recID in noSeriesSettings.Keys do begin
            importConfigLine.Get(recID);
            case noSeriesSettings.Get(recID).Get('NoSeriesType') of
                format(NoSeriesTypeGlobal::"Starting No."):
                    if noSeriesSettings.Get(recID).get('DoIncrement_Yes_No') = 'Increment_Yes' then begin
                        noSeriesSettings.Get(recID).set('LastUsedNo', noSeriesSettings.Get(recID).get('NextNo'));
                        SetSetting_LastUsedNo(importConfigLine, noSeriesSettings.Get(recID).get('LastUsedNo'));
                    end;
                Format(NoSeriesTypeGlobal::"BC No. Series"):
                    begin
                        if noSeriesSettings.Get(recID).get('DoIncrement_Yes_No') = 'Increment_Yes' then
                            dummy := noSeries.GetNextNo(CopyStr(noSeriesSettings.Get(recID).Get('BCNoSeriesCode'), 1, 20), 0D, false);
                    end;
            end;
            // set to default for next record
            noSeriesSettings.Get(recID).set('DoIncrement_Yes_No', 'Increment_Yes');
        end;
    end;

    internal procedure AddToNoSeriesSetting(var noSeriesSettings: Dictionary of [RecordId, Dictionary of [Text, Text]]; var tempImportConfigLine: Record DMTImportConfigLine temporary)
    var
        noSeriesProperties: Dictionary of [Text, Text];
    begin
        noSeriesProperties.Add('NoSeriesType', GetSetting_NoSeriesType(tempImportConfigLine));
        noSeriesProperties.Add('BCNoSeriesCode', GetSetting_BcNoSeriesCode(tempImportConfigLine));
        noSeriesProperties.Add('StartingNo', GetSetting_StartingNo(tempImportConfigLine));
        noSeriesProperties.Add('LastUsedNo', GetSetting_LastUsedNo(tempImportConfigLine));
        noSeriesProperties.Add('DoIncrement_Yes_No', 'Increment_Yes');
        noSeriesSettings.Add(tempImportConfigLine.RecordId, noSeriesProperties);
    end;

    /// <summary>
    /// peek next no for no series
    /// </summary>
    /// <param name="importSettings"></param>
    internal procedure prepareNoSeriesNextNo(var importSettings: Codeunit DMTImportSettings)
    var
        noSeries: Codeunit "No. Series";
        recID: RecordId;
        noSeriesSettings: Dictionary of [RecordId, Dictionary of [Text, Text]];
        nextNo: Text;
    begin
        if importSettings.GetNoSeriesSettings().Count = 0 then
            exit;

        noSeriesSettings := importSettings.GetNoSeriesSettings();
        foreach recID in noSeriesSettings.Keys do begin
            /*
        noSeriesProperties.Add('NoSeriesType', GetSetting_NoSeriesType(tempImportConfigLine));
        noSeriesProperties.Add('BCNoSeriesCode', GetSetting_BcNoSeriesCode(tempImportConfigLine));
        noSeriesProperties.Add('StartingNo', GetSetting_StartingNo(tempImportConfigLine));
        noSeriesProperties.Add('DoIncrement_Yes_No', 'Increment_Yes');
            */
            case noSeriesSettings.Get(recID).Get('NoSeriesType') of
                Format(NoSeriesTypeGlobal::"Starting No."):
                    begin
                        if noSeriesSettings.Get(recID).Get('DoIncrement_Yes_No') = 'Increment_Yes' then
                            if noSeriesSettings.Get(recID).Get('LastUsedNo') <> '' then begin
                                nextNo := IncStr(noSeriesSettings.Get(recID).Get('LastUsedNo'))
                            end else begin
                                nextNo := noSeriesSettings.Get(recID).Get('StartingNo');
                            end;
                    end;
                Format(NoSeriesTypeGlobal::"BC No. Series"):
                    begin
                        if noSeriesSettings.Get(recID).Get('DoIncrement_Yes_No') = 'Increment_Yes' then
                            nextNo := noSeries.PeekNextNo(CopyStr(noSeriesSettings.Get(recID).Get('BCNoSeriesCode'), 1, 20), 0D);
                    end;
            end;
            noSeriesSettings.Get(recID).Set('NextNo', nextNo);
        end;
        importSettings.NoSeriesSettings(noSeriesSettings);
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
        NoSeriesTypeGlobal: Option "Starting No.","BC No. Series";
        BcNoSeriesCodeGlobal: Code[20];
}