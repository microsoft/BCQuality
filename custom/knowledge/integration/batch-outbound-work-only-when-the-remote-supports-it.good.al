// Best practice: send one bounded batch to a remote that returns per-item
// status, carry a per-item idempotency key inside the batch, and settle each
// Integration Message individually from its own result. A partial failure parks
// only the items that actually failed; a retry of the batch is safe because the
// items that already succeeded carry the same keys.

codeunit 50150 "WMS Batch Sender"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        IntegrationMessage: Record "Integration Message";
        BatchBuilder: Codeunit "WMS Batch Builder";
        BatchSize: Integer;
    begin
        // Size is tuned from telemetry, smaller for stages that lock. Not a constant.
        BatchSize := GetTunedBatchSize();

        IntegrationMessage.SetRange(Direction, IntegrationMessage.Direction::Outbound);
        IntegrationMessage.SetRange(Status, IntegrationMessage.Status::New);
        IntegrationMessage.SetRange(Type, 'wms-shipment');
        if IntegrationMessage.FindSet() then
            repeat
                // Each item carries its own Message ID as the idempotency key,
                // so re-sending the batch never double-processes a sent item.
                BatchBuilder.AddItem(IntegrationMessage."Message ID", IntegrationMessage);
            until (IntegrationMessage.Next() = 0) or (BatchBuilder.Count() >= BatchSize);

        // One call. The remote returns a result per item, keyed by Message ID.
        SendBatchAndSettleEachItem(BatchBuilder);
    end;

    local procedure SendBatchAndSettleEachItem(var BatchBuilder: Codeunit "WMS Batch Builder")
    begin
        // For each per-item result: set that one message Resolved or Failed.
        // A single bad item parks only itself; the rest move on.
    end;
}
