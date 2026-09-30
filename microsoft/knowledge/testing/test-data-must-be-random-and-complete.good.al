[Test]
procedure PostsSalesOrderForRandomCustomer()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
begin
    // Freshly created customer, owned by this test — no assumption about what exists.
    LibrarySales.CreateCustomer(Customer);
    LibrarySales.CreateSalesHeader(
        SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

    // ... add lines, post, assert ...
end;
