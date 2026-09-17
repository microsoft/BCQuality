codeunit 50235 "Upgrade With Validation"
{
    Subtype = Upgrade;

    trigger OnValidateUpgradePerCompany()
    begin
        // A full-table scan repeats on every upgrade.
        ValidateAllCustomers();
    end;

    local procedure ValidateAllCustomers()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet() then
            repeat
                if Customer."Customer Posting Group" = 'OLD' then
                    Error(MigrationIncompleteErr);
            until Customer.Next() = 0;
    end;

    var
        MigrationIncompleteErr: Label 'The legacy customer posting group was not migrated.';
}
