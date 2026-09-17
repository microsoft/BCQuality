codeunit 50220 "Upgrade Trigger Aware"
{
    Subtype = Upgrade;

    local procedure UpdateCustomerCreditLimit()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet(true) then
            repeat
                // Validate runs the field OnValidate logic; Modify(true) separately
                // runs the table OnModify trigger and its row-based events.
                Customer.Validate("Credit Limit (LCY)", 50000);
                Customer.Modify(true);
            until Customer.Next() = 0;
    end;
}
