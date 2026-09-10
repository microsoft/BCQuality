codeunit 50100 "Posting Date Helper"
{
    procedure GetDefaultPostingDate(): Date
    var
        PostingDate: Date;
    begin
        // Read the work date to default a value; never write to it.
        PostingDate := WorkDate();
        exit(PostingDate);
    end;
}
