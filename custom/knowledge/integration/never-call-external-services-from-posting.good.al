// Best practice: the posting subscriber only STAGES an outbound message and returns.
// The HttpClient.Send happens later, in a Job Queue codeunit, outside the posting lock.
// The row is inserted inside the posting transaction, so it exists only if the post
// committed; the callout runs in a separate transaction where a remote outage can only
// delay delivery, never roll back a posted shipment.

codeunit 50110 "Post Shipment Notifier"
{
    // Subscriber on the real posting publisher. It runs while posting locks are held,
    // so it must do nothing that can block: no HTTP, no second remote call, just an Insert.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure StageShipmentNotification(var SalesHeader: Record "Sales Header")
    var
        IntegrationMessage: Record "Integration Message";
    begin
        // Only notify on an actual posted shipment, not on every posted document kind.
        if not SalesHeader.Ship then
            exit;

        IntegrationMessage.Init();
        IntegrationMessage."Message ID" := CreateGuid();
        // Direction Outbound + Status New is exactly what the Job Queue processor queries for.
        IntegrationMessage.Direction := IntegrationMessage.Direction::Outbound;
        IntegrationMessage.Status := IntegrationMessage.Status::New;
        IntegrationMessage.Type := 'SHIPMENT-NOTIFY';
        // Carry the document ANCHOR, not a live handle. The processor re-reads detail later.
        IntegrationMessage."Document No." := SalesHeader."No.";
        IntegrationMessage."External Reference" := SalesHeader."External Document No.";
        // Correlation id threads this notification to the rest of the flow's log lines.
        IntegrationMessage."Correlation ID" := CopyStr(DelChr(LowerCase(Format(CreateGuid())), '=', '{}'), 1, 40);
        // Insert participates in the posting transaction: the row lives only if the post commits,
        // and rolls back cleanly with the post if posting fails. No remote system is touched here.
        IntegrationMessage.Insert(true);
    end;
}

codeunit 50111 "Outbound Sender"
{
    // Runs as a Job Queue entry, well after posting has committed and released its locks.
    // Nothing it does can lengthen a posting lock window, because there is no longer a post in flight.
    procedure SendNew()
    var
        IntegrationMessage: Record "Integration Message";
    begin
        IntegrationMessage.SetRange(Direction, IntegrationMessage.Direction::Outbound);
        IntegrationMessage.SetRange(Status, IntegrationMessage.Status::New);
        if IntegrationMessage.FindSet() then
            repeat
                // Each row is its own short unit of work. A slow endpoint stalls delivery
                // of THIS message only; it cannot stall anyone's posting.
                SendOne(IntegrationMessage);
            until IntegrationMessage.Next() = 0;
    end;

    local procedure SendOne(var IntegrationMessage: Record "Integration Message")
    var
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
    begin
        Content.WriteFrom(BuildShipmentJson(IntegrationMessage));
        if Client.Post(GetEndpoint(IntegrationMessage), Content, Response) and Response.IsSuccessStatusCode() then begin
            IntegrationMessage.Status := IntegrationMessage.Status::Resolved;
            IntegrationMessage.Modify(true);
        end else begin
            // A failure here is recorded on the row and retried later. The posted shipment
            // is already durable, so a WMS outage never costs us the posting.
            IntegrationMessage."Retry Count" += 1;
            IntegrationMessage."Error Message" := CopyStr(GetLastErrorText(), 1, 2048);
            IntegrationMessage.Modify(true);
        end;
    end;
}
