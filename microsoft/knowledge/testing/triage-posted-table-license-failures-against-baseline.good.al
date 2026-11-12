using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;

codeunit 50542 "Posted Fixture Good"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryPurchase: Codeunit "Library - Purchase";

    // [FEATURE] Purchase invoice fixtures
    [Test]
    procedure PostedInvoiceIsAvailable()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] Retrieve a posted purchase invoice
        // [GIVEN] A vendor with library-assigned posting groups
        LibraryPurchase.CreateVendor(Vendor);
        // [GIVEN] An invoice for the vendor with an explicit posting date
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify(true);
        // [WHEN] The invoice is posted
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        // [THEN] The posted invoice can be retrieved by number
        PurchInvHeader.Get(PostedInvoiceNo);
    end;
}
