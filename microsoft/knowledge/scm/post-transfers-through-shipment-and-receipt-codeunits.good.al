namespace BCQuality.SCM.Samples;

using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;

codeunit 50113 "SCM Transfer Posting Good"
{
    procedure ShipTransferOrder(TransferOrderNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
    begin
        TransferHeader.Get(TransferOrderNo);
        TransferHeader.TestField("Direct Transfer", false);
        TransferHeader.TestField("In-Transit Code");
        Location.Get(TransferHeader."Transfer-from Code");
        Location.TestField("Require Shipment", false);

        TransferOrderPostShipment.Run(TransferHeader);
    end;

    procedure ReceiveTransferOrder(TransferOrderNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin
        TransferHeader.Get(TransferOrderNo);
        TransferHeader.TestField("Direct Transfer", false);
        TransferHeader.TestField("In-Transit Code");
        Location.Get(TransferHeader."Transfer-to Code");
        Location.TestField("Require Receive", false);

        TransferOrderPostReceipt.Run(TransferHeader);
    end;
}
