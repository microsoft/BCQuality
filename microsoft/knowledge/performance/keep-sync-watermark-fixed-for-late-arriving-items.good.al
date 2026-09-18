codeunit 50250 "Perf Sample SyncWatermark Good"
{
    procedure RetrieveMonitoredFolderEmails(var MonitorSetup: Record "Email Monitor Setup")
    var
        TempFilters: Record "Email Retrieve Filters" temporary;
        RetrievedCount: Integer;
    begin
        // Earliest Email stays pinned to the configured Start Date: emails moved
        // into the monitored folder keep their original receivedDateTime, so a
        // fixed lower bound is required to still see them after being moved in.
        TempFilters."Earliest Email" := MonitorSetup."Start Date";
        TempFilters."Exclude Processed Category" := true;

        RetrievedCount := CallGraphRetrieve(TempFilters);

        // Last Sync At records that a successful run happened, for diagnostics
        // only. It is never fed back into the retrieval filter.
        MonitorSetup."Last Sync At" := CurrentDateTime;
        MonitorSetup.Modify();
    end;

    local procedure CallGraphRetrieve(var TempFilters: Record "Email Retrieve Filters" temporary): Integer
    begin
        exit(0);
    end;
}
