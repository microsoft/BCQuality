codeunit 50805 "Upgrade Sample TagRegister Bad"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(FeatureXUpgradeTag()) then
            exit;

        UpgradeTag.SetUpgradeTag(FeatureXUpgradeTag());
    end;

    // Missing OnGetPerCompanyUpgradeTags subscriber.
    // The tag is set but the platform's upgrade-tag machinery does not know about it.

    local procedure FeatureXUpgradeTag(): Code[250]
    begin
        exit('MS-000004-FeatureX-20260501');
    end;
}
