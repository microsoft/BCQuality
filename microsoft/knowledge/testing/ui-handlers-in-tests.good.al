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

    [Test]
    [HandlerFunctions('ConfirmHandler,PostMessageHandler')]
    procedure ConfirmPostingAndShowMessage()
    begin
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue('Post this document?');
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue('Posting completed.');

        Assert.IsTrue(RunPostingThatConfirmsAndMessages(), 'The posting confirmation was declined.');

        LibraryVariableStorage.AssertEmpty();
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
        Assert.ExpectedConfirm(LibraryVariableStorage.DequeueText(), Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure PostMessageHandler(MessageText: Text[1024])
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), MessageText);
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
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        CapturedCustomerNo: Code[20];
}
