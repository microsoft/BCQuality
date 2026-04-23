codeunit 51204 "Perf Sample LockTable Good"
{
    procedure GetOrCreate(var AgentStatus: Record "Integer"): Boolean
    begin
        // Read path: no lock.
        if AgentStatus.Get(1) then
            exit(true);

        // Write path: lock only when we are about to insert.
        AgentStatus.LockTable();
        if not AgentStatus.Get(1) then begin
            AgentStatus.Number := 1;
            AgentStatus.Insert();
        end;
        exit(true);
    end;
}
