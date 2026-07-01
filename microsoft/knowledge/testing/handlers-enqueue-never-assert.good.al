codeunit 50404 "Test Enqueue Handler Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('PostMessageHandler')]
    procedure PostingShowsConfirmationMessage()
    var
        ActualMessage: Text;
    begin
        // [WHEN] the code under test posts and raises a Message
        RunPostingThatMessages();

        // [THEN] the body — not the handler — owns the verdict
        ActualMessage := LibraryVariableStorage.DequeueText();
        Assert.AreEqual('Posting completed.', ActualMessage, 'Unexpected confirmation message.');
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure RunPostingThatMessages()
    begin
        // Stands in for the production routine that ends with a Message.
        Message('Posting completed.');
    end;

    [MessageHandler]
    procedure PostMessageHandler(Message: Text)
    begin
        // Capture only — never assert here.
        LibraryVariableStorage.Enqueue(Message);
    end;

    var
        Assert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
}
