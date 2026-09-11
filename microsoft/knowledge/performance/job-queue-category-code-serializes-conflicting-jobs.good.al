codeunit 50113 "Job Queue Category Good"
{
    procedure ConfigurePostingJobs(var PostSales: Record "Job Queue Entry"; var PostPurchases: Record "Job Queue Entry")
    var
        JobQueueCategory: Record "Job Queue Category";
    begin
        if not JobQueueCategory.Get('POSTING') then begin
            JobQueueCategory.Code := 'POSTING';
            JobQueueCategory.Insert();
        end;

        // The shared category lets only one conflicting posting job run at a time.
        PostSales.Validate("Job Queue Category Code", 'POSTING');
        PostPurchases.Validate("Job Queue Category Code", 'POSTING');
    end;
}