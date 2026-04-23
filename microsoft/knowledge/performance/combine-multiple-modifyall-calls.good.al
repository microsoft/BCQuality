codeunit 51206 "Perf Sample CombineMA Good"
{
    procedure UpdateTolerance(DocumentNo: Code[20]; ToleranceAmount: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.FindSet(true) then
            repeat
                CustLedgerEntry."Accepted Payment Tolerance" := ToleranceAmount;
                CustLedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                CustLedgerEntry.Modify(false);
            until CustLedgerEntry.Next() = 0;
    end;
}
