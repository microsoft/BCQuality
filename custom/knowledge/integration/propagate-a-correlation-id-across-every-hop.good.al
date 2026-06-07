// Best practice: mint the correlation id ONCE at the entry point and carry it unchanged on
// every staged message, event payload, queue header, and outbound call. Log it at every step,
// so one filter pulls the entire flow across BC, the queue, and the external system.

codeunit 50190 "Inbound Entry"
{
    // The boundary: this is the ONLY place a correlation value is created. Everything downstream
    // reads it, never regenerates it.
    procedure Receive(Payload: Text)
    var
        IntegrationMessage: Record "Integration Message";
    begin
        IntegrationMessage.Init();
        IntegrationMessage."Message ID" := CreateGuid();
        // Generated once, here, at the entry point. This is the trace id for the whole flow.
        IntegrationMessage."Correlation ID" := NewCorrelationId();
        IntegrationMessage.SetRequest(Payload);
        IntegrationMessage.Insert(true);

        // Log it on the very first step, so even the inbound receipt is part of the trace.
        LogStep('received', IntegrationMessage."Correlation ID");
    end;

    local procedure NewCorrelationId(): Code[40]
    begin
        exit(CopyStr(DelChr(LowerCase(Format(CreateGuid())), '=', '{}'), 1, 40));
    end;
}

codeunit 50191 "Outbound Step"
{
    // A downstream hop. It READS the correlation id off the message it was handed; it does not
    // mint a new one, because that would split the flow into two untraceable halves.
    procedure Send(var IntegrationMessage: Record "Integration Message")
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
    begin
        Request.SetRequestUri('https://svc.contoso.com/api/orders');
        Request.Method := 'POST';
        Request.GetHeaders(Headers);

        // Carry the SAME id onto the outbound call as a header. The receiver logs it too, so the
        // external system's logs can be joined back to the BC side by this one value.
        Headers.Add('Correlation-Id', IntegrationMessage."Correlation ID");

        Client.Send(Request, Response);
        // Same id logged on this hop. Request and confirmation rows share it, so a status query
        // or failure investigation pulls the whole chain with a single filter.
        LogStep('sent', IntegrationMessage."Correlation ID");
    end;
}
