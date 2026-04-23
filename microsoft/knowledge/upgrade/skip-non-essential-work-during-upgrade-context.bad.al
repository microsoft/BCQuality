codeunit 50820 "Upgrade Sample SkipContext Bad"
{
    procedure AddReportSelectionEntries()
    begin
        // No execution-context check. On upgrade, this either throws on
        // primary-key conflict or silently overwrites the tenant's
        // customized report selections.
        InsertDefaultReportSelections();
    end;

    local procedure InsertDefaultReportSelections()
    begin
    end;
}
