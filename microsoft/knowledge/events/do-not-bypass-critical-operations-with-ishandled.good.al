// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50295 "Critical Op Good Sample"
{
    procedure PostInvoice(var SalesHeader: Record "Sales Header")
    var
        DiscountAmount: Decimal;
        IsHandled: Boolean;
    begin
        // IsHandled guards only a safe, side-effect-free calculation.
        IsHandled := false;
        OnBeforeCalculateInvoiceDiscount(SalesHeader, DiscountAmount, IsHandled);
        if not IsHandled then
            DiscountAmount := 10;
        SalesHeader."Invoice Discount Amount" := DiscountAmount;

        // Critical operations always run; no subscriber can bypass them.
        CreateCustomerLedgerEntry(SalesHeader);
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify(true);

        OnAfterPostInvoice(SalesHeader);
    end;

    local procedure CreateCustomerLedgerEntry(var SalesHeader: Record "Sales Header")
    begin
        // Posts the customer ledger entry (critical; must never be skipped).
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateInvoiceDiscount(var SalesHeader: Record "Sales Header"; var DiscountAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostInvoice(var SalesHeader: Record "Sales Header")
    begin
    end;
}
