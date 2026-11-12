using Microsoft.Purchases.History;

codeunit 50543 "Posted Fixture Bad"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryUtility: Codeunit "Library - Utility";

    local procedure CreatePostedPurchaseInvoice(): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.Init();
        PurchInvHeader."No." := LibraryUtility.GenerateGUID();
        PurchInvHeader.Insert();
        exit(PurchInvHeader."No.");
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
