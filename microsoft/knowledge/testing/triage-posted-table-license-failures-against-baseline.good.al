using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

codeunit 50542 "Posted Fixture Good"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryPurchase: Codeunit "Library - Purchase";

    local procedure CreatePostedPurchaseInvoice(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    // [FEATURE] Purchase invoice fixtures
    [Test]
    procedure PostedInvoiceIsAvailable()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] Retrieve a posted purchase invoice
        // [GIVEN] Purchase posting setup is available
        // [WHEN] The invoice fixture is created
        PostedInvoiceNo := CreatePostedPurchaseInvoice();
        // [THEN] The posted invoice can be retrieved by number
        PurchInvHeader.Get(PostedInvoiceNo);
    end;
}
