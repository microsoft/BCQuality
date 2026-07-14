codeunit 50401 "Test UI Handlers Bad"
{
    Subtype = Test;

    // Several wiring mistakes, each of which fails at runtime rather than as a
    // clean assertion the reviewer can read:
    //  * A UI call with no listed handler -> "unhandled UI" abort (the Message
    //    below has no handler).
    //  * The mirror mistake, listing a handler the path never hits, instead
    //    fails with "handler function was not executed".
    //  * A handler that hardcodes its answer and asserts inline, with no
    //    enqueue/dequeue -> nothing proves the RIGHT dialog fired the RIGHT
    //    number of times, and a failed inline assert can be swallowed by the
    //    calling UI operation.
    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostDocumentConfirmsAndMessages()
    begin
        // No Initialize(): a value leaked by an earlier test corrupts this one.
        RunPostingThatConfirmsAndMessages();
        // No AssertEmpty(): a missing or extra dialog goes unnoticed.
    end;

    local procedure RunPostingThatConfirmsAndMessages()
    begin
        // Raises a Confirm AND a Message, but only ConfirmHandler is listed:
        // the Message has nothing to intercept it -> unhandled-UI runtime abort.
        if Confirm('Post this document?', false) then
            Message('Posting completed.');
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        // Hardcoded expectation and hardcoded reply. If the wrong dialog fires,
        // this inline assert may never surface as the test's verdict.
        Assert.AreEqual('Post this document?', Question, 'Wrong confirm.');
        Reply := true;
    end;

    var
        Assert: Codeunit "Library Assert";
}
