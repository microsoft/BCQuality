// Anti-pattern: "batching" by chaining single calls in one Job Queue run, and
// a real batch with no per-item status. Both strand work on one failure.

codeunit 50150 "WMS Sender (bad)"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        IntegrationMessage: Record "Integration Message";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
    begin
        IntegrationMessage.SetRange(Status, IntegrationMessage.Status::New);
        if IntegrationMessage.FindSet() then
            repeat
                // BAD: fifty serial round trips inside one task. This is a wait
                // loop with extra steps: one task and its locks are pinned for the
                // whole sequence, and a slow remote slows every other queued job.
                BuildRequest(IntegrationMessage, Request);
                Client.Send(Request, Response);
            until IntegrationMessage.Next() = 0;
    end;

    // BAD alternative: a genuine batch POST whose response is a single status.
    procedure SendBlindBatch(var Request: HttpRequestMessage; Items: List of [Guid])
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        IntegrationMessage: Record "Integration Message";
        Id: Guid;
    begin
        Client.Send(Request, Response);
        // BAD: one IsSuccessStatusCode for the whole batch. One invalid item
        // fails all fifty, and we cannot tell which item to fix or retry. A retry
        // re-sends the items that already succeeded.
        foreach Id in Items do begin
            IntegrationMessage.Get(Id);
            if Response.IsSuccessStatusCode() then
                IntegrationMessage.Status := IntegrationMessage.Status::Resolved
            else
                IntegrationMessage.Status := IntegrationMessage.Status::Failed;
            IntegrationMessage.Modify(true);
        end;
    end;
}
