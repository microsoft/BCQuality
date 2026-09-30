codeunit 50223 "Perf Sample CalcSums Bad"
{
    procedure TotalSales(CustomerNo: Code[20]) Total: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        if CustLedgerEntry.FindSet() then
            repeat
                Total += CustLedgerEntry."Sales (LCY)";
            until CustLedgerEntry.Next() = 0;
    end;
}
