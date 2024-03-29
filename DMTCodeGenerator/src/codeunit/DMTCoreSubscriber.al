codeunit 90012 DMTCoreSubscriber
{
    [EventSubscriber(ObjectType::Table, Database::DMTImportConfigHeader, 'OnAfterValidateEvent', "Use Separate Buffer Table", false, false)]
    local procedure ImportConfigHeader_OnAfterValidateEvent_UseSeparateBufferTable(var Rec: Record DMTImportConfigHeader)
    var
        DMTSetup: Record DMTSetup;
    begin
        if rec.IsTemporary then
            exit;
        if not rec."Use Separate Buffer Table" then
            exit;
        Rec.SetNAVTableByFileName(Rec."Source File Name");
        DMTSetup.ProposeObjectIDs(Rec, false);
    end;

}