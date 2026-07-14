codeunit 50234 "Upgrade With Validation"
{
    Subtype = Upgrade;

    trigger OnValidateUpgradePerCompany()
    begin
        CheckNoLegacyPostingGroups();
    end;

    local procedure CheckNoLegacyPostingGroups()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Customer Posting Group", 'OLD');
        if not Customer.IsEmpty() then
            Error(MigrationIncompleteErr);
    end;

    var
        MigrationIncompleteErr: Label 'The legacy customer posting group was not migrated.';
}
