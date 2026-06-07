// Anti-pattern: the inbound handler BLOCKS the request thread, Sleep-polling an external
// service until it completes. The caller's connection is held open for the whole wait,
// and concurrent requests pile up on pinned threads.

codeunit 50123 "Inbound Intake Bad"
{
    // Called on the request path. It does not return until the remote work is done,
    // so its runtime is entirely dictated by a system BC does not control.
    procedure Accept(Payload: Text): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JobId: Text;
        Done: Boolean;
    begin
        JobId := StartRemoteJob(Client, Payload);

        // BAD: Sleep inside a loop on the request thread. This single request now holds
        // its thread and session slot for the full duration of the remote job.
        repeat
            // When the downstream is SLOW: this blocks for seconds or minutes. The caller's
            // HTTP connection times out long before the loop ends, and the work it kicked
            // off is orphaned with no staged row recording it.
            Sleep(2000);

            // When the downstream is DOWN: this Get blocks until its own timeout, every
            // iteration, making a slow failure even slower.
            Client.Get(StrSubstNo('https://svc.contoso.com/jobs/%1', JobId), Response);
            Done := IsComplete(Response);
        until Done;

        // Under load: each in-flight request pins a thread here. A handful of slow calls
        // exhaust the request slots and BC starts rejecting healthy callers too. One slow
        // dependency becomes a site-wide outage.
        exit('completed'); // by now the original caller has almost certainly timed out
    end;
}
