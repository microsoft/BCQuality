// Demonstration-only AL. The Isolated argument requires runtime 9.0 / BC20.
codeunit 50530 "Shipment Events"
{
    procedure NotifyShipment(ShipmentNo: Code[20])
    begin
        OnShipmentCreated(ShipmentNo);
        OnShipmentCreatedIsolated(ShipmentNo);
    end;

    // Preserve the shipped attribute contract.
    [IntegrationEvent(true, true, false)]
    local procedure OnShipmentCreated(ShipmentNo: Code[20])
    begin
    end;

    // Publish a new event for different isolation and sender semantics.
    [IntegrationEvent(false, false, true)]
    local procedure OnShipmentCreatedIsolated(ShipmentNo: Code[20])
    begin
    end;
}
