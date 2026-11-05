codeunit 50542 "Test Sample Posted Fixture Good"
{
    Subtype = Test;

    var
        LibraryPurchase: Codeunit "Library - Purchase";

    // Posted data is produced by posting, so the fixture runs under any license.
    local procedure CreatePostedPurchaseInvoice(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    [Test]
    procedure PostedInvoiceIsAvailable()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.Get(CreatePostedPurchaseInvoice());
    end;
}
