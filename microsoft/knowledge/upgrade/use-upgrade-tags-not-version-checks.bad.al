codeunit 50803 "Upgrade Sample TagGuard Bad"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        // Version check: fragile across skipped versions, and every nested branch
        // is another place a customer can be stuck if the matching step fails.
        if AppInfo.DataVersion().Major < 18 then
            UpgradeFeatureA()
        else
            if AppInfo.DataVersion().Major < 21 then
                UpgradeFeatureB();
    end;

    local procedure UpgradeFeatureA()
    begin
    end;

    local procedure UpgradeFeatureB()
    begin
    end;
}
