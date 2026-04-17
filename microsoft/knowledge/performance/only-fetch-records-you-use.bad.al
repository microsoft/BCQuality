codeunit 50107 "Perf Sample OnlyFetchUsed Bad"
{
    procedure CustomerHasEntries(CustomerNo: Code[20]): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        exit(CustLedgerEntry.FindSet());
    end;
}
