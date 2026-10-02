table 50568 "Contoso Activity Log"
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

codeunit 50564 "Contoso Reten. Pol. Default"
{
    Access = Internal;
    Permissions = tabledata "Retention Policy Setup" = ri;

    procedure CreateDefaultPolicy()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupMgt: Codeunit "Retention Policy Setup";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        // A setup can only be created for a table that is already registered.
        if not RetenPolAllowedTables.IsAllowedTable(Database::"Contoso Activity Log") then
            exit;

        // Created once per company: an administrator who deletes the policy
        // does not get it back on the next upgrade.
        if UpgradeTag.HasUpgradeTag(DefaultPolicyTag()) then
            exit;

        if not RetentionPolicySetup.Get(Database::"Contoso Activity Log") then begin
            RetentionPolicySetup.Validate("Table Id", Database::"Contoso Activity Log");
            RetentionPolicySetup.Validate("Apply to all records", true);
            RetentionPolicySetup.Validate(
                "Retention Period",
                RetentionPolicySetupMgt.FindOrCreateRetentionPeriod("Retention Period Enum"::"6 Months"));
            RetentionPolicySetup.Validate(Enabled, false); // the administrator opts in to deletion
            RetentionPolicySetup.Insert(true);
        end;

        UpgradeTag.SetUpgradeTag(DefaultPolicyTag());
    end;

    local procedure DefaultPolicyTag(): Code[250]
    begin
        exit('Contoso-ActivityLogDefaultPolicy-20260910');
    end;
}
