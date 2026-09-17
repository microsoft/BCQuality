namespace BCQuality.SCM.Samples;

using Microsoft.Sales.Document;

codeunit 50109 "SCM Tracking Transfer Good"
{
    procedure TransferBlanketOrderTracking(var SourceBlanketOrderLine: Record "Sales Line"; var DestinationSalesOrderLine: Record "Sales Line"; QuantityBaseToTransfer: Decimal)
    var
        SalesLineReserve: Codeunit "Sales Line-Reserve";
    begin
        SourceBlanketOrderLine.TestField("Document Type", SourceBlanketOrderLine."Document Type"::"Blanket Order");
        SourceBlanketOrderLine.TestField(Type, SourceBlanketOrderLine.Type::Item);
        DestinationSalesOrderLine.TestField("Document Type", DestinationSalesOrderLine."Document Type"::Order);
        DestinationSalesOrderLine.TestField(Type, DestinationSalesOrderLine.Type::Item);
        DestinationSalesOrderLine.TestField("No.", SourceBlanketOrderLine."No.");
        if QuantityBaseToTransfer <= 0 then
            Error(PositiveQuantityErr);

        SalesLineReserve.TransferSaleLineToSalesLine(SourceBlanketOrderLine, DestinationSalesOrderLine, QuantityBaseToTransfer);
    end;

    var
        PositiveQuantityErr: Label 'The base quantity to transfer must be positive.';
}
