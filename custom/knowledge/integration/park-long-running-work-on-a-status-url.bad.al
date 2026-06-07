// Anti-pattern: a Job Queue tight loop that Sleep-polls the status URL, with the retry count in
// a local variable that resets on restart. The loop pins a Job Queue slot for the entire
// external wait, and the counter never survives long enough to drive real backoff or give-up.

codeunit 50202 "Long Running Bad"
{
    procedure Start(var IntegrationMessage: Record "Integration Message")
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Location: array[1] of Text;
        RetryCount: Integer; // BAD: lost on restart; this state belongs on the message row
    begin
        Client.Post('https://svc.contoso.com/api/jobs', BuildContent(IntegrationMessage), Response);
        Response.Headers().GetValues('Location', Location);

        // BAD: a tight Sleep-poll loop INSIDE the Job Queue handler. This single flow now holds a
        // Job Queue worker slot for the whole external wait. A flow that can take hours starves
        // every other job behind it, because the slot is occupied doing nothing but sleeping.
        repeat
            Sleep(5000);
            // BAD: RetryCount is a local. Every BC restart resets it to zero, so backoff and the
            // give-up threshold below never behave correctly across a restart: the loop effectively
            // starts over, having forgotten how long it has already been waiting.
            RetryCount += 1;
            Client.Get(Location[1], Response);
        until IsComplete(Response) or (RetryCount > 1000);

        // The flow lives only in this session. If BC recycles the session mid-wait, the work is
        // orphaned: nothing parked it, so nothing will ever resume it.
    end;
}
