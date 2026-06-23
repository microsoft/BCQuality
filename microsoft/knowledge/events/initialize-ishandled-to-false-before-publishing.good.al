// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50240 "IsHandled Init Good Sample"
{
    procedure ApplyDiscounts(var SalesHeader: Record "Sales Header")
    var
        DiscountPct: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeApplyHeaderDiscount(SalesHeader, DiscountPct, IsHandled);
        if not IsHandled then
            DiscountPct := 5;

        // Reset before reusing the same variable for the next event so a
        // subscriber that handled the first raise can't suppress this one.
        IsHandled := false;
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
