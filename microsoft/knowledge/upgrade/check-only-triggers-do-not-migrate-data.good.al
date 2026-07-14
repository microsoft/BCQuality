codeunit 50302 "Upgrade Phases Good"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    begin
        CheckTargetPostingGroup();
    end;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(CustomerPostingGroupTag()) then
            exit;

        MigrateCustomerPostingGroups();
        UpgradeTag.SetUpgradeTag(CustomerPostingGroupTag());
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        CheckLegacyPostingGroupsRemoved();
    end;

    local procedure CheckTargetPostingGroup()
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if not CustomerPostingGroup.Get('NEW') then
            Error(TargetGroupMissingErr);
    end;

    local procedure MigrateCustomerPostingGroups()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Customer Posting Group", 'OLD');
        if Customer.FindSet(true) then
            repeat
                Customer.Validate("Customer Posting Group", 'NEW');
                Customer.Modify(true);
            until Customer.Next() = 0;
    end;

    local procedure CheckLegacyPostingGroupsRemoved()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Customer Posting Group", 'OLD');
        if not Customer.IsEmpty() then
            Error(MigrationIncompleteErr);
    end;

    local procedure CustomerPostingGroupTag(): Code[250]
    begin
        exit('MS-50302-CustomerPostingGroup-20260714');
    end;

    var
        MigrationIncompleteErr: Label 'The legacy customer posting group was not migrated.';
        TargetGroupMissingErr: Label 'Customer posting group NEW must exist before the upgrade.';
}
