codeunit 50400 "Test UI Handler Capture Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('CustomerCardHandler')]
    procedure CustomerCardShowsSelectedCustomer()
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        CapturedCustomerNo := '';

        Page.RunModal(Page::"Customer Card", Customer);

        Assert.AreEqual(Customer."No.", CapturedCustomerNo, 'The customer card opened for the wrong customer.');
    end;

    [Test]
    [HandlerFunctions('CustomerCardHandler,CreditLimitNotificationHandler')]
    procedure CustomerCardOpensForCustomerWithinCreditLimit()
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        CapturedCustomerNo := '';

        Page.RunModal(Page::"Customer Card", Customer);

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
