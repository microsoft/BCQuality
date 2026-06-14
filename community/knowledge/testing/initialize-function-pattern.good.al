codeunit 50100 "Sales Discount Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;

    [Test]
    procedure PostSalesOrderCreatesHeader()
    var
        SalesHeader: Record "Sales Header";
    begin
        Initialize();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        if SalesHeader."No." = '' then Error('Header number not assigned');
    end;

    [Test]
    procedure SalesInvoiceCarriesSellToCustomer()
    var
        SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
    begin
        Initialize();
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        if SalesHeader."Sell-to Customer No." <> CustomerNo then Error('Sell-to customer mismatch');
    end;
    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear(); // runs every test, not just on first init
        if IsInitialized then exit;
        LibrarySales.SetCreditWarningsToNoWarnings();
        IsInitialized := true;
        Commit();
    end;
}
