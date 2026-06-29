codeunit 50400 "Test UI Handlers Good"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure DeleteDocumentConfirmsAndProceeds()
    var
        Deleted: Boolean;
    begin
        // [WHEN] the code under test guards the delete with a Confirm
        Deleted := TryDeleteWithConfirm();

        // [THEN] the handler answered yes, so the routine proceeded
        Assert.IsTrue(Deleted, 'Routine should proceed after confirmation.');
    end;

    local procedure TryDeleteWithConfirm(): Boolean
    begin
        // Stands in for the production routine that confirms before deleting.
        if not Confirm('Delete this document?', false) then
            exit(false);
        exit(true);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    var
        Assert: Codeunit "Library Assert";
}
