// Demonstration only. Shows the correct way to extend an integration event that already has subscribers.

codeunit 50110 "Sales Post Events"
{
    // Original event kept and marked obsolete so existing subscribers continue to compile.
    [Obsolete('Use OnAfterPostSalesOrderWithShipmentNo instead.', '26.0')]
    [IntegrationEvent(false, false)]
    procedure OnAfterPostSalesOrder(var SalesHeader: Record "Sales Header")
    begin
    end;

    // New overload carries the extra parameter - existing subscribers on the old event still compile.
    [IntegrationEvent(false, false)]
    procedure OnAfterPostSalesOrderWithShipmentNo(var SalesHeader: Record "Sales Header"; ShipmentNo: Code[20])
    begin
    end;

    procedure PostSalesOrder(var SalesHeader: Record "Sales Header"; ShipmentNo: Code[20])
    begin
        // ... posting logic ...
        OnAfterPostSalesOrder(SalesHeader);                            // kept for backward compat
        OnAfterPostSalesOrderWithShipmentNo(SalesHeader, ShipmentNo); // new callers migrate here
    end;
}

codeunit 50111 "Shipment Notifier Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Events", 'OnAfterPostSalesOrderWithShipmentNo', '', false, false)]
    local procedure HandleAfterPostSalesOrderWithShipmentNo(var SalesHeader: Record "Sales Header"; ShipmentNo: Code[20])
    begin
        // Subscriber uses the new event; ShipmentNo is available without breaking old subscribers.
        if ShipmentNo = '' then
            exit;
        // ... notify warehouse of shipment ...
    end;
}
