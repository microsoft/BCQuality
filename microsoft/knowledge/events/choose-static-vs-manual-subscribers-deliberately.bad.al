// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50232 "Order Event Pub Bad Sample"
{
    procedure ReleaseOrder(OrderNo: Code[20])
    begin
        OnAfterReleaseOrder(OrderNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseOrder(OrderNo: Code[20])
    begin
    end;
}

// Anti-pattern 1: a static subscriber drives an always-on side effect that
// should be scoped. Every release now emails the customer, in every session
// and every automated test, with no way to switch it off.
codeunit 50233 "Always Email Sub Bad Sample"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Order Event Pub Bad Sample", 'OnAfterReleaseOrder', '', false, false)]
    local procedure SendEmailOnRelease(OrderNo: Code[20])
    begin
        // Send a confirmation email unconditionally on every release.
    end;
}

codeunit 50234 "Scoped Sub Bad Sample"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Order Event Pub Bad Sample", 'OnAfterReleaseOrder', '', false, false)]
    local procedure OverrideRelease(OrderNo: Code[20])
    begin
        // Scoped behaviour intended only for a specific flow.
    end;
}

// Anti-pattern 2: a manual subscriber is bound and never unbound. Because the
// instance is held on a SingleInstance global, the binding lives for the whole
// session, so later unrelated releases keep hitting the scoped subscriber.
codeunit 50235 "Leaky Binder Bad Sample"
{
    SingleInstance = true;

    var
        Scoped: Codeunit "Scoped Sub Bad Sample";

    procedure ActivateOverride()
    begin
        BindSubscription(Scoped);
        // Missing: a matching UnbindSubscription(Scoped) when the scope ends.
    end;
}
