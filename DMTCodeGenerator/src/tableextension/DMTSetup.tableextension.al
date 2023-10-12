tableextension 90012 DMTSetup extends DMTSetup
{
    fields
    {
        field(90011; "Obj. ID Range Buffer Tables"; Text[250]) { Caption = 'Obj. ID Range Buffer Tables', Comment = 'de-DE=Objekt ID Bereich für Puffertabellen'; }
        field(90012; "Obj. ID Range XMLPorts"; Text[250]) { Caption = 'Obj. ID Range XMLPorts (Import)', Comment = 'de-DE=Objekt ID Bereich für XMLPorts (Import)'; }
        field(90013; "Import with FlowFields"; Boolean) { Caption = 'Create Buffer Tables with Flowfields', Comment = 'de-DE=Puffertabellen mit Flowfields generieren'; }
    }
}