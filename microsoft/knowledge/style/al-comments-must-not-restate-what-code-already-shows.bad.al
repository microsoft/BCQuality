codeunit 50101 "Credit Memo Routing"
{
    procedure PostSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; Amount: Decimal)
    begin
        // Set the customer number
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        // Insert the line
        SalesLine.Insert(true);
        // Check if the amount is positive
        if Amount > 0 then
            // Post the entry
            PostEntry(Amount);
    end;

    local procedure PostEntry(Amount: Decimal)
    begin
    end;
}
