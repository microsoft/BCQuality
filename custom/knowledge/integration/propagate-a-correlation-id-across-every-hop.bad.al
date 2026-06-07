// Anti-pattern: a new id minted at a downstream hop, and an outbound call with no correlation
// header. Nothing ties the inbound message, this processing step, and the external system's
// logs together. Tracing a failure becomes correlation-by-timestamp guesswork.

codeunit 50192 "Outbound Step Bad"
{
    procedure Send(var IntegrationMessage: Record "Integration Message")
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        LocalTrace: Guid;
    begin
        // BAD: a brand-new id, unrelated to IntegrationMessage."Correlation ID". The entry point
        // already minted the flow's trace id; minting another one here breaks the chain just as
        // thoroughly as having none, because the two halves now log different identifiers.
        LocalTrace := CreateGuid();

        // This trace value appears in no other component's logs, so it joins to nothing.
        LogStep('sending', Format(LocalTrace));

        Request.SetRequestUri('https://svc.contoso.com/api/orders');
        Request.Method := 'POST';
        Request.GetHeaders(Headers);

        // BAD: no Correlation-Id header at all. The receiver logs the call under its own ids, and
        // there is no shared value to join the external system's logs back to this flow. When this
        // POST fails three hops into a busy system, reconstructing what happened is archaeology.
        Client.Send(Request, Response);
    end;
}
