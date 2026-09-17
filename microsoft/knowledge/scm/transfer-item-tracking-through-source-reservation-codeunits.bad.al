namespace BCQuality.SCM.Samples;

using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Document;

codeunit 50108 "SCM Tracking Transfer Bad"
{
    procedure TransferBlanketOrderTracking(var SourceBlanketOrderLine: Record "Sales Line"; var DestinationSalesOrderLine: Record "Sales Line"; QuantityBaseToTransfer: Decimal)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        SourceBlanketOrderLine.TestField("Document Type", SourceBlanketOrderLine."Document Type"::"Blanket Order");
        SourceBlanketOrderLine.TestField(Type, SourceBlanketOrderLine.Type::Item);
        DestinationSalesOrderLine.TestField("Document Type", DestinationSalesOrderLine."Document Type"::Order);
        DestinationSalesOrderLine.TestField(Type, DestinationSalesOrderLine.Type::Item);
        DestinationSalesOrderLine.TestField("No.", SourceBlanketOrderLine."No.");
        if QuantityBaseToTransfer <= 0 then
            Error(PositiveQuantityErr);

        ReservationEntry.SetRange("Source Type", Database::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SourceBlanketOrderLine."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", SourceBlanketOrderLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", SourceBlanketOrderLine."Line No.");
        ReservationEntry.SetRange(Positive, false);
        ReservationEntry.FindFirst();
        ReservationEntry."Source Subtype" := DestinationSalesOrderLine."Document Type".AsInteger();
        ReservationEntry."Source ID" := DestinationSalesOrderLine."Document No.";
        ReservationEntry."Source Ref. No." := DestinationSalesOrderLine."Line No.";
        ReservationEntry.Validate("Quantity (Base)", -QuantityBaseToTransfer);
        ReservationEntry.Modify(true);
    end;

    var
        PositiveQuantityErr: Label 'The base quantity to transfer must be positive.';
}
