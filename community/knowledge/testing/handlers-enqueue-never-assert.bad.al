codeunit 50405 "Test Enqueue Handler Bad"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('PostMessageHandler')]
    procedure PostingShowsConfirmationMessage()
    begin
        RunPostingThatMessages();
        // The verdict was delegated to the handler below — a failed
        // expectation there may never surface as this test's result.
    end;

    local procedure RunPostingThatMessages()
    begin
        Message('Posting completed.');
    end;

    [MessageHandler]
    procedure PostMessageHandler(Message: Text)
    begin
        // Asserting inside the handler: if this is wrong the failure can be
        // swallowed by the Message call, leaving the test falsely green.
        Assert.AreEqual('Posting completed.', Message, 'Unexpected confirmation message.');
    end;

    var
        Assert: Codeunit "Library Assert";
}
