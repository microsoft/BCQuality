using Microsoft.Purchases.History;

codeunit 50543 "Posted Fixture Bad"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryUtility: Codeunit "Library - Utility";

    // [FEATURE] Purchase invoice fixtures
    [Test]
    procedure PostedInvoiceIsAvailable()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] Retrieve a posted purchase invoice
        // [GIVEN] An invoice number for the fixture
        PostedInvoiceNo := LibraryUtility.GenerateGUID();
        // [WHEN] The invoice fixture is created
        PurchInvHeader.Init();
        PurchInvHeader."No." := PostedInvoiceNo;
        PurchInvHeader.Insert();
        // [THEN] The posted invoice can be retrieved by number
        PurchInvHeader.Get(PostedInvoiceNo);
    end;
}
