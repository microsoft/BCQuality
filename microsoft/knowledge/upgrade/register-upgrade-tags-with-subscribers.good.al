codeunit 50212 "Upgrade Tag Definitions"
{
    procedure MyUpgradeTag(): Code[250]
    begin
        exit('MS-123456-MyFeature-20240101');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(MyUpgradeTag());
    end;
}

codeunit 50214 "Upgrade Tagged Feature"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Tags: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(Tags.MyUpgradeTag()) then
            exit;
        // Upgrade work ...
        UpgradeTag.SetUpgradeTag(Tags.MyUpgradeTag());
    end;
}

codeunit 50215 "Install Tagged Feature"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Tags: Codeunit "Upgrade Tag Definitions";
    begin
        // Existing-company install path; new-company initialization uses
        // SetAllUpgradeTags and the subscriber above.
        UpgradeTag.SetUpgradeTag(Tags.MyUpgradeTag());
    end;
}
