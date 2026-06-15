// Demonstration only. Shows the wrong way: adding a parameter directly to an existing integration event.

codeunit 50112 "Sales Post Events Bad"
{
    // BAD: ShipmentNo added directly to the existing event signature after subscribers already existed.
    [IntegrationEvent(false, false)]
    procedure OnAfterPostSalesOrder(var SalesHeader: Record "Sales Header"; ShipmentNo: Code[20])
    begin
    end;

    procedure PostSalesOrder(var SalesHeader: Record "Sales Header"; ShipmentNo: Code[20])
    begin
        // ... posting logic ...
        OnAfterPostSalesOrder(SalesHeader, ShipmentNo);
    end;
}

codeunit 50113 "Existing Subscriber Bad"
{
    // COMPILE ERROR (AL0306): subscriber signature no longer matches the publisher.
    // "The event subscriber method signature does not match the event publisher method signature."
    // ShipmentNo was not on the original event. Every extension that subscribed breaks immediately -
    // no deprecation period, no warning, no grace. The parameter change is a breaking change.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Events Bad", 'OnAfterPostSalesOrder', '', false, false)]
    local procedure HandleAfterPostSalesOrder(var SalesHeader: Record "Sales Header")
    begin
        // This procedure no longer compiles after ShipmentNo was added to the publisher.
    end;
}
