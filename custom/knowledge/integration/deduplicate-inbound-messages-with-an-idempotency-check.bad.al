// Anti-pattern: insert on every call with no idempotency check, keyed on a brand-new GUID.
// A retried or re-fetched delivery is processed again as a fresh message, so a duplicating
// source produces duplicate documents and double-applied side effects.

codeunit 50142 "Inbound Dedup Bad"
{
    procedure Stage(ExternalRef: Text[100]; MsgType: Code[40]; Payload: Text): Guid
    var
        IntegrationMessage: Record "Integration Message";
    begin
        // BAD: no SetRange on External Reference + Type, no Get, no lookup of any kind.
        // The source system's stable id is captured on the row but never used to detect a repeat.
        IntegrationMessage.Init();

        // BAD: the only "identity" is a fresh GUID. If anyone later "dedups" on Message ID,
        // it can never match, because every insert mints a new one. This is the illusion of a
        // dedup key that can never actually fire.
        IntegrationMessage."Message ID" := CreateGuid();

        IntegrationMessage.Direction := IntegrationMessage.Direction::Inbound;
        IntegrationMessage."External Reference" := ExternalRef;
        IntegrationMessage.Type := MsgType;
        IntegrationMessage.Status := IntegrationMessage.Status::New;
        IntegrationMessage.SetRequest(Payload);

        // When the source RETRIES (a webhook that did not see our ack, a restart re-send, an
        // overlapping poll window): this runs again with the same ExternalRef and stages a
        // second message. Downstream it becomes a second sales order and a second posting.
        // The duplicate volume scales with how aggressively the source retries.
        IntegrationMessage.Insert(true);
        exit(IntegrationMessage."Message ID");
    end;
}
