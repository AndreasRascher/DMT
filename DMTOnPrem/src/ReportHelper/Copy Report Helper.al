page 90001 "Copy Report Helper"
{
    Caption = 'Copy Report Helper';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Report Metadata";
    SaveValues = true;
    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(RemoveALReportWhiteSpaceOption; removeALWhitespaceOption) { ApplicationArea = All; Caption = 'Remove al whitespace', Comment = 'Nicht benötigte Leerzeichen entfernen.'; }
                field(addSetDataGetDataCustomCodeOption; addSetDataGetDataCustomCodeOption) { ApplicationArea = All; Caption = 'Add SetData GetData CustomCode'; }
            }
            repeater(Repeater)
            {
                field(ReportIDCtrl; Rec.ID) { ApplicationArea = All; }
                field(ReportNameCtrl; Rec.Name) { ApplicationArea = All; }
                field(ReportCaptionCtrl; Rec.Caption) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadReport)
            {
                ApplicationArea = All;
                Image = Download;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReportMetadata_SELECTED: Record "Report Metadata";
                    FileContents: List of [Text];
                    FileNames: List of [Text];
                    FileNameBase: Text;
                    ReportALCode, ReportRDLCLayout : Text;
                begin
                    if not GetSelection(ReportMetadata_SELECTED) then exit;
                    ReportMetadata_SELECTED.FindSet();
                    repeat
                        FileNameBase := ConvertStr(ReportMetadata_SELECTED.Name, '<>*\/|"', '_______');
                        // Layout File
                        Clear(ReportRDLCLayout);
                        GetDatabaseReportRDLC(ReportRDLCLayout, ReportMetadata_SELECTED.ID);
                        if addSetDataGetDataCustomCodeOption then
                            AddCustomCode(ReportRDLCLayout);
                        FileNames.Add(FileNameBase + '.rdlc');
                        FileContents.Add(ReportRDLCLayout);
                        // AL Code File
                        Clear(ReportALCode);
                        ReadALCode(ReportALCode, ReportMetadata_SELECTED.ID);
                        if removeALWhitespaceOption then
                            RemoveALReportWhiteSpace(ReportALCode);
                        SetRDLCFilenameProperty(ReportALCode, FileNameBase + '.rdlc');
                        FileNames.Add(FileNameBase + '.al');
                        FileContents.Add(ReportALCode);
                    until ReportMetadata_SELECTED.Next() = 0;
                    DownloadReportFilesAsZip(FileNames, FileContents);
                end;
            }
        }
    }

    views
    {
        view(Sales)
        {
            Caption = 'Sales', Comment = 'Einkauf';
            Filters = where(FirstDataItemTableID = filter('36|110|112|114'), ProcessingOnly = const(false));
        }
        view(Purchase)
        {
            Caption = 'Purchase', Comment = 'Verkauf';
            Filters = where(FirstDataItemTableID = filter('38|120|122|124|6650'), ProcessingOnly = const(false));
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := true;
    end;

    procedure GetSelection(var ReportMetadata_SELECTED: Record "Report Metadata") HasLines: Boolean
    begin
        Clear(ReportMetadata_SELECTED);
        CurrPage.SetSelectionFilter(ReportMetadata_SELECTED);
        HasLines := ReportMetadata_SELECTED.FindFirst();
    end;

    local procedure ReadALCode(var ReportALCode: Text; ReportID: Integer)
    var
        AppObjectMetadata: Record "Application Object Metadata";
        BText: BigText;
        IStr: InStream;
        ALCodeNotAvailableErr: Label 'User AL Code is not available for the %1 %2. Enable with Powershell command:\\set-NAVServerConfiguration -ServerInstance BC -KeyName ProtectNAVAppSourceFiles -KeyValue false -ApplyTo All';
    begin
        Clear(ReportALCode);
        AppObjectMetadata.SetRange("Object Type", AppObjectMetadata."Object Type"::Report);
        AppObjectMetadata.SetRange("Object ID", ReportID);
        AppObjectMetadata.FindFirst();
        AppObjectMetadata.CalcFields("User AL Code");
        AppObjectMetadata."User AL Code".CreateInStream(IStr);
        BText.Read(IStr);
        if BText.Length = 0 then
            Error(ALCodeNotAvailableErr, AppObjectMetadata."Object Type", AppObjectMetadata."Object ID");
        ReportALCode := Format(BText);
    end;

    procedure CustomCodeLib_SetGetDataByName() CustomCode: Text
    var
        Content: TextBuilder;
    begin
        Content.AppendLine(''' Source: https://github.com/AndreasRascher/RDLCReport_CustomCode');
        Content.AppendLine(''' Hidden Tablecell Property Hidden=Code.SetGlobalData(Fields!GlobalData.Value)');
        Content.AppendLine(''' =================');
        Content.AppendLine(''' Global variables');
        Content.AppendLine(''' =================');
        Content.AppendLine('Shared GlobalDict As Microsoft.VisualBasic.Collection');
        Content.AppendLine(''' ==========================');
        Content.AppendLine(''' Get value by name or number');
        Content.AppendLine(''' ==========================');
        Content.AppendLine('');
        Content.AppendLine(''' Key = position number or name');
        Content.AppendLine('Public Function GetVal(Key as Object)');
        Content.AppendLine('  Return GetVal2(GlobalDict,Key)');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function GetVal2(ByRef Data as Object,Key as Object)');
        Content.AppendLine('  ''if Key As Number');
        Content.AppendLine('  If IsNumeric(Key) then');
        Content.AppendLine('    Dim i as Long');
        Content.AppendLine('    Integer.TryParse(Key,i)');
        Content.AppendLine('    if (i=0) then');
        Content.AppendLine('    return "Index starts at 1"');
        Content.AppendLine('    end if');
        Content.AppendLine('    if (Data.Count = 0) OR (i = 0) OR (i > Data.Count) then');
        Content.AppendLine('      Return "Invalid Index: ''"+CStr(i)+"''! Collection Count = "+ CStr(Data.Count)');
        Content.AppendLine('    end if  ');
        Content.AppendLine('    Return Data.Item(i)');
        Content.AppendLine('  end if');
        Content.AppendLine('');
        Content.AppendLine('  ''if Key As String');
        Content.AppendLine('  Key = CStr(Key).ToUpper() '' Key is Case Insensitive');
        Content.AppendLine('  Select Case True');
        Content.AppendLine('    Case IsNothing(Data)');
        Content.AppendLine('      Return "CollectionEmpty"');
        Content.AppendLine('    Case IsNothing(Key)');
        Content.AppendLine('      Return "KeyEmpty"');
        Content.AppendLine('    Case (not Data.Contains(Key))');
        Content.AppendLine('      Return "?"+CStr(Key)+"?"  '' Not found');
        Content.AppendLine('    Case Data.Contains(Key)');
        Content.AppendLine('      Return Data.Item(Key)');
        Content.AppendLine('    Case else');
        Content.AppendLine('      Return "Something else failed"');
        Content.AppendLine('  End Select ');
        Content.AppendLine('');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine(''' ===========================================');
        Content.AppendLine(''' Set global values from the body ');
        Content.AppendLine(''' ===========================================');
        Content.AppendLine('');
        Content.AppendLine('Public Function SetGlobalData(KeyValueList as Object)');
        Content.AppendLine('  SetDataAsKeyValueList(GlobalDict,KeyValueList)');
        Content.AppendLine('  Return True ''Set Control to Hidden=true');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function SetDataAsKeyValueList(ByRef SharedData as Object,NewData as Object)');
        Content.AppendLine('  Dim i as integer');
        Content.AppendLine('  Dim words As String() = Split(CStr(NewData),Chr(177))');
        Content.AppendLine('  Dim Key As String');
        Content.AppendLine('  Dim Value As String');
        Content.AppendLine('  For i = 1 To UBound(words)   ');
        Content.AppendLine('    if ((i mod 2) = 0) then');
        Content.AppendLine('      Key   = Cstr(Choose(i-1, Split(Cstr(NewData),Chr(177))))     ');
        Content.AppendLine('      Value = Cstr(Choose(i, Split(Cstr(NewData),Chr(177))))');
        Content.AppendLine('      AddKeyValue(SharedData,Key,Value)');
        Content.AppendLine('    end if');
        Content.AppendLine('    '' If last item in list only has a key');
        Content.AppendLine('    if (i = UBound(words)) and ((i mod 2) = 1) then');
        Content.AppendLine('      Key   = Cstr(Choose(i, Split(Cstr(NewData),Chr(177))))     ');
        Content.AppendLine('      Value = ""');
        Content.AppendLine('      AddKeyValue(SharedData,Key,Value)');
        Content.AppendLine('    end if');
        Content.AppendLine('  Next ');
        Content.AppendLine('End Function');
        Content.AppendLine('');
        Content.AppendLine('Public Function AddKeyValue(ByRef Data as Object, Key as Object,Value as Object)');
        Content.AppendLine('  if IsNothing(Data) then');
        Content.AppendLine('     Data = New Microsoft.VisualBasic.Collection');
        Content.AppendLine('  End if');
        Content.AppendLine('');
        Content.AppendLine('  Dim RealKey as String');
        Content.AppendLine('  if (CStr(Key) <> "") Then');
        Content.AppendLine('    RealKey = CStr(Key).ToUpper()');
        Content.AppendLine('  else');
        Content.AppendLine('    RealKey = CStr(Data.Count +1)');
        Content.AppendLine('  End if');
        Content.AppendLine('  '' Replace value if it already exists');
        Content.AppendLine('  if Data.Contains(RealKey) then');
        Content.AppendLine('     Data.Remove(RealKey)');
        Content.AppendLine('  End if');
        Content.AppendLine('');
        Content.AppendLine('  Data.Add(Value,RealKey)   ');
        Content.AppendLine('');
        Content.AppendLine('  Return Data.Count');
        Content.AppendLine('End Function');
        CustomCode := Content.ToText();
    end;


    procedure GetDatabaseReportRDLC(var ReportRDLCLayout: Text; ReportID: Integer) OK: Boolean
    var
        InStr: InStream;
        RDLXml: XmlDocument;
    begin
        if not Report.RdlcLayout(ReportID, InStr) then
            exit(false);
        OK := XmlDocument.ReadFrom(InStr, RDLXml);
        RDLXml.WriteTo(ReportRDLCLayout);
    end;

    procedure DownloadReportFilesAsZip(FileNames: List of [Text]; FileContents: List of [Text])
    var
        DataCompression: Codeunit "Data Compression";
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        Index: Integer;
        OStr: OutStream;
        FileContent, FileName : Text;
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        DataCompression.CreateZipArchive();
        for Index := 1 to FileNames.Count do begin
            FileName := FileNames.Get(Index);
            FileContent := FileContents.Get(Index);
            Clear(FileBlob);
            FileBlob.CreateOutStream(OStr);
            OStr.WriteText(FileContent);
            FileBlob.CreateInStream(IStr);
            DataCompression.AddEntry(IStr, FileName);
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr);
        FileName := 'ReportsWithLayout.zip';
        DownloadFromStream(IStr, 'Download', 'ToFolder', ZIPFileTypeTok, FileName);
    end;

    procedure SetRDLCFilenameProperty(var ReportALCode: Text; RDLCFileName: Text)
    var
        Index: Integer;
        Lines: List of [Text];
        CRLF: Text[2];
        ReportALCodeNew: TextBuilder;
    begin
        if not ReportALCode.Contains('RDLCLayout = ') then exit;
        CRLF[1] := 13;
        CRLF[2] := 10;
        Lines := ReportALCode.Split(CRLF);
        for Index := 1 to Lines.Count do begin
            if Lines.Get(Index).Trim().StartsWith('RDLCLayout =') then begin
                Lines.Set(Index, StrSubstNo('    RDLCLayout = ''%1'';', RDLCFileName));
            end;
            ReportALCodeNew.AppendLine(Lines.Get(Index));
        end;
        ReportALCode := ReportALCodeNew.ToText().TrimEnd();
    end;

    procedure RemoveALReportWhiteSpace(var ReportALCode: Text)
    var
        Index: Integer;
        PropertyLineCount: Integer;
        Lines: List of [Text];
        CRLF: Text[2];
        ReportALCodeNew: TextBuilder;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        Lines := ReportALCode.Split(CRLF);
        for Index := 1 to Lines.Count do begin

            Clear(PropertyLineCount);
            if (Index <= (Lines.Count - 2)) then
                if (Lines.Get(Index + 1).Trim() = '{') and (Lines.Get(Index + 2).Trim() = '}') then
                    PropertyLineCount := 2;

            if (Index <= (Lines.Count - 3)) then
                if (Lines.Get(Index + 1).Trim() = '{') and (Lines.Get(Index + 3).Trim() = '}') then
                    PropertyLineCount := 3;

            if (Index <= (Lines.Count - 4)) then
                if (Lines.Get(Index + 1).Trim() = '{') and (Lines.Get(Index + 4).Trim() = '}') then
                    PropertyLineCount := 4;

            case PropertyLineCount of
                // Compress empty brackets to one line
                2:
                    begin
                        ReportALCodeNew.AppendLine(Lines.Get(Index) + ' {}');
                        Index += 2;
                    end;
                // Compress brackets with one statement to one line
                3:
                    begin
                        ReportALCodeNew.AppendLine(StrSubstNo('%1 {%2}', Lines.Get(Index), Lines.Get(Index + 2)));
                        Index += 3;
                    end;
                // Compress brackets with two statements to two lines
                4:
                    begin
                        ReportALCodeNew.AppendLine(StrSubstNo('%1 {%2 %3}', Lines.Get(Index).TrimStart(), Lines.Get(Index + 2).TrimStart(), Lines.Get(Index + 3).TrimStart()));
                        Index += 4;
                    end;
                else
                    ReportALCodeNew.AppendLine(Lines.Get(Index));
            end;
        end;
        ReportALCode := ReportALCodeNew.ToText().TrimEnd();
    end;

    procedure AddCustomCode(var ReportRDLCLayout: Text);
    var
        CustomCodeFirstLineTok: Label 'Source: https://github.com/AndreasRascher/RDLCReport_CustomCode', Locked = true;
        NewCustomCode: Text;
        RDLXML: XmlDocument;
    begin
        if ReportRDLCLayout.Contains(CustomCodeFirstLineTok) then exit;
        XmlDocument.ReadFrom(ReportRDLCLayout, RDLXML);
        NewCustomCode := CustomCodeLib_SetGetDataByName();
        AppendCustomCode(RDLXML, NewCustomCode);
        RDLXML.WriteTo(ReportRDLCLayout);
    end;

    procedure AppendCustomCode(var RDLXml: XmlDocument; NewCustomCode: Text)
    var
        NewLine: Text[2];
        XmlNsMgr: XmlNamespaceManager;
        XCustomCode: XmlNode;
    begin
        AddNamespaces(XmlNsMgr, RDLXml); // adds default namespace with ns prefix
        if not RDLXml.SelectSingleNode('//ns:Report/ns:Code/text()', XmlNsMgr, XCustomCode) then
            exit;
        NewLine[1] := 13;
        NewLine[2] := 10;
        XCustomCode.AsXmlText().Value(XCustomCode.AsXmlText().Value + NewLine + NewCustomCode);
        if not RDLXml.SelectSingleNode('//ns:Report/ns:Code/text()', XmlNsMgr, XCustomCode) then
            exit;
    end;

    procedure AddNamespaces(var _XmlNsMgr: XmlNamespaceManager; _XMLDoc: XmlDocument)
    var
        _XmlAttribute: XmlAttribute;
        _XmlAttributeCollection: XmlAttributeCollection;
        _XMLElement: XmlElement;
    begin
        _XmlNsMgr.NameTable(_XMLDoc.NameTable());
        _XMLDoc.GetRoot(_XMLElement);
        _XmlAttributeCollection := _XMLElement.Attributes();
        if _XMLElement.NamespaceUri() <> '' then
            //_XmlNsMgr.AddNamespace('', _XMLElement.NamespaceUri());
            _XmlNsMgr.AddNamespace('ns', _XMLElement.NamespaceUri());
        foreach _XmlAttribute in _XmlAttributeCollection do
            if StrPos(_XmlAttribute.Name(), 'xmlns:') = 1 then
                _XmlNsMgr.AddNamespace(DelStr(_XmlAttribute.Name(), 1, 6), _XmlAttribute.Value());
    end;

    var
        [InDataSet]
        addSetDataGetDataCustomCodeOption, removeALWhitespaceOption : Boolean;
}