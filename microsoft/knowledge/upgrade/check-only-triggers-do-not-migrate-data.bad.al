codeunit 50303 "Upgrade Phases Bad"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    begin
        // A precondition check must not repair the data it is checking.
        RenamePostingGroup();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        // Validation must not perform a migration omitted from OnUpgrade.
        MigrateCustomerPostingGroups();
    end;

    local procedure RenamePostingGroup()
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if CustomerPostingGroup.Get('OLD') then
            CustomerPostingGroup.Rename('NEW');
    end;

    local procedure MigrateCustomerPostingGroups()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Customer Posting Group", 'OLD');
        Customer.ModifyAll("Customer Posting Group", 'NEW');
    end;
}
