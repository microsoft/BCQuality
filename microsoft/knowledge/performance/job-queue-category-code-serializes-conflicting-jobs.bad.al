codeunit 50113 "Job Queue Category Bad"
{
    procedure ConfigureJobsForSharedExclusiveResource(var SalesPostingJob: Record "Job Queue Entry"; var PurchasePostingJob: Record "Job Queue Entry"; ExclusiveResourceId: Text[250])
    begin
        // Both jobs update the same posting resources, but nothing prevents overlap.
        SalesPostingJob.Validate("Parameter String", ExclusiveResourceId);
        PurchasePostingJob.Validate("Parameter String", ExclusiveResourceId);
        SalesPostingJob.Validate("Job Queue Category Code", '');
        PurchasePostingJob.Validate("Job Queue Category Code", '');
    end;
}