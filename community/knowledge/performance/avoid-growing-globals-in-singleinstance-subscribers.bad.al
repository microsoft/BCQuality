codeunit 50100 "Event Audit Buffer"
{
    SingleInstance = true;

    // Unbounded global: every event fires adds an entry for the lifetime of the session.
    var
        AllEventIds: List of [Guid];

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertSalesHeader(var Rec: Record "Sales Header")
    begin
        // No cap. No eviction. No reset. A session that sees ten thousand inserts
        // keeps ten thousand GUIDs in memory until the user signs out.
        AllEventIds.Add(Rec.SystemId);
    end;
}
