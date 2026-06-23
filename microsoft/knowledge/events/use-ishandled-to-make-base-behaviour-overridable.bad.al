// Demonstration-only AL. Not compiled by CI; illustrates the article.

// Anti-pattern 1: no OnBefore/IsHandled hook. A partner cannot replace this
// rule without overwriting base code, so the behaviour is not extensible.
codeunit 50222 "Shipping Charge NoHook Bad"
{
    procedure CalculateShippingCharge(OrderAmount: Decimal) Charge: Decimal
    begin
        if OrderAmount >= 1000 then
            Charge := 0
        else
            Charge := 49;
    end;
}

// Anti-pattern 2: the hook exists but the 'if IsHandled then exit;' guard is
// missing, so the default logic still runs after a subscriber handled the call.
codeunit 50223 "Shipping Charge Guard Bad"
{
    procedure CalculateShippingCharge(OrderAmount: Decimal) Charge: Decimal
    var
        IsHandled: Boolean;
    begin
        OnBeforeCalculateShippingCharge(OrderAmount, Charge, IsHandled);

        // Bug: no 'if IsHandled then exit;' here. Even when a subscriber set
        // Charge and IsHandled := true, the default below overwrites the result.
        if OrderAmount >= 1000 then
            Charge := 0
        else
            Charge := 49;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateShippingCharge(OrderAmount: Decimal; var Charge: Decimal; var IsHandled: Boolean)
    begin
    end;
}
