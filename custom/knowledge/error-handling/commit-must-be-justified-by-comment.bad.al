codeunit 50121 "Sample Commit Unjustified"
{
    // Expected finding (major): the Commit below has no comment above it.
    procedure PostAndReview(var SampleHeader: Record "Sample Header")
    begin
        SampleHeader.Modify(true);
        CreateLines(SampleHeader);
        Commit();

        Page.RunModal(Page::"Sample Review", SampleHeader);
        UpdateRelatedEntries(SampleHeader);
    end;

    // Expected finding (minor): the comment above the Commit gives a reason but
    // does not say what remains in the database if a later step fails.
    procedure PostAndReviewAgain(var SampleHeader: Record "Sample Header")
    begin
        SampleHeader.Modify(true);
        CreateLines(SampleHeader);

        // Commit required before Page.RunModal because the current
        // write transaction must be closed for the modal review page.
        Commit();

        Page.RunModal(Page::"Sample Review", SampleHeader);
        UpdateRelatedEntries(SampleHeader);
    end;

    local procedure CreateLines(var SampleHeader: Record "Sample Header")
    begin
    end;

    local procedure UpdateRelatedEntries(var SampleHeader: Record "Sample Header")
    begin
    end;
}
