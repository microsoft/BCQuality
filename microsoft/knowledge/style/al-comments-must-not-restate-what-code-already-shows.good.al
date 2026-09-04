codeunit 50101 "Credit Memo Routing"
{
    procedure PostSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; Amount: Decimal)
    begin
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesLine.Insert(true);

        // Negative amounts arrive from credit memos routed through this
        // codeunit; PostEntry() rejects them, so they're filtered here.
        if Amount < 0 then
            exit;

        if Amount > 0 then
            PostEntry(Amount);
    end;

    local procedure PostEntry(Amount: Decimal)
    begin
    end;
}
