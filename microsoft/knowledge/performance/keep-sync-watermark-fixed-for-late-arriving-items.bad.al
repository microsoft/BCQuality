codeunit 50251 "Perf Sample SyncWatermark Bad"
{
    procedure RetrieveMonitoredFolderEmails(var MonitorSetup: Record "Email Monitor Setup")
    var
        TempFilters: Record "Email Retrieve Filters" temporary;
        RetrievedCount: Integer;
    begin
        TempFilters."Earliest Email" := MonitorSetup."Earliest Sync At";
        TempFilters."Exclude Processed Category" := true;

        RetrievedCount := CallGraphRetrieve(TempFilters);

        // Advancing the lower bound after every successful poll permanently
        // excludes emails that are moved into the monitored folder later,
        // because a moved email keeps its original (older) receivedDateTime.
        if RetrievedCount < MaxBatchSize() then
            MonitorSetup."Earliest Sync At" := CurrentDateTime;

        MonitorSetup.Modify();
    end;

    local procedure MaxBatchSize(): Integer
    begin
        exit(50);
    end;

    local procedure CallGraphRetrieve(var TempFilters: Record "Email Retrieve Filters" temporary): Integer
    begin
        exit(0);
    end;
}
