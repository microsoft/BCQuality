codeunit 50143 "Sample Doc Amount Test"
{
    Subtype = Test;

    [Test]
    procedure DocAmountIsNotVerifiedWhenLinesAreMissing()
    var
        Assert: Codeunit Assert;
        PurchHeader: Record "Purchase Header";
    begin
        asserterror Assert.IsTrue(VerifyDocAmount(PurchHeader), 'Doc. amount should not verify with no lines.');
    end;

    local procedure VerifyDocAmount(var PurchHeader: Record "Purchase Header"): Boolean
    begin
        exit(false);
    end;
}
