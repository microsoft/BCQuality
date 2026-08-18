codeunit 50401 "Test UI Handler Proof Bad"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure PreSetBooleanDoesNotProveCustomerCardResult()
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        ActionSucceeded := true;

        Page.RunModal(Page::"Customer Card", Customer);

        // This only proves a value assigned before the action stayed true.
        Assert.IsTrue(ActionSucceeded, 'The customer card action failed.');
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure MissingMessageHandlerFailsAtRuntime()
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);

        Page.RunModal(Page::"Customer Card", Customer);
        Message('Customer card closed.');
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler,UnusedConfirmHandler')]
    procedure UnreachedListedHandlerFailsAtRuntime()
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);

        Page.RunModal(Page::"Customer Card", Customer);
    end;

    [ModalPageHandler]
    procedure CustomerCardHandler(var CustomerCard: TestPage "Customer Card")
    begin
    end;

    [ConfirmHandler]
    procedure UnusedConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        ActionSucceeded: Boolean;
}
