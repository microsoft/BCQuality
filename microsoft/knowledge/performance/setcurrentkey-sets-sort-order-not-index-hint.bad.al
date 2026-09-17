codeunit 50231 "Perf Sample SetCurrentKey Bad"
{
    // Misconception: SetCurrentKey does NOT tell SQL Server to use this index.
    // The optimizer picks the index from the filters (WHERE clause) and statistics.
    // The result order is never used here, so SetCurrentKey only adds an ORDER BY
    // the query does not need — and can push the plan toward a sort.
    procedure SumRemainingAmount(CustomerNo: Code[20]) Total: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", Open, "Posting Date");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        if CustLedgerEntry.FindSet() then
            repeat
                Total += CustLedgerEntry."Remaining Amount";
            until CustLedgerEntry.Next() = 0;
    end;
}
