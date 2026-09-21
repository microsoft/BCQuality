codeunit 50565 "Contoso Reten. Pol. Register"
{
    Subtype = Install;
    Access = Internal;

    // The table becomes selectable on the Retention Policies page and nothing
    // else happens: no Retention Policy Setup record is created, so no period
    // is proposed and no data is ever deleted. The log table keeps growing
    // until someone notices the tenant's storage consumption.
    trigger OnInstallAppPerCompany()
    var
        ContosoActivityLog: Record "Contoso Activity Log";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        RetenPolAllowedTables.AddAllowedTable(
            Database::"Contoso Activity Log", ContosoActivityLog.FieldNo(SystemCreatedAt));
    end;
}
