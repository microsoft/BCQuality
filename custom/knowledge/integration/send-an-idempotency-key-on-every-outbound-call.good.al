// Best practice: every outbound call carries Idempotency-Key = the Integration Message GUID.
// The key is created once when the message is staged and never changes, so the first call
// and every retry (Job Queue or operator-driven) send the SAME key. A well-behaved receiver
// collapses them into a single side effect and returns the original response.

codeunit 50150 "Outbound Caller"
{
    procedure Send(var IntegrationMessage: Record "Integration Message")
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
    begin
        Content.WriteFrom(IntegrationMessage.GetRequest());

        // Content-Type belongs on the content headers, not the request headers.
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.Content := Content;
        Request.Method := 'POST';
        Request.SetRequestUri('https://pay.contoso.com/api/charges');
        Request.GetHeaders(RequestHeaders);

        // THE key line. The value is the staged Message ID, which is stable for the life of
        // the message. Calling Send again for the same row sends this exact same value, so the
        // payment service sees the retry as a repeat of one charge and captures money once.
        RequestHeaders.Add('Idempotency-Key', StableKey(IntegrationMessage));

        // After an UNCERTAIN failure (timeout, dropped connection, 502) the Job Queue will
        // re-run this message. Because the key is unchanged, the retry is safe: no double charge.
        Client.Send(Request, Response);
        IntegrationMessage.RecordResult(Response);
    end;

    // The key is derived purely from the durable message id. Nothing here changes between
    // attempts: no CreateGuid, no timestamp, no attempt counter.
    local procedure StableKey(IntegrationMessage: Record "Integration Message"): Text
    begin
        exit(DelChr(LowerCase(Format(IntegrationMessage."Message ID")), '=', '{}'));
    end;
}
