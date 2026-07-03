codeunit 50100 "Stale Quote Cleanup"
{
    procedure ClearExpiredQuotes(CutoffDate: Date)
    var
        SalesHeader: Record "Sales Header";
    begin
        // OnDelete on Sales Header carries no logic this call depends on:
        // expired quotes have no ledger entries, shipments, or downstream state.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetFilter("Document Date", '<%1', CutoffDate);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        // Single SQL DELETE. Orders of magnitude faster than FindSet + Delete
        // once the filtered set exceeds a handful of rows.
        SalesHeader.DeleteAll();
    end;
}
