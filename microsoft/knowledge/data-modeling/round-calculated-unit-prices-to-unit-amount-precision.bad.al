// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50650 "Sample Own Sales Price Bad"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnUpdateUnitPriceOnBeforeFindPrice', '', false, false)]
    local procedure SetOwnUnitPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean; xSalesLine: Record "Sales Line")
    var
        Item: Record Item;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        PriceLCY: Decimal;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        // Scope: prices excluding VAT only. On a Prices Including VAT document, leave the price
        // to the standard calculation, which converts to the VAT basis before it rounds.
        if SalesHeader."Prices Including VAT" then
            exit;
        Item.Get(SalesLine."No.");
        PriceLCY := Item."Unit Cost" * SalesLine."Qty. per Unit of Measure" * GetMarkupFactor(SalesHeader."Sell-to Customer No.");

        // Markup and currency conversion leave more decimals than the currency's unit-amount
        // precision. IsHandled skips the standard calculation and its RoundPrice, so the price
        // is stored unrounded and Quantity x the displayed price no longer equals Line Amount.
        SalesLine."Unit Price" :=
            CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                SalesHeader."Posting Date", SalesHeader."Currency Code", PriceLCY, SalesHeader."Currency Factor");
        IsHandled := true;
    end;

    local procedure GetMarkupFactor(CustomerNo: Code[20]): Decimal
    begin
        // Stand-in for a customer-specific markup lookup.
        exit(1.35);
    end;
}
