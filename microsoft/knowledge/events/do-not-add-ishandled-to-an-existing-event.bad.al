// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50291 "New OnBefore Bad Sample"
{
    procedure CalculateTotal(var SalesHeader: Record "Sales Header")
    var
        Total: Decimal;
        IsHandled: Boolean;
    begin
        Total := 100;

        // Anti-pattern: IsHandled was bolted onto the existing OnAfter event.
        // Regardless of compiler compatibility, this changes a notification
        // into an override contract that existing subscribers did not expect.
        OnAfterCalculateTotal(SalesHeader, Total, IsHandled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateTotal(var SalesHeader: Record "Sales Header"; Total: Decimal; var IsHandled: Boolean)
    begin
    end;
}
