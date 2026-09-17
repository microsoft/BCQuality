codeunit 50110 "Job Queue UI Bad"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        if not Confirm('Process the queued export now?') then
            exit;

        ProcessExport(Rec."Parameter String");
        Message('The queued export completed.');
    end;

    local procedure ProcessExport(ParameterString: Text)
    begin
    end;
}