// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50285 "Typed Param Good Sample"
{
    procedure ValidateQuantity(var SalesLine: Record "Sales Line"; PreviousQuantity: Decimal)
    begin
        // A concrete record plus the specific value needed: type-safe contract.
        OnAfterValidateQuantity(SalesLine, PreviousQuantity);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateQuantity(var SalesLine: Record "Sales Line"; PreviousQuantity: Decimal)
    begin
    end;
}
