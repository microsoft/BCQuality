codeunit 50100 "Event Audit Buffer"
{
    SingleInstance = true;

    var
        RecentEventIds: List of [Guid];
        MaxBuffered: Integer;

    trigger OnRun()
    begin
        MaxBuffered := 50;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertSalesHeader(var Rec: Record "Sales Header")
    begin
        // Bounded cache: drop the oldest entry when the cap is reached.
        RecentEventIds.Add(Rec.SystemId);
        if RecentEventIds.Count() > MaxBuffered then
            RecentEventIds.RemoveAt(1);
    end;

    procedure ResetAtBusinessProcessBoundary()
    begin
        // Explicit reset point at a natural boundary in the workflow.
        Clear(RecentEventIds);
    end;
}
