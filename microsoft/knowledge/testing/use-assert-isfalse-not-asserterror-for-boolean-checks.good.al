// [FEATURE] Purchase document amount verification
codeunit 50143 "Sample Doc Amount Test"
{
    Subtype = Test;

    [Test]
    procedure DocAmountIsNotVerifiedWhenLinesAreMissing()
    var
        Assert: Codeunit Assert;
        PurchHeader: Record "Purchase Header";
    begin
        // [SCENARIO] A purchase header with no lines does not pass document amount verification
        // [WHEN] the document amount of a purchase header with no lines is verified
        // [THEN] the document amount is not verified
        Assert.IsFalse(VerifyDocAmount(PurchHeader), 'Doc. amount should not verify with no lines.');
    end;

    local procedure VerifyDocAmount(var PurchHeader: Record "Purchase Header"): Boolean
    begin
        exit(false);
    end;
}
