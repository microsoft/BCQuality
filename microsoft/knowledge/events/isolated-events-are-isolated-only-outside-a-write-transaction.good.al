// Demonstration only. Shows the recommended pattern: the isolated event is raised from a context that has written nothing.

codeunit 50181 "Shipment Confirmation Good"
{
    procedure ConfirmShipment(var ShipmentHeader: Record "Shipment Header Demo")
    begin
        ShipmentHeader.TestField("Carrier Code");
        ShipmentHeader.Status := ShipmentHeader.Status::Confirmed;
        ShipmentHeader.Modify(true);
    end;

    // Called by the page action or job queue entry after ConfirmShipment has completed and its
    // transaction has ended. This procedure only reads, so each subscriber runs in its own
    // transaction and a failing subscriber cannot undo or block anything.
    procedure NotifyShipmentConfirmed(ShipmentNo: Code[20])
    var
        ShipmentHeader: Record "Shipment Header Demo";
    begin
        ShipmentHeader.Get(ShipmentNo);
        ShipmentHeader.TestField(Status, ShipmentHeader.Status::Confirmed);
        OnAfterShipmentConfirmed(ShipmentHeader);
    end;

    [IntegrationEvent(false, false, true)]
    local procedure OnAfterShipmentConfirmed(ShipmentHeader: Record "Shipment Header Demo")
    begin
    end;
}

table 50181 "Shipment Header Demo"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Carrier Code"; Code[10]) { }
        field(3; Status; Option)
        {
            OptionMembers = Open,Confirmed;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}
