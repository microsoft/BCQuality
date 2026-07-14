codeunit 50211 "Install My Extension"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        // No DataVersion() guard: a reinstall duplicates seed rows.
        SeedDefaultRows();
    end;

    local procedure SeedDefaultRows() begin end;
}
