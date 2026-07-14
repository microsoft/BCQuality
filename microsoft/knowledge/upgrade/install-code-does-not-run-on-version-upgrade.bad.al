codeunit 50306 "My App Install Only"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        // A normal version upgrade never invokes this migration.
        MigrateLegacySetup();
    end;

    local procedure MigrateLegacySetup()
    var
        MyAppSetup: Record "My App Setup";
    begin
        if MyAppSetup.Get() then begin
            MyAppSetup."Configuration Version" := 2;
            MyAppSetup.Modify(true);
        end;
    end;
}
