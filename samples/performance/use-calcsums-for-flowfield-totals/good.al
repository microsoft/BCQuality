codeunit 50114 "Perf Sample CalcSums Good"
{
    procedure OutstandingForCustomer(CustomerNo: Code[20]): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.CalcSums("Remaining Amt. (LCY)");
        exit(CustLedgerEntry."Remaining Amt. (LCY)");
    end;
}
