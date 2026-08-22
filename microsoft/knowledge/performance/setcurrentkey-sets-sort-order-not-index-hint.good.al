codeunit 50230 "Perf Sample SetCurrentKey Good"
{
    // SetCurrentKey is used because the rows must be processed oldest-first.
    // The sort is a functional requirement, so the ORDER BY it adds is justified.
    procedure ApplyOldestEntriesFirst(CustomerNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetCurrentKey("Posting Date");
        if CustLedgerEntry.FindSet() then
            repeat
                // Apply entries in posting-date order ...
            until CustLedgerEntry.Next() = 0;
    end;
}

