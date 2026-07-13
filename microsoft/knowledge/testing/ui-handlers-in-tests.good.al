codeunit 50400 "Test UI Handlers Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('ConfirmHandler,PostMessageHandler')]
    procedure PostDocumentConfirmsAndMessages()
    begin
        Initialize();

        // [GIVEN] the test enqueues, in interaction order, what each handler
        //         will see and how it should answer: the Confirm's expected
        //         question plus the reply to return, then the expected Message.
        LibraryVariableStorage.Enqueue('Post this document?'); // expected question (substring)
        LibraryVariableStorage.Enqueue(true);                  // reply ConfirmHandler returns
        LibraryVariableStorage.Enqueue('Posting completed.');  // expected message (substring)

        // [WHEN] the code under test raises the Confirm and then the Message
        RunPostingThatConfirmsAndMessages();

        // [THEN] every enqueued expectation was consumed exactly once
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        // Clear leftover values so a value leaked by an earlier test cannot
        // cascade into this one.
        LibraryVariableStorage.Clear();
    end;

    local procedure RunPostingThatConfirmsAndMessages()
    begin
        // Stands in for the production routine that confirms, then messages.
        if Confirm('Post this document?', false) then
            Message('Posting completed.');
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        // Verify the RIGHT dialog fired (substring match), then return the
        // reply the test enqueued for it.
        Assert.ExpectedConfirm(LibraryVariableStorage.DequeueText(), Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure PostMessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    var
        Assert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
}
