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

    [Test]
    [HandlerFunctions('CustomerCardHandler,MandatoryNotificationHandler')]
    procedure UnreachedNonoptionalNotificationHandlerFailsAtRuntime()
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);

        Page.RunModal(Page::"Customer Card", Customer);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,PostMessageHandler')]
    procedure ConfirmPostingAndShowMessage()
    begin
        Assert.IsTrue(RunPostingThatConfirmsAndMessages(), 'The posting confirmation was declined.');
    end;

    local procedure RunPostingThatConfirmsAndMessages(): Boolean
    begin
        if not Confirm('Post this document?', false) then
            exit(false);
        Message('Posting completed.');
        exit(true);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure PostMessageHandler(MessageText: Text[1024])
    begin
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
