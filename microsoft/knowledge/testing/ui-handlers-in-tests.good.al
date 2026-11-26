// [FEATURE] Customer management
codeunit 50400 "Test UI Handler Capture Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure CustomerCardShowsSelectedCustomer()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] Opening the customer card for a customer passes that customer's number to the card handler
        // [GIVEN] a newly created customer and an empty captured customer number
        LibrarySales.CreateCustomer(Customer);
        CapturedCustomerNo := '';

        // [WHEN] the customer card is opened for the customer
        Page.RunModal(Page::"Customer Card", Customer);

        // [THEN] the customer number captured by the card handler matches the customer
        Assert.AreEqual(Customer."No.", CapturedCustomerNo, 'The customer card opened for the wrong customer.');
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler,CreditLimitNotificationHandler')]
    procedure CustomerCardOpensForCustomerWithinCreditLimit()
    var
        Customer: Record Customer;
    begin
        // [SCENARIO] The customer card is opened for a newly created customer
        // [GIVEN] a newly created customer and an empty captured customer number
        LibrarySales.CreateCustomer(Customer);
        CapturedCustomerNo := '';

        // [WHEN] the customer card is opened for the customer
        Page.RunModal(Page::"Customer Card", Customer);

        // [THEN] the customer number captured by the card handler matches the customer
        Assert.AreEqual(Customer."No.", CapturedCustomerNo, 'The customer card opened for the wrong customer.');
    end;

    [ModalPageHandler]
    procedure CustomerCardHandler(var CustomerCard: TestPage "Customer Card")
    begin
        CapturedCustomerNo := CustomerCard."No.".Value();
    end;

    [SendNotificationHandler(true)]
    procedure CreditLimitNotificationHandler(var CreditLimitNotification: Notification): Boolean
    begin
        exit(true);
    end;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        CapturedCustomerNo: Code[20];
}
