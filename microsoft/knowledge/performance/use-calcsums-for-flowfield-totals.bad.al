codeunit 50115 "Perf Sample CalcSums Bad"
{
    procedure OutstandingForCustomer(CustomerNo: Code[20]) Total: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.FindSet() then
            repeat
                Total += CustLedgerEntry."Remaining Amt. (LCY)";
            until CustLedgerEntry.Next() = 0;
    end;
}
