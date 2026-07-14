codeunit 50304 "My App Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitializeSetup();
    end;

    local procedure InitializeSetup()
    var
        MyAppSetup: Record "My App Setup";
    begin
        if MyAppSetup.IsEmpty() then
            MyAppSetup.Insert(true);
    end;
}

codeunit 50305 "My App Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(ConfigurationVersionTag()) then
            exit;

        MigrateLegacySetup();
        UpgradeTag.SetUpgradeTag(ConfigurationVersionTag());
    end;

    local procedure MigrateLegacySetup()
    var
        MyAppSetup: Record "My App Setup";
    begin
        if MyAppSetup.Get() then begin
            MyAppSetup."Configuration Version" := 2;
            MyAppSetup.Modify(true);
        end;
    end;

    local procedure ConfigurationVersionTag(): Code[250]
    begin
        exit('MS-50305-ConfigurationVersion-20260714');
    end;
}
