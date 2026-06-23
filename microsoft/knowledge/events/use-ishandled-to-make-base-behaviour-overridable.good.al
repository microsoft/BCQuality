// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50220 "Shipping Charge Good Sample"
{
    procedure CalculateShippingCharge(OrderAmount: Decimal) Charge: Decimal
    var
        IsHandled: Boolean;
    begin
        // Give extensions a sanctioned seam to replace the calculation, then
        // skip the default logic when a subscriber has handled it.
        OnBeforeCalculateShippingCharge(OrderAmount, Charge, IsHandled);
        if IsHandled then
            exit(Charge);

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

codeunit 50221 "Shipping Charge Sub Good Sample"
{
    // A partner replaces the flat rate with a contract-specific rule.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shipping Charge Good Sample", 'OnBeforeCalculateShippingCharge', '', false, false)]
    local procedure ApplyContractRate(OrderAmount: Decimal; var Charge: Decimal; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        Charge := OrderAmount * 0.02;
        IsHandled := true;
    end;
}
