// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50228 "Item Post Pub Good Sample"
{
    procedure PostItemLine(ItemNo: Code[20]; Qty: Decimal)
    begin
        // ... post the line ...
        OnAfterPostItemLine(ItemNo, Qty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostItemLine(ItemNo: Code[20]; Qty: Decimal)
    begin
    end;
}

codeunit 50229 "Item Post Audit Good Sample"
{
    // Always-on behaviour belongs in a static subscriber (the default).
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Post Pub Good Sample", 'OnAfterPostItemLine', '', false, false)]
    local procedure LogPostedLine(ItemNo: Code[20]; Qty: Decimal)
    begin
        // Audit every posted line, unconditionally.
    end;
}

codeunit 50230 "Item Post Stub Good Sample"
{
    // Scoped/temporary behaviour belongs in a manual subscriber.
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Post Pub Good Sample", 'OnAfterPostItemLine', '', false, false)]
    local procedure CaptureForTest(ItemNo: Code[20]; Qty: Decimal)
    begin
        // Record the call so a single test can assert on it.
    end;
}

codeunit 50231 "Item Post Test Good Sample"
{
    procedure VerifyPostingRaisesEvent()
    var
        Publisher: Codeunit "Item Post Pub Good Sample";
        Stub: Codeunit "Item Post Stub Good Sample";
    begin
        // Activate the scoped subscriber only for the duration of the test.
        BindSubscription(Stub);
        Publisher.PostItemLine('1000', 5);
        UnbindSubscription(Stub);
    end;
}
