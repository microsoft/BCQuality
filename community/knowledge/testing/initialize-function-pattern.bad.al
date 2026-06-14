codeunit 50101 "Sales Discount Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    var
        LibrarySales: Codeunit "Library - Sales";

    [Test]
    procedure PostSalesOrderCreatesHeader()
    var
        SalesHeader: Record "Sales Header";
    begin
        // No Initialize() - setup bloat repeated in every test.
        // No LibraryVariableStorage.Clear() - stale handler bindings carry over from prior tests.
        LibrarySales.SetCreditWarningsToNoWarnings();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        if SalesHeader."No." = '' then Error('Header number not assigned');
    end;

    [Test]
    procedure SalesInvoiceCarriesSellToCustomer()
    var
        SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
    begin
        // Identical setup pasted again. Change the requirement once, miss it here.
        LibrarySales.SetCreditWarningsToNoWarnings();
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        if SalesHeader."Sell-to Customer No." <> CustomerNo then Error('Sell-to customer mismatch');
    end;
}
