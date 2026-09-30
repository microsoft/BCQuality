table 50104 "Sample Posted Document Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { Caption = 'No.'; }
        field(2; "Posting Date"; Date) { Caption = 'Posting Date'; }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

page 50104 "Sample Posted Document"
{
    PageType = Card;
    SourceTable = "Sample Posted Document Header";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field("No."; Rec."No.") { ApplicationArea = All; }
            field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
        }
    }
}

codeunit 50103 "Sample Navigate Subscribers"
{
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

    // Without this second subscriber, the row added above shows up in the
    // Find Entries result list with a correct count, but "Show records"
    // has nothing to open it with - see the .bad.al sample.
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeShowRecords', '', false, false)]
    local procedure OnBeforeShowRecords(var TempDocumentEntry: Record "Document Entry" temporary; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; ContactNo: Code[250]; ExtDocNo: Code[250]; var IsHandled: Boolean)
    var
        SampleDocHeader: Record "Sample Posted Document Header";
    begin
        if TempDocumentEntry."Table ID" <> Database::"Sample Posted Document Header" then
            exit;

        SampleDocHeader.SetFilter("No.", DocNoFilter);
        SampleDocHeader.SetFilter("Posting Date", PostingDateFilter);
        if TempDocumentEntry."No. of Records" = 1 then begin
            SampleDocHeader.FindFirst();
            Page.Run(Page::"Sample Posted Document", SampleDocHeader);
        end else
            Page.Run(0, SampleDocHeader);

        IsHandled := true;
    end;
}
