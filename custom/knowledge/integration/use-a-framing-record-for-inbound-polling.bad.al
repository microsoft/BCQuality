// Anti-pattern: no framing record, no watermark, no lock. Every run fetches the whole
// collection, and two overlapping Job Queue runs stage the same records twice.

codeunit 50132 "Inbound Poller Bad"
{
    TableNo = "Job Queue Entry";

    procedure Poll()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        // BAD: "fetch all". No last-fetch datetime feeds the request and no window cap bounds it,
        // so the cost of every poll grows with the TOTAL data set, not with what is new. Records
        // that were already staged and resolved are pulled again and reprocessed every run.
        Client.Get('https://svc.contoso.com/api/orders', Response);

        // BAD: no lock. The Job Queue can start the next run before this one finishes (a run that
        // overruns its recurrence interval overlaps the following one). Both runs fetch the full
        // collection concurrently and BOTH stage every order, so each order lands twice and becomes
        // a duplicate document downstream.
        StageAll(Response);

        // There is also no watermark to advance, so even back-to-back runs cannot narrow their
        // windows: there is no notion of "where we left off" anywhere in this design.
    end;
}
