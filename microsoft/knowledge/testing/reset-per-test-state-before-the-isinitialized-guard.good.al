codeunit 50410 "Test Sales Setup Initialize Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure CustomerCardOpensForSelectedCustomer()
    var
        Customer: Record Customer;
    begin
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");

        Page.RunModal(Page::"Customer Card", Customer);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure StockoutWarningCanBeDisabled()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        Initialize();

        LibrarySales.SetStockoutWarning(false);

        SalesSetup.Get();
        Assert.IsFalse(SalesSetup."Stockout Warning", 'The stockout warning was not disabled.');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Test Sales Setup Initialize Good");
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Test Sales Setup Initialize Good");

        LibrarySales.SetStockoutWarning(true);
        IsInitialized := true;
        LibrarySetupStorage.SaveSalesSetup();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Test Sales Setup Initialize Good");
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
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
}
