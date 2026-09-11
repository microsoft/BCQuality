codeunit 50560 "Contoso Reten. Pol. Setup"
{
    Access = Internal;

    procedure AddAllowedTables()
    var
        ContosoActivityLog: Record "Contoso Activity Log";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(AllowedTableTag()) then
            exit;

        if not RetenPolAllowedTables.IsAllowedTable(Database::"Contoso Activity Log") then
            RetenPolAllowedTables.AddAllowedTable(
                Database::"Contoso Activity Log",
                ContosoActivityLog.FieldNo(SystemCreatedAt),
                28); // support cases need at least four weeks of log history

        UpgradeTag.SetUpgradeTag(AllowedTableTag());
    end;

    local procedure AllowedTableTag(): Code[250]
    begin
        exit('Contoso-ActivityLogAllowedTable-20260910');
    end;
}

codeunit 50561 "Contoso Reten. Pol. Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    var
        ContosoRetenPolSetup: Codeunit "Contoso Reten. Pol. Setup";
    begin
        ContosoRetenPolSetup.AddAllowedTables();
    end;
}

codeunit 50562 "Contoso Reten. Pol. Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    // Install code does not run on upgrade, so tenants that already have the
    // app get their registration here.
    trigger OnUpgradePerCompany()
    var
        ContosoRetenPolSetup: Codeunit "Contoso Reten. Pol. Setup";
    begin
        ContosoRetenPolSetup.AddAllowedTables();
    end;
}
