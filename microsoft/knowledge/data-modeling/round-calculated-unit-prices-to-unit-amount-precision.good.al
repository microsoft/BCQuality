// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50651 "Sample Own Sales Price Good"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnUpdateUnitPriceOnBeforeFindPrice', '', false, false)]
    local procedure SetOwnUnitPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean; xSalesLine: Record "Sales Line")
    var
        Item: Record Item;
        Currency: Record Currency;
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

        // IsHandled skips the standard calculation and its RoundPrice, so this subscriber rounds
        // the final price itself: once, after every factor, to the unit-amount precision of the
        // document's currency (Initialize takes General Ledger Setup's precision for a blank code).
        Currency.Initialize(SalesHeader."Currency Code");
        SalesLine."Unit Price" :=
            Round(
                CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    SalesHeader."Posting Date", SalesHeader."Currency Code", PriceLCY, SalesHeader."Currency Factor"),
                Currency."Unit-Amount Rounding Precision");
        IsHandled := true;
    end;

    local procedure GetMarkupFactor(CustomerNo: Code[20]): Decimal
    begin
        // Stand-in for a customer-specific markup lookup.
        exit(1.35);
    end;
}
