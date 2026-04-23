codeunit 50804 "Upgrade Sample TagRegister Good"
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(FeatureXUpgradeTag());
    end;

    local procedure FeatureXUpgradeTag(): Code[250]
    begin
        exit('MS-000003-FeatureX-20260501');
    end;
}
