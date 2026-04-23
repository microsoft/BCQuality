codeunit 50800 "Upgrade Sample CallMethods Good"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeCustomerDefaults();
        UpgradeSalesDocumentDefaults();
    end;

    local procedure UpgradeCustomerDefaults()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(CustomerDefaultsUpgradeTag()) then
            exit;

        // Step body omitted

        UpgradeTag.SetUpgradeTag(CustomerDefaultsUpgradeTag());
    end;

    local procedure UpgradeSalesDocumentDefaults()
    begin
    end;

    local procedure CustomerDefaultsUpgradeTag(): Code[250]
    begin
        exit('MS-000001-CustomerDefaults-20260501');
    end;
}
