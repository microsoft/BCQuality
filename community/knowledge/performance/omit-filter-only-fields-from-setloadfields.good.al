codeunit 50100 "Recent Orders Summary"
{
    procedure SummarizeRecentOrders(StartDate: Date; EndDate: Date)
    var
        SalesHeader: Record "Sales Header";
    begin
        // "Document Type" and "Document Date" are used only in the filters below.
        // The database index handles them; there is no need to load their values
        // into AL memory for every row.
        SalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Amount Including VAT");

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Document Date", StartDate, EndDate);

        if SalesHeader.FindSet() then
            repeat
                Emit(SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Amount Including VAT");
            until SalesHeader.Next() = 0;
    end;

    local procedure Emit(No: Code[20]; CustNo: Code[20]; Amount: Decimal) begin end;
}
