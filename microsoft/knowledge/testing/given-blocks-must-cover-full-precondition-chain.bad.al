[Test]
procedure PostSalesOrder_CreatesInvoice()
var
    SalesHeader: Record "Sales Header";
    SalesInvoiceHeader: Record "Sales Invoice Header";
    InvoiceNo: Code[20];
begin
    // [GIVEN] a sales order — posting groups left to whatever exists in the test company
    LibrarySales.CreateSalesOrder(SalesHeader);
    // [WHEN]
    InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
    // [THEN]
    SalesInvoiceHeader.Get(InvoiceNo);
    Assert.RecordIsNotEmpty(SalesInvoiceHeader);
end;
