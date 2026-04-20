codeunit 50100 "Sales Document Processor"
{
    procedure ProcessDocument(var SalesHeader: Record "Sales Header")
    begin
        // Tier 1: the discriminator and any fields every branch reads.
        SalesHeader.SetLoadFields("Document Type", "No.", "Sell-to Customer No.");

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    // Tier 2: extend the load only on the branch that needs these fields.
                    SalesHeader.SetLoadFields("Order Date", "Shipment Date", "Completely Shipped");
                    ProcessOrder(SalesHeader);
                end;
            SalesHeader."Document Type"::Invoice:
                begin
                    SalesHeader.SetLoadFields("Posting Date", "Amount Including VAT");
                    ProcessInvoice(SalesHeader);
                end;
        end;
    end;

    local procedure ProcessOrder(var SalesHeader: Record "Sales Header") begin end;
    local procedure ProcessInvoice(var SalesHeader: Record "Sales Header") begin end;
}
