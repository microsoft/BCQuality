[Test]
procedure PostSalesOrder_CreatesInvoice()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesInvoiceHeader: Record "Sales Invoice Header";
    InvoiceNo: Code[20];
begin
    // [SCENARIO] Posting a sales order results in a posted sales invoice record
    // [GIVEN] a customer with the posting groups assigned by the sales library
    LibrarySales.CreateCustomer(Customer);
    // [GIVEN] a sales order for that customer with the work date as posting date
    LibrarySales.CreateSalesOrderForCustomerNo(SalesHeader, Customer."No.");
    SalesHeader.Validate("Posting Date", WorkDate());
    SalesHeader.Modify(true);
    // [WHEN] the sales order is posted
    InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
    // [THEN] the posted sales invoice record exists
    SalesInvoiceHeader.Get(InvoiceNo);
    Assert.RecordIsNotEmpty(SalesInvoiceHeader);
end;
