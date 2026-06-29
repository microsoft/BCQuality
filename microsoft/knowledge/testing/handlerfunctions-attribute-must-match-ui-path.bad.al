codeunit 50407 "Test Handler Match Bad"
{
    Subtype = Test;

    // The path raises a Confirm AND a Message, but only the Confirm handler
    // is listed. The Message has no handler -> unhandled-UI runtime abort.
    // The mirror mistake — listing a third handler the path never hits —
    // instead fails with "handler function was not executed".
    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure PostWithConfirmAndMessage()
    begin
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
    end;
}
