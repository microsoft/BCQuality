codeunit 50821 "Upgrade Sample FirstInstall Good"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() <> Version.Create('0.0.0.0') then
            exit;

        // First-install-only initialization follows here.
        InsertDefaultSetup();
    end;

    local procedure InsertDefaultSetup()
    begin
    end;
}
