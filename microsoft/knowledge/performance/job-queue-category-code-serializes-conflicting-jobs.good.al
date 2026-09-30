codeunit 50113 "Job Queue Category Good"
{
    procedure ConfigureJobsForSharedExclusiveResource(var SalesPostingJob: Record "Job Queue Entry"; var PurchasePostingJob: Record "Job Queue Entry"; ExclusiveResourceId: Text[250])
    var
        JobQueueCategory: Record "Job Queue Category";
    begin
        if not JobQueueCategory.Get('POSTING') then begin
            JobQueueCategory.Code := 'POSTING';
            JobQueueCategory.Insert();
        end;

        // The shared category lets only one conflicting posting job run at a time.
        SalesPostingJob.Validate("Parameter String", ExclusiveResourceId);
        PurchasePostingJob.Validate("Parameter String", ExclusiveResourceId);
        SalesPostingJob.Validate("Job Queue Category Code", 'POSTING');
        PurchasePostingJob.Validate("Job Queue Category Code", 'POSTING');
    end;
}