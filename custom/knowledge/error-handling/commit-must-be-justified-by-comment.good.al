codeunit 50120 "Sample Commit Justified"
{
    procedure CreateDraftAndReview(var SampleDraft: Record "Sample Draft")
    begin
        SampleDraft.Insert(true);
        SampleDraft.CalcFields("Line Count");

        // Commit required: Page.RunModal below cannot run while this write
        // transaction is open. Removing the Commit breaks the review step.
        // If later processing fails, the inserted draft remains saved.
        // This is intentional: the draft is a complete, valid record and
        // does not depend on the review or subsequent processing to exist.
        Commit();

        Page.RunModal(Page::"Sample Draft Review", SampleDraft);
        ProcessReviewedDraft(SampleDraft);
    end;

    local procedure ProcessReviewedDraft(var SampleDraft: Record "Sample Draft")
    begin
        // Further processing may fail after the draft has been committed.
    end;
}
