// Anti-pattern: a hand-written HTTP retry loop for a fire-and-forget notification. It
// reimplements platform retry, backoff, and durability (usually less correctly), couples
// delivery to BC staying up for the life of the loop, and runs inline on the caller's thread.

codeunit 50162 "Shipment Notifier Bad"
{
    procedure NotifyShipmentReleased(DocumentNo: Code[20])
    var
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Attempt: Integer;
    begin
        Content.WriteFrom(BuildJson(DocumentNo));

        // BAD: a hand-rolled retry loop for a one-way notification an external business event
        // would carry. Everything in this loop is something the platform already does for free.
        for Attempt := 1 to 5 do begin
            if Client.Post('https://wms.contoso.com/api/events', Content, Response) then
                // BAD: status classification by hand. A real implementation must distinguish
                // 408/429/5xx (retry) from 4xx (give up), and this one does not even try.
                if Response.IsSuccessStatusCode() then
                    exit;

            // BAD: hand-rolled backoff. The platform's external-event delivery already retries
            // with backoff for up to ~36 hours and persists the state across restarts.
            Sleep(Attempt * 2000);
        end;

        // BAD: the loop lives entirely in this session. If the WMS is DOWN for the whole window
        // the notification is lost; and if BC RESTARTS mid-loop, the retry state is gone and the
        // notification is silently lost with no record that it was ever attempted. Nobody is
        // alerted, so the gap is found only when downstream is discovered to be out of sync.
    end;
}
