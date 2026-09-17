// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50241 "IsHandled Carry Over Bad Sample"
{
    procedure ApplyDiscounts(var SalesHeader: Record "Sales Header")
    var
        DiscountPct: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeApplyHeaderDiscount(SalesHeader, DiscountPct, IsHandled);
        if not IsHandled then
            DiscountPct := 5;

        // Bug: execution continues when the first event set IsHandled to true,
        // and that stale value is passed to a different publisher.
        OnBeforeApplyPaymentDiscount(SalesHeader, DiscountPct, IsHandled);
        if not IsHandled then
            DiscountPct += 2;
    end;

    procedure ApplyLineDiscounts(var SalesLine: Record "Sales Line")
    var
        LineIsHandled: Boolean;
    begin
        if SalesLine.FindSet() then
            repeat
                // Bug: the local initializes only once. A subscriber that handles
                // one line leaves true for every later iteration.
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
