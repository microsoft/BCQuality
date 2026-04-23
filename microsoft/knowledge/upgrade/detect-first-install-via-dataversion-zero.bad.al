codeunit 50822 "Upgrade Sample FirstInstall Bad"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        // Unconditional initialization. Re-install after uninstall either throws
        // on primary-key collisions or overwrites existing rows.
        InsertDefaultSetup();
    end;

    local procedure InsertDefaultSetup()
    begin
    end;
}
