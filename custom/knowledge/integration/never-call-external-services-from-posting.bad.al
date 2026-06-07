// Anti-pattern: the posting subscriber calls an external service INLINE, inside the
// posting transaction. The post now holds document and ledger locks until the remote
// endpoint answers, and a remote failure rolls the whole post back.

codeunit 50112 "Post Shipment Notifier Bad"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure NotifyShipmentInline(var SalesHeader: Record "Sales Header")
    var
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
    begin
        Content.WriteFrom(BuildShipmentJson(SalesHeader));

        // BAD: HttpClient.Post runs INSIDE the posting transaction. The locks taken by
        // Sales-Post on the header, the lines, and the related ledger entries stay held
        // for the entire round trip to the WMS.
        //
        // When the WMS is SLOW: every other user posting a sales document queues behind
        // these locks. One slow endpoint serialises the whole team's posting.
        //
        // When the WMS is DOWN: this call blocks until the HTTP timeout fires, then throws.
        // The throw propagates out of the posting transaction and the entire post ROLLS BACK.
        // The shipment physically left the warehouse, but there is now no posted document
        // and nothing was staged, so there is nothing to retry and nothing to inspect.
        Client.Post('https://wms.contoso.com/api/shipments', Content, Response);

        // Even on a success that is not actually success: a network blip after the WMS
        // committed but before BC saw the response leaves the two systems disagreeing,
        // with no staged row recording that the notification was attempted.
    end;
}
