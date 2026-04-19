codeunit 50100 "Recent Orders Summary"
{
    procedure SummarizeRecentOrders(StartDate: Date; EndDate: Date)
    var
        SalesHeader: Record "Sales Header";
    begin
        // "Document Type" and "Document Date" are listed in SetLoadFields even
        // though they appear only in filters. Per-row values are transferred
        // for columns the processing body never reads.
        SalesHeader.SetLoadFields(
            "Document Type", "Document Date",
            "No.", "Sell-to Customer No.", "Amount Including VAT");

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Document Date", StartDate, EndDate);

        if SalesHeader.FindSet() then
            repeat
                Emit(SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Amount Including VAT");
            until SalesHeader.Next() = 0;
    end;

    local procedure Emit(No: Code[20]; CustNo: Code[20]; Amount: Decimal) begin end;
}
