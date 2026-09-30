table 50566 "Contoso Activity Log"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Activity"; Text[250]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

codeunit 50560 "Contoso Reten. Pol. Setup"
{
    Access = Internal;

    procedure AddAllowedTables()
    begin
        AddAllowedTables(false);
    end;

    // ForceUpdate re-registers even after the upgrade tag is set, so the
    // table comes back when an administrator refreshes the allowed tables.
    procedure AddAllowedTables(ForceUpdate: Boolean)
    var
        ContosoActivityLog: Record "Contoso Activity Log";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsInitialSetup: Boolean;
    begin
        IsInitialSetup := not UpgradeTag.HasUpgradeTag(AllowedTableTag());
        if not (IsInitialSetup or ForceUpdate) then
            exit;

        if not RetenPolAllowedTables.IsAllowedTable(Database::"Contoso Activity Log") then
            RetenPolAllowedTables.AddAllowedTable(
                Database::"Contoso Activity Log",
                ContosoActivityLog.FieldNo(SystemCreatedAt),
                28); // support cases need at least four weeks of log history

        if IsInitialSetup then
            UpgradeTag.SetUpgradeTag(AllowedTableTag());
    end;

    local procedure AllowedTableTag(): Code[250]
    begin
        exit('Contoso-ActivityLogAllowedTable-20260910');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reten. Pol. Allowed Tables", OnRefreshAllowedTables, '', false, false)]
    local procedure AddAllowedTablesOnRefreshAllowedTables()
    begin
        AddAllowedTables(true);
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
