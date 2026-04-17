codeunit 50106 "Perf Sample OnlyFetchUsed Good"
{
    procedure CustomerHasEntries(CustomerNo: Code[20]): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        exit(not CustLedgerEntry.IsEmpty());
    end;
}
