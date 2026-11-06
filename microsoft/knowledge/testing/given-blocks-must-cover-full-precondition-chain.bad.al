[Test]
procedure PostSalesOrder_CreatesInvoice()
var
    SalesHeader: Record "Sales Header";
    SalesInvoiceHeader: Record "Sales Invoice Header";
    InvoiceNo: Code[20];
begin
    // [SCENARIO] Posting a sales order results in a posted sales invoice record
    // [GIVEN] a sales order
    // Posting groups are left to whatever exists in the test company.
    LibrarySales.CreateSalesOrder(SalesHeader);
    // [WHEN] the sales order is posted
    InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
    // [THEN] the posted sales invoice record exists
    SalesInvoiceHeader.Get(InvoiceNo);
    Assert.RecordIsNotEmpty(SalesInvoiceHeader);
end;
