codeunit 50640 "Sample Upgrade Good"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        CreateUpgradeState();
        MigrateDependentData();
    end;

    local procedure CreateUpgradeState()
    begin
    end;

    local procedure MigrateDependentData()
    begin
    end;
}
