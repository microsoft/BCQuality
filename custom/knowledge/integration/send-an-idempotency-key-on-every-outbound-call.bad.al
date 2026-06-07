// Anti-pattern: a fresh key per attempt (and the loop would be just as broken with no key).
// Every retry looks like a brand-new request, so after an uncertain failure the receiver
// applies the side effect AGAIN. A flaky payment service produces duplicate charges exactly
// when it is least healthy.

codeunit 50151 "Outbound Caller Bad"
{
    procedure Send(var IntegrationMessage: Record "Integration Message")
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        Attempt: Integer;
    begin
        for Attempt := 1 to 3 do begin
            Content.WriteFrom(IntegrationMessage.GetRequest());
            Request.Content := Content;
            Request.Method := 'POST';
            Request.SetRequestUri('https://pay.contoso.com/api/charges');
            Request.GetHeaders(Headers);

            // BAD: a new GUID on every attempt. The key is supposed to let the receiver
            // recognise a retry, but a value that changes each time is functionally NO key:
            // attempt 2 and attempt 3 each look like a completely new charge request.
            Headers.Add('Idempotency-Key', Format(CreateGuid()));

            // The dangerous case is the UNCERTAIN failure. If attempt 1 actually reached the
            // service and captured the payment, but the response was lost to a timeout, then
            // Send returns false here and the loop retries. Attempt 2 carries a different key,
            // so the service captures the payment a SECOND time. The customer is charged twice.
            if Client.Send(Request, Response) and Response.IsSuccessStatusCode() then
                exit;
        end;
    end;
}
