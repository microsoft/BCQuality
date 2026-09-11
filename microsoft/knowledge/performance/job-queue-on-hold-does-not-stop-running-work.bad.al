codeunit 50114 "Job Queue On Hold Bad"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        repeat
            if not ProcessNextBatch() then
                exit;
            Rec.Get(Rec.ID);
        until Rec.Status = Rec.Status::"On Hold";
    end;

    local procedure ProcessNextBatch(): Boolean
    begin
        exit(false);
    end;
}