codeunit 50564 "Contoso Reten. Pol. Default"
{
    Access = Internal;

    var
        SixMonthsTok: Label 'Six Months', MaxLength = 20;

    procedure CreateDefaultPolicy()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        // Created once per company: an administrator who deletes the policy
        // does not get it back on the next upgrade.
        if UpgradeTag.HasUpgradeTag(DefaultPolicyTag()) then
            exit;

        if not RetentionPolicySetup.Get(Database::"Contoso Activity Log") then begin
            RetentionPolicySetup.Validate("Table Id", Database::"Contoso Activity Log");
            RetentionPolicySetup.Validate("Apply to all records", true);
            RetentionPolicySetup.Validate("Retention Period", SixMonthRetentionPeriod());
            RetentionPolicySetup.Validate(Enabled, false); // the administrator opts in to deletion
            RetentionPolicySetup.Insert(true);
        end;

        UpgradeTag.SetUpgradeTag(DefaultPolicyTag());
    end;

    local procedure SixMonthRetentionPeriod(): Code[20]
    var
        RetentionPeriod: Record "Retention Period";
    begin
        RetentionPeriod.SetRange("Retention Period", RetentionPeriod."Retention Period"::"6 Months");
        if RetentionPeriod.FindFirst() then
            exit(RetentionPeriod.Code);

        RetentionPeriod.Code := CopyStr(UpperCase(SixMonthsTok), 1, MaxStrLen(RetentionPeriod.Code));
        RetentionPeriod.Description := SixMonthsTok;
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"6 Months");
        RetentionPeriod.Insert(true);
        exit(RetentionPeriod.Code);
    end;

    local procedure DefaultPolicyTag(): Code[250]
    begin
        exit('Contoso-ActivityLogDefaultPolicy-20260910');
    end;
}
