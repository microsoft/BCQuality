// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50240 "IsHandled Carry Over Good Sample"
{
    procedure ApplyDiscounts(var SalesHeader: Record "Sales Header")
    var
        DiscountPct: Decimal;
        HeaderIsHandled: Boolean;
        PaymentIsHandled: Boolean;
    begin
        // Each fresh local is false and belongs to one non-looping raise.
        OnBeforeApplyHeaderDiscount(SalesHeader, DiscountPct, HeaderIsHandled);
        if not HeaderIsHandled then
            DiscountPct := 5;

        // Handling the header event does not suppress this independent seam.
        OnBeforeApplyPaymentDiscount(SalesHeader, DiscountPct, PaymentIsHandled);
        if not PaymentIsHandled then
            DiscountPct += 2;
    end;

    procedure ApplyLineDiscounts(var SalesLine: Record "Sales Line")
    var
        LineIsHandled: Boolean;
    begin
        if SalesLine.FindSet() then
            repeat
                // The local initializes once, so reset it per iteration; a
                // subscriber that handles one line must not skip the rest.
                LineIsHandled := false;
                OnBeforeApplyLineDiscount(SalesLine, LineIsHandled);
                if not LineIsHandled then
                    SalesLine.Validate("Line Discount %", 5);
            until SalesLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyHeaderDiscount(var SalesHeader: Record "Sales Header"; var DiscountPct: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyPaymentDiscount(var SalesHeader: Record "Sales Header"; var DiscountPct: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyLineDiscount(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;
}
