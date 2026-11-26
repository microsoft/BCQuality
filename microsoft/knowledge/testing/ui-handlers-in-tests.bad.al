// [FEATURE] Customer management
codeunit 50401 "Test UI Handler Proof Bad"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure PreSetBooleanDoesNotProveCustomerCardResult()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] The customer card is opened for a newly created customer
        // [GIVEN] a newly created customer and a status flag
        LibrarySales.CreateCustomer(Customer);
        ActionSucceeded := true;

        // [WHEN] the customer card is opened for the customer
        Page.RunModal(Page::"Customer Card", Customer);

        // [THEN] the status flag is checked
        // This only proves a value assigned before the action stayed true.
        Assert.IsTrue(ActionSucceeded, 'The customer card action failed.');
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure MissingMessageHandlerFailsAtRuntime()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] A message follows the customer card for a newly created customer
        // [GIVEN] a newly created customer
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] the customer card is opened for the customer and a message is raised afterwards
        Page.RunModal(Page::"Customer Card", Customer);
        Message('Customer card closed.');
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler,UnusedConfirmHandler')]
    procedure UnreachedListedHandlerFailsAtRuntime()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] The customer card is opened and closed for a newly created customer
        // [GIVEN] a newly created customer
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] the customer card is opened for the customer
        Page.RunModal(Page::"Customer Card", Customer);
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler,MandatoryNotificationHandler')]
    procedure UnreachedNonoptionalNotificationHandlerFailsAtRuntime()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] The customer card is opened and closed for a newly created customer
        // [GIVEN] a newly created customer
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] the customer card is opened for the customer
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

    [SendNotificationHandler]
    procedure MandatoryNotificationHandler(var TheNotification: Notification): Boolean
    begin
        exit(true);
    end;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        ActionSucceeded: Boolean;
}
