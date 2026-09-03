codeunit 50113 "Job Queue Category Good"
{
    procedure ConfigurePostingJobs(var PostSales: Record "Job Queue Entry"; var PostPurchases: Record "Job Queue Entry")
    begin
        // The shared category lets only one conflicting posting job run at a time.
        PostSales.Validate("Job Queue Category Code", 'POSTING');
        PostPurchases.Validate("Job Queue Category Code", 'POSTING');
    end;
}