codeunit 51207 "Perf Sample CombineMA Bad"
{
    procedure UpdateTolerance(DocumentNo: Code[20]; ToleranceAmount: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.SetRange(Open, true);
        // Two scans over the same filtered rows on a 10M-row ledger table.
        CustLedgerEntry.ModifyAll("Accepted Payment Tolerance", ToleranceAmount);
        CustLedgerEntry.ModifyAll("Accepted Pmt. Disc. Tolerance", false);
    end;
}
