codeunit 50809 "Upgrade Sample DataTransfer Bad"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        InitializeNewFlag();
    end;

    local procedure InitializeNewFlag()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Row-at-a-time update over a 10M-row ledger table. Multi-hour upgrade.
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.FindSet(true) then
            repeat
                CustLedgerEntry."New Flag" := false;
                CustLedgerEntry.Modify();
            until CustLedgerEntry.Next() = 0;
    end;
}
