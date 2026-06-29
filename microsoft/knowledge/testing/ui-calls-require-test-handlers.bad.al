codeunit 50401 "Test UI Handlers Bad"
{
    Subtype = Test;

    // No [HandlerFunctions] and no ConfirmHandler: the Confirm below has
    // nothing to intercept it, so this test fails at runtime with an
    // "unhandled UI" error before any assertion is evaluated.
    [Test]
    procedure DeleteDocumentConfirmsAndProceeds()
    var
        Deleted: Boolean;
    begin
        Deleted := TryDeleteWithConfirm();
        Assert.IsTrue(Deleted, 'Routine should proceed after confirmation.');
    end;

    local procedure TryDeleteWithConfirm(): Boolean
    begin
        if not Confirm('Delete this document?', false) then
            exit(false);
        exit(true);
    end;

    var
        Assert: Codeunit "Library Assert";
}
