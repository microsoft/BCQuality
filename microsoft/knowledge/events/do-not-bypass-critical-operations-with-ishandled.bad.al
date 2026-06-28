// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50296 "Critical Op Bad Sample"
{
    procedure PostInvoice(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        // Anti-pattern: IsHandled wraps the entire posting. A subscriber can set
        // IsHandled := true and silently skip ledger-entry creation and the
        // status update, leaving imbalanced ledgers and orphaned documents.
        IsHandled := false;
        OnBeforePostInvoice(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        CreateCustomerLedgerEntry(SalesHeader);
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify(true);
    end;

    local procedure CreateCustomerLedgerEntry(var SalesHeader: Record "Sales Header")
    begin
        // Posts the customer ledger entry (critical; must never be skipped).
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvoice(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;
}
