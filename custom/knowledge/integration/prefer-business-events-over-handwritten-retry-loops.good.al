// Best practice: declare an external business event and fire it from a thin subscriber.
// The platform owns retry (408/429/5xx, up to ~36h) and backoff; delivery is asynchronous
// and post-commit, so the notification is sent only if the firing transaction commits.

codeunit 50160 "Shipment Events v1"
{
    // [ExternalBusinessEvent], not [BusinessEvent]: the externally deliverable flavour that
    // external subscribers can register against. Parameters are a minimal DTO of identifiers,
    // never the BC record (see version-business-events-and-keep-payloads-stable).
    [ExternalBusinessEvent('ShipmentReleased', 'Shipment released', 'Raised when a warehouse shipment is posted', EventCategory::Sales)]
    procedure OnShipmentReleased_v1(DocumentNo: Code[20]; ExternalRef: Text[100])
    begin
        // Body is intentionally empty: the platform raises and delivers this; we only declare it.
    end;
}

codeunit 50161 "Shipment Event Firer"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnAfterPostWhseShipment', '', false, false)]
    local procedure FireShipmentReleased(var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        Events: Codeunit "Shipment Events v1";
    begin
        // Safe to fire from the posting path, even though an HttpClient.Send here would NOT be:
        //  - this is not an HTTP call, so it holds no lock open on a remote round trip;
        //  - the platform queues delivery and sends it only AFTER this transaction commits;
        //  - if posting rolls back, the event is never sent, so nothing leaks on failure.
        Events.OnShipmentReleased_v1(WhseShptHeader."No.", WhseShptHeader."External Document No.");
    end;
}

// External subscribers register themselves with no AL change, by POSTing to
//   api/microsoft/runtime/v1.0/externaleventsubscriptions
// with eventName, appId, notificationUrl and clientState. Adding a consumer is configuration,
// not code. (External business events are available from runtime 11 and still preview; confirm
// the surface against current docs before relying on it.)
