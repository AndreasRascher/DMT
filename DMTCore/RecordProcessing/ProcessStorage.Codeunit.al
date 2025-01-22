codeunit 91009 DMTProcessStorage
{
    EventSubscriberInstance = Manual;

    procedure Set(Storage: Variant)
    begin
        if IsBindingActive() then
            Unbind();
        Bind();
        SetPublisher(Storage);
    end;

    procedure Get(var Storage: Variant)
    begin
        ErrorIfBindingIsNotActive();
        GetPublisher(Storage);
    end;

    procedure Get() Storage: Variant;
    begin
        ErrorIfBindingIsNotActive();
        GetPublisher(Storage);
    end;

    local procedure Bind()
    begin
        BindSubscription(GlobalProcessStorage);
    end;

    procedure Unbind()
    begin
        UnbindSubscription(GlobalProcessStorage);
    end;

    local procedure ErrorIfBindingIsNotActive()
    begin
        if not IsBindingActive() then
            Error('Bindsubscribtion has to be used for the DMTProcessStorage Codeunit');
    end;

    local procedure IsBindingActive(): Boolean
    var
        EventSubscription: Record "Event Subscription";
    begin
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange(EventSubscription."Publisher Object ID", Codeunit::DMTProcessStorage);
        EventSubscription.FindFirst();
        exit(EventSubscription.Active);
    end;

    [BusinessEvent(false)]
    local procedure SetPublisher(var Storage: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::DMTProcessStorage, 'SetPublisher', '', false, false)]
    local procedure SetStorage(var Storage: Variant)
    begin
        GlobalStorageVariant := Storage;
    end;

    [BusinessEvent(false)]
    local procedure GetPublisher(var Storage: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::DMTProcessStorage, 'GetPublisher', '', false, false)]
    local procedure GetStorage(var Storage: Variant)
    begin
        Storage := GlobalStorageVariant;
    end;

    var
        GlobalProcessStorage: Codeunit DMTProcessStorage;
        GlobalStorageVariant: Variant;

}