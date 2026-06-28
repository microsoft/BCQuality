// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50291 "New OnBefore Bad Sample"
{
    procedure CalculateTotal(var SalesHeader: Record "Sales Header")
    var
        Total: Decimal;
        IsHandled: Boolean;
    begin
        Total := 100;

        // Anti-pattern: IsHandled was bolted onto the existing
        // OnAfterCalculateTotal, changing its contract and breaking every
        // subscriber that matched the original signature.
        OnAfterCalculateTotal(SalesHeader, Total, IsHandled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotal(var SalesHeader: Record "Sales Header"; Total: Decimal; var IsHandled: Boolean)
    begin
    end;
}
