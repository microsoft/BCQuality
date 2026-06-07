// Anti-pattern: mutating a published signature, passing the whole record plus a secret, and
// firing without validation or failure classification. Every external subscriber breaks, and
// credentials and every table field leak into the payload.

codeunit 50173 "Order Events Bad"
{
    // This event already shipped as OnOrderConfirmed(OrderNo: Code[20]). Subscribers bound to
    // that signature. Editing it IN PLACE to add parameters silently breaks all of them: there
    // is no compiler across the boundary, so the notification just starts arriving in the wrong
    // shape and processing fails on the far side, far from this change.
    [ExternalBusinessEvent('OrderConfirmed', 'Order confirmed', 'Raised on confirm', EventCategory::Sales)]
    procedure OnOrderConfirmed(var SalesHeader: Record "Sales Header"; ApiKey: Text)
    // BAD: the full record exposes every field of Sales Header to every subscriber and couples
    // the contract to the table layout. ApiKey leaks a secret credential into the payload.
    begin
    end;
}

codeunit 50174 "Order Publisher Bad"
{
    procedure Publish(SalesHeader: Record "Sales Header")
    var
        Events: Codeunit "Order Events Bad";
    begin
        // BAD: no validation. A header with no document number is published and then, because
        // the data is permanently invalid, retried by the platform indefinitely. There is no
        // transient/permanent classification, so an unfixable payload is treated like a blip.
        Events.OnOrderConfirmed(SalesHeader, GetSecretApiKey());
    end;
}
