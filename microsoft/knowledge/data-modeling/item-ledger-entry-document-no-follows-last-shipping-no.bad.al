codeunit 50130 "Sample Item Ledger Lookup"
{
    procedure GetPostedItemLedgerEntries(var SalesHeader: Record "Sales Header"; var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ItemLedgerEntry.SetRange("Document No.", InvoiceNo);
        ItemLedgerEntry.FindSet();
    end;
}
