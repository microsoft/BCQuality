codeunit 50819 "Upgrade Sample SkipContext Good"
{
    procedure AddReportSelectionEntries()
    begin
        // Existing tenants already have the selections, possibly customized.
        if GetExecutionContext() = ExecutionContext::Upgrade then
            exit;

        InsertDefaultReportSelections();
    end;

    local procedure InsertDefaultReportSelections()
    begin
    end;
}
