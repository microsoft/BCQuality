codeunit 50110 "Job Queue UI Good"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Rec.TestField("Parameter String");
        ProcessExport(Rec."Parameter String");
    end;

    local procedure ProcessExport(ParameterString: Text)
    begin
    end;
}