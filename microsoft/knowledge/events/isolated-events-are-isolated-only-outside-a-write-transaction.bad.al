// Demonstration only. Shows the wrong pattern: an isolated event raised inside an open write transaction.

codeunit 50180 "Shipment Confirmation Bad"
{
    procedure ConfirmShipment(var ShipmentHeader: Record "Shipment Header Demo")
    begin
        ShipmentHeader.TestField("Carrier Code");
        ShipmentHeader.Status := ShipmentHeader.Status::Confirmed;
        ShipmentHeader.Modify(true);

        // BAD: the Modify above is not committed, so the platform runs this "isolated" event
        // as a normal event. A failing subscriber rolls back the confirmation as well.
        OnAfterConfirmShipment(ShipmentHeader);
    end;

    [IntegrationEvent(false, false, true)]
    local procedure OnAfterConfirmShipment(ShipmentHeader: Record "Shipment Header Demo")
    begin
    end;
}

table 50180 "Shipment Header Demo"
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
