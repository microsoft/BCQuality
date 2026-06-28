// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50241 "IsHandled Init Bad Sample"
{
    procedure ApplyDiscounts(var SalesHeader: Record "Sales Header")
    var
        DiscountPct: Decimal;
        IsHandled: Boolean;
    begin
        // IsHandled is never initialized before the first raise, so flow depends
        // on the variable's default rather than an explicit, documented intent.
        OnBeforeApplyHeaderDiscount(SalesHeader, DiscountPct, IsHandled);
        if not IsHandled then
            DiscountPct := 5;

        // Bug: IsHandled is not reset. If the first subscriber set it true, the
        // payment-discount default below is silently skipped too.
        OnBeforeApplyPaymentDiscount(SalesHeader, DiscountPct, IsHandled);
        if not IsHandled then
            DiscountPct += 2;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyHeaderDiscount(var SalesHeader: Record "Sales Header"; var DiscountPct: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyPaymentDiscount(var SalesHeader: Record "Sales Header"; var DiscountPct: Decimal; var IsHandled: Boolean)
    begin
    end;
}
