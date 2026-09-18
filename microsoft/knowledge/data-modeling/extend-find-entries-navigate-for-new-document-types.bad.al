codeunit 50103 "Sample Navigate Subscribers"
{
    // WRONG: registers the row, so it appears in the Find Entries result
    // list with a correct table name and record count - but there is no
    // OnBeforeShowRecords subscriber for this table. ShowRecords()'s own
    // case statement has no branch and no else for it either, so
    // selecting this row and choosing "Show records" does nothing,
    // silently, with no error.
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterFindRecords', '', false, false)]
    local procedure OnAfterFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        SampleDocHeader: Record "Sample Posted Document Header";
    begin
        SampleDocHeader.SetFilter("No.", DocNoFilter);
        SampleDocHeader.SetFilter("Posting Date", PostingDateFilter);
        DocumentEntry.InsertIntoDocEntry(
            Database::"Sample Posted Document Header", SampleDocHeader.TableCaption(), SampleDocHeader.Count());
    end;
}
