codeunit 50564 "Contoso Reten. Pol. Default"
{
    Access = Internal;

    procedure CreateDefaultPolicy()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupMgt: Codeunit "Retention Policy Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
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
