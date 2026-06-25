codeunit 50100 "Sales Document Processor"
{
    procedure ProcessDocument(var SalesHeader: Record "Sales Header")
    begin
        // Single top-level load pulls every field any branch might touch.
        // Order records pay for Posting Date and Amount Including VAT that
        // only the Invoice branch reads, and vice versa.
        SalesHeader.SetLoadFields(
            "Document Type", "No.", "Sell-to Customer No.",
            "Order Date", "Shipment Date", "Completely Shipped",
            "Posting Date", "Amount Including VAT");

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                ProcessOrder(SalesHeader);
            SalesHeader."Document Type"::Invoice:
                ProcessInvoice(SalesHeader);
        end;
    end;

    local procedure ProcessOrder(var SalesHeader: Record "Sales Header") begin end;
    local procedure ProcessInvoice(var SalesHeader: Record "Sales Header") begin end;
}
