codeunit 50802 "Upgrade Sample TagGuard Good"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeFeatureX();
    end;

    local procedure UpgradeFeatureX()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(FeatureXUpgradeTag()) then
            exit;

        // Idempotent, retries cleanly after failure, runs exactly once.

        UpgradeTag.SetUpgradeTag(FeatureXUpgradeTag());
    end;

    local procedure FeatureXUpgradeTag(): Code[250]
    begin
        exit('MS-000002-FeatureX-20260501');
    end;
}
