codeunit 51205 "Perf Sample LockTable Bad"
{
    procedure GetOrCreate(var AgentStatus: Record "Integer"): Boolean
    begin
        // Every caller takes an exclusive lock, even the ones that only read.
        // Under load the helper becomes the dominant contention point.
        AgentStatus.LockTable();
        if not AgentStatus.Get(1) then begin
            AgentStatus.Number := 1;
            AgentStatus.Insert();
        end;
        exit(true);
    end;
}
