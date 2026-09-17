codeunit 50101 "Sales Review Agent Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertSalesHeader(var Rec: Record "Sales Header")
    begin
        // Runs for every user session, not only the agent.
        Message('Keep going, agent.');
    end;
}
