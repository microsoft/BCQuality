codeunit 50406 "Test Handler Match Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,PostMessageHandler')]
    procedure PostWithConfirmAndMessage()
    begin
        // The path below raises BOTH a Confirm and a Message, and the
        // attribute names exactly those two handlers — no more, no less.
        RunPostingThatConfirmsAndMessages();
    end;

    local procedure RunPostingThatConfirmsAndMessages()
    begin
        if Confirm('Post this document?', false) then
            Message('Posting completed.');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure PostMessageHandler(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
}
