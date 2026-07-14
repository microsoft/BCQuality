// Demonstration-only AL. Version 1 used [IntegrationEvent(true, true, false)].
codeunit 50531 "Shipment Events Bad"
{
    procedure NotifyShipment(ShipmentNo: Code[20])
    begin
        OnShipmentCreated(ShipmentNo);
    end;

    // Version 2 mutates all three contract-significant arguments in place.
    [IntegrationEvent(false, false, true)]
    local procedure OnShipmentCreated(ShipmentNo: Code[20])
    begin
    end;
}
