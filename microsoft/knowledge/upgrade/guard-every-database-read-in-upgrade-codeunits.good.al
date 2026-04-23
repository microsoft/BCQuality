codeunit 50806 "Upgrade Sample GuardReads Good"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeDefaults();
    end;

    local procedure UpgradeDefaults()
    var
        Setup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
    begin
        if not Setup.Get() then
            exit;

        if Customer.FindSet() then
            repeat
                // per-row work
            until Customer.Next() = 0;
    end;
}
