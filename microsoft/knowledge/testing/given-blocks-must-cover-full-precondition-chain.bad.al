[Test]
procedure PostSalesOrder_CreatesInvoice()
var
    SalesHeader: Record "Sales Header";
begin
    // [GIVEN] a sales order — posting groups left to whatever exists in the test company
    LibrarySales.CreateSalesOrder(SalesHeader);
    // [WHEN]
    LibrarySales.PostSalesOrder(SalesHeader, false, true);
    // [THEN]
    Assert.RecordIsNotEmpty(SalesInvoiceHeader);
end;
