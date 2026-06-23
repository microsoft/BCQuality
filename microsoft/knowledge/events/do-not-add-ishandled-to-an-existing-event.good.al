// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50290 "New OnBefore Good Sample"
{
    procedure CalculateTotal(var SalesHeader: Record "Sales Header")
    var
        Total: Decimal;
        IsHandled: Boolean;
    begin
        // New overridable seam added as a separate event; the existing
        // OnAfterCalculateTotal keeps its original signature and subscribers.
        IsHandled := false;
        OnBeforeCalculateTotal(SalesHeader, IsHandled);
        if not IsHandled then
            Total := 100;

        OnAfterCalculateTotal(SalesHeader, Total);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateTotal(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotal(var SalesHeader: Record "Sales Header"; Total: Decimal)
    begin
    end;
}
