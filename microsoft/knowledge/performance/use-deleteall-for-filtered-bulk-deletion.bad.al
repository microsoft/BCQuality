codeunit 50100 "Stale Quote Cleanup"
{
    procedure ClearExpiredQuotes(CutoffDate: Date)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetFilter("Document Date", '<%1', CutoffDate);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        // One SQL DELETE per row. On a 10k-row cleanup, minutes instead of
        // under a second - and the OnDelete trigger has no logic this call
        // needs to run.
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Delete();
            until SalesHeader.Next() = 0;
    end;
}
