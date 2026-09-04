codeunit 50130 "Sample Item Ledger Lookup"
{
    procedure GetPostedItemLedgerEntries(var SalesHeader: Record "Sales Header"; var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        LibrarySales: Codeunit "Library - Sales";
        ShippingNo: Code[20];
    begin
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ShippingNo := SalesHeader."Last Shipping No.";
        ItemLedgerEntry.SetRange("Document No.", ShippingNo);
        ItemLedgerEntry.FindSet();
    end;
}
