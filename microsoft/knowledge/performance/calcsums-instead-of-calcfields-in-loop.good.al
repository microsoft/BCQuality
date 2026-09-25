codeunit 50222 "Perf Sample CalcSums Good"
{
    procedure TotalSales(CustomerNo: Code[20]) Total: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.");
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.CalcSums("Sales (LCY)");
        Total := CustLedgerEntry."Sales (LCY)";
    end;
}
