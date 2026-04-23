codeunit 50807 "Upgrade Sample GuardReads Bad"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Setup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
    begin
        // Unguarded Get. One tenant whose Setup row is missing blocks the upgrade.
        Setup.Get();

        // Unguarded FindSet. Raises when the table is empty for this tenant.
        Customer.FindSet();
        repeat
            // per-row work
        until Customer.Next() = 0;
    end;
}
