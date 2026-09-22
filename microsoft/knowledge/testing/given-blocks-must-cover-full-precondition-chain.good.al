[Test]
procedure PostSalesOrder_CreatesInvoice()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesInvoiceHeader: Record "Sales Invoice Header";
    InvoiceNo: Code[20];
begin
    // [GIVEN] a customer
    LibrarySales.CreateCustomer(Customer);
    // [GIVEN] a sales order for that customer
    LibrarySales.CreateSalesOrderForCustomerNo(SalesHeader, Customer."No.");
    SalesHeader.Validate("Posting Date", WorkDate());
    SalesHeader.Modify(true);
    // [WHEN]
    InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
    // [THEN]
    SalesInvoiceHeader.Get(InvoiceNo);
    Assert.RecordIsNotEmpty(SalesInvoiceHeader);
end;
