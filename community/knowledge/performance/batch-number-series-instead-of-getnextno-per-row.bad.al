codeunit 50100 "Batch NoSeries Insert Bad"
{
    procedure InsertDraftOrders(var Customer: Record Customer)
    var
        SalesHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        SalesSetup.Get();
        if Customer.FindSet() then
            repeat
                SalesHeader.Init();
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                // Per-row GetNextNo locks the number-series line every insert.
                SalesHeader."No." := NoSeries.GetNextNo(SalesSetup."Order Nos.", WorkDate());
                SalesHeader."Sell-to Customer No." := Customer."No.";
                SalesHeader.Insert(true);
            until Customer.Next() = 0;
    end;
}
