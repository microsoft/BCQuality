// Best practice: one events codeunit per version, versioned procedure names, a minimal
// stable DTO of identifiers, validation before firing, and transient/permanent classification.

codeunit 50170 "Order Events v1"
{
    // Shipped contract. Once a subscriber binds to OnOrderConfirmed_v1, this signature is FROZEN.
    // Parameters are identifiers only: a subscriber calls back for detail, so no field leaks and
    // no secret travels in the payload.
    [ExternalBusinessEvent('OrderConfirmed', 'Order confirmed', 'Raised when a sales order is confirmed', EventCategory::Sales)]
    procedure OnOrderConfirmed_v1(OrderNo: Code[20]; ExternalRef: Text[100])
    begin
    end;
}

codeunit 50171 "Order Event Publisher"
{
    procedure Publish(SalesHeader: Record "Sales Header")
    var
        Events: Codeunit "Order Events v1";
    begin
        // Validate BEFORE firing. A header with no number cannot produce a meaningful
        // notification, so this is a PERMANENT failure: fail and alert, do not publish it and
        // let the platform retry an unfixable payload for 36 hours.
        if SalesHeader."No." = '' then
            Error('Cannot publish OrderConfirmed without a document number');

        // Transient conditions (subscriber temporarily down, network blip) are NOT handled here:
        // the platform's external-event delivery retries those for us. We only guard permanent ones.
        Events.OnOrderConfirmed_v1(SalesHeader."No.", SalesHeader."External Document No.");
    end;
}

// A breaking change does NOT edit OnOrderConfirmed_v1. It ships a NEW codeunit with a NEW
// procedure, so v1 subscribers keep receiving exactly what they bound to and new subscribers
// opt into the richer v2 shape.
codeunit 50172 "Order Events v2"
{
    [ExternalBusinessEvent('OrderConfirmedV2', 'Order confirmed (v2)', 'Adds the warehouse location code', EventCategory::Sales)]
    procedure OnOrderConfirmed_v2(OrderNo: Code[20]; ExternalRef: Text[100]; LocationCode: Code[10])
    begin
    end;
}
