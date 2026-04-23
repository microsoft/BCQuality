codeunit 50801 "Upgrade Sample CallMethods Bad"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Customer: Record Customer;
    begin
        // Inline logic in the trigger body: no tag guard, not testable in isolation,
        // re-runs on every upgrade.
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        Customer.ModifyAll("Some Field", true);
    end;
}
