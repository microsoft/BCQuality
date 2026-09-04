[Test]
procedure PostSalesOrder_CreatesInvoice()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
begin
    // [GIVEN] a customer with a full posting-group chain and VAT setup
    LibrarySales.CreateCustomerWithPostingSetup(Customer);
    // [GIVEN] a sales order for that customer, dated explicitly
    LibrarySales.CreateSalesOrderForCustomer(SalesHeader, Customer."No.", WorkDate());
    // [WHEN]
    LibrarySales.PostSalesOrder(SalesHeader, false, true);
    // [THEN]
    Assert.RecordIsNotEmpty(SalesInvoiceHeader);
end;
