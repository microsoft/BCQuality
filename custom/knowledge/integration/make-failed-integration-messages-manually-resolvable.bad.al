// Anti-pattern: failed messages are PURGED, and the only "retry" mints a NEW message. The
// payload and error context needed to diagnose the failure are destroyed, and the new id breaks
// idempotency so the receiver double-applies the side effect.

codeunit 50221 "Failed Cleanup Bad"
{
    procedure PurgeFailed()
    var
        IntegrationMessage: Record "Integration Message";
    begin
        // BAD: deleting failed rows means a fix needs a code change and a redeploy, because there
        // is no editable row for ops to correct and re-run. Every data-level failure becomes an
        // engineering incident. Worse, the payload and the error that explain WHAT failed are gone,
        // so diagnosis after the fact is impossible.
        IntegrationMessage.SetRange(Status, IntegrationMessage.Status::Failed);
        IntegrationMessage.DeleteAll(true);
    end;

    procedure RetryFailed(SourceRef: Text[100]; MsgType: Code[40]; Payload: Text)
    var
        NewMessage: Record "Integration Message";
    begin
        // BAD: a manual retry that creates a BRAND-NEW message with a fresh Message ID. The
        // idempotency key is derived from the Message ID, so a new id means a new key, and the
        // receiver sees this as a new request rather than a repeat of the failed one. If the
        // original attempt had partly landed (a charge captured, a shipment booked), this retry
        // applies the side effect a SECOND time. The correct fix is to re-run the EXISTING message.
        NewMessage.Init();
        NewMessage."Message ID" := CreateGuid();
        NewMessage."External Reference" := SourceRef;
        NewMessage.Type := MsgType;
        NewMessage.Status := NewMessage.Status::New;
        NewMessage.SetRequest(Payload);
        NewMessage.Insert(true);
    end;
}
