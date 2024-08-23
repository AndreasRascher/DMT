codeunit 50048 DMTCoreSubscriber
{
    [EventSubscriber(ObjectType::Table, Database::DMTImportConfigHeader, 'OnAfterValidateEvent', "Separate Buffer Table Objects", false, false)]
    local procedure ImportConfigHeader_OnAfterValidateEvent_UseSeparateBufferTable(var Rec: Record DMTImportConfigHeader)
    var
        DMTSetup: Record DMTSetup;
    begin
        if rec.IsTemporary then
            exit;
        if rec."Separate Buffer Table Objects" = rec."Separate Buffer Table Objects"::None then
            exit;
        if Rec."Separate Buffer Table Objects" = Rec."Separate Buffer Table Objects"::"buffer table and XMLPort (Best performance)" then
            Rec.SetNAVTableByFileName(Rec."Source File Name");
        DMTSetup.ProposeObjectIDs(Rec, false);
    end;

}