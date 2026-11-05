// [FEATURE] Customer and sales setup
codeunit 50411 "Test Sales Setup Initialize Bad"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure CustomerCardOpensForSelectedCustomer()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] The customer card opens for the customer that is passed to the page
        // [GIVEN] the test codeunit is initialized
        Initialize();
        // [GIVEN] a customer whose number is queued for the customer card handler
        LibrarySales.CreateCustomer(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");

        // [WHEN] the customer card is opened for that customer
        Page.RunModal(Page::"Customer Card", Customer);

        // [THEN] the queued customer number is consumed by the handler
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure StockoutWarningCanBeDisabled()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // [SCENARIO] The stockout warning on the sales setup can be switched off
        // [GIVEN] the test codeunit is initialized
        Initialize();

        // [WHEN] the stockout warning is switched off
        LibrarySales.SetStockoutWarning(false);

        // [THEN] the sales setup holds the stockout warning as disabled
        SalesSetup.Get();
        Assert.IsFalse(SalesSetup."Stockout Warning", 'The stockout warning was not disabled.');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();
        LibrarySales.SetStockoutWarning(true);
        IsInitialized := true;
        LibrarySetupStorage.SaveSalesSetup();
    end;

    [ModalPageHandler]
    procedure CustomerCardHandler(var CustomerCard: TestPage "Customer Card")
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), CustomerCard."No.".Value(), 'The customer card opened for the wrong customer.');
    end;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
}
