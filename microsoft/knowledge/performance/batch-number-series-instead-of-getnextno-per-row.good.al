codeunit 50100 "Batch NoSeries Insert Good"
{
    procedure InsertDraftOrders(var Customer: Record Customer)
    var
        SalesHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        SalesSetup.Get();
        if Customer.FindSet() then
            repeat
                SalesHeader.Init();
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader."No." := NoSeriesBatch.GetNextNo(SalesSetup."Order Nos.", WorkDate());
                SalesHeader."Sell-to Customer No." := Customer."No.";
                SalesHeader.Insert(true);
            until Customer.Next() = 0;
        NoSeriesBatch.SaveState();
    end;
}
