// page 91012 DMTFieldLookup
// {
//     Caption = 'Fields', Comment = 'de-DE=Felder';
//     PageType = List;
//     UsageCategory = None;
//     SourceTable = DMTDataLayoutLine;
//     SourceTableTemporary = true;

//     layout
//     {
//         area(Content)
//         {
//             repeater(fields)
//             {
//                 field(Name; Rec.ColumnName) { ApplicationArea = All; }
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         LoadLines();
//     end;

//     procedure LoadLines()
//     var
//         TempDataLayoutLine: Record DMTDataLayoutLine temporary;
//         ImportConfigHeader: Record DMTImportConfigHeader;
//         ImportConfigLine: Record DMTImportConfigLine;
//         importConfigMgt: Codeunit DMTImportConfigMgt;
//         BuffTableCaptions: Dictionary of [Integer, Text];
//         importConfigID: Integer;
//         FieldLookUpMode: Option "Look Up Source","Look Up Target";
//         TargetFieldNames: Dictionary of [Integer, Text];
//     begin
//         if IsLoaded then exit;
//         Clear(BuffTableCaptions);
//         ReadImportConfigIDFromTableRelationFilter(importConfigID, FieldLookUpMode);
//         case true of
//             (importConfigID <> 0) and (FieldLookUpMode = FieldLookUpMode::"Look Up Source"):
//                 begin
//                     ImportConfigHeader.Get(importConfigID);
//                     ImportConfigHeader.BufferTableMgt().ReadBufferTableColumnCaptions(BuffTableCaptions);
//                     CopyColumnCaptionsToTempDataLayoutLine(TempDataLayoutLine, BuffTableCaptions);
//                     Rec.Copy(TempDataLayoutLine, true);
//                     IsLoaded := true;
//                 end;
//             (importConfigID <> 0) and (FieldLookUpMode = FieldLookUpMode::"Look Up Target"):
//                 begin
//                     ImportConfigHeader.Get(importConfigID);
//                     ImportConfigLine.SetRange("Imp.Conf.Header ID", importConfigID);
//                     TargetFieldNames := importConfigMgt.CreateTargetFieldNamesDict(ImportConfigLine, false);
//                     CopyColumnCaptionsToTempDataLayoutLine(TempDataLayoutLine, TargetFieldNames);
//                     Rec.Copy(TempDataLayoutLine, true);
//                     IsLoaded := true;
//                 end;
//             else
//                 Error('unhandled case');
//         end;
//     end;

//     local procedure CopyColumnCaptionsToTempDataLayoutLine(var tempDataLayoutLine: Record DMTDataLayoutLine temporary; fieldCaptions: Dictionary of [Integer, Text])
//     var
//         fieldNo: Integer;
//     begin
//         clear(tempDataLayoutLine);
//         if tempDataLayoutLine.IsTemporary then
//             tempDataLayoutLine.DeleteAll();
//         foreach FieldNo in fieldCaptions.Keys do begin
//             tempDataLayoutLine.Init();
//             tempDataLayoutLine."Column No." := FieldNo;
//             tempDataLayoutLine.ColumnName := CopyStr(fieldCaptions.Get(FieldNo), 1, MaxStrLen(tempDataLayoutLine.ColumnName));
//             tempDataLayoutLine.Insert();
//         end;
//     end;

//     local procedure ReadImportConfigIDFromTableRelationFilter(var ImportConfigID: Integer; var FieldLookUpMode: Option "Look Up Source","Look Up Target");
//     var
//         dataLayoutLine: Record DMTDataLayoutLine;
//     begin
//         dataLayoutLine.Copy(Rec);
//         if (dataLayoutLine.GetFilter("Import Config. ID Filter") <> '') then
//             ImportConfigID := dataLayoutLine.GetRangeMin("Import Config. ID Filter");
//         if (dataLayoutLine.GetFilter("Field Look Mode Filter") <> '') then
//             FieldLookUpMode := dataLayoutLine.GetRangeMin("Field Look Mode Filter");

//         if ImportConfigID <> 0 then
//             exit;

//         dataLayoutLine.FilterGroup(4);
//         if (dataLayoutLine.GetFilter("Import Config. ID Filter") <> '') then
//             ImportConfigID := dataLayoutLine.GetRangeMin("Import Config. ID Filter");
//         if (dataLayoutLine.GetFilter("Field Look Mode Filter") <> '') then
//             FieldLookUpMode := dataLayoutLine.GetRangeMin("Field Look Mode Filter");
//     end;

//     var
//         IsLoaded: Boolean;
// }