[Test]
procedure PostsSalesOrderForCashCustomer()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
begin
    // Assumes a 'CASH' customer already exists in the environment —
    // fails on any database where it doesn't.
    Customer.Get('CASH');
    LibrarySales.CreateSalesHeader(
        SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

    // ... add lines, post, assert ...
end;
