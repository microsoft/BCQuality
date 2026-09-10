codeunit 50563 "Contoso Activity Log Cleanup"
{
    Access = Internal;

    // The log table is never added to the allowed tables, so it cannot appear
    // on the Retention Policies page. Cleanup is hard-coded here instead:
    // the period is not configurable, the deletion is not written to the
    // Retention Policy Log, and an administrator cannot switch it off.
    trigger OnRun()
    var
        ContosoActivityLog: Record "Contoso Activity Log";
    begin
        ContosoActivityLog.SetFilter(
            SystemCreatedAt, '<%1', CreateDateTime(CalcDate('<-30D>', Today()), 0T));
        ContosoActivityLog.DeleteAll();
    end;
}
