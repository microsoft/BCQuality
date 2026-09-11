codeunit 50113 "Job Queue Category Bad"
{
    procedure ConfigurePostingJobs(var PostSales: Record "Job Queue Entry"; var PostPurchases: Record "Job Queue Entry")
    begin
        // Both jobs update the same posting resources, but nothing prevents overlap.
        PostSales.Validate("Job Queue Category Code", '');
        PostPurchases.Validate("Job Queue Category Code", '');
    end;
}