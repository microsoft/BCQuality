// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50255 "Event Naming Good Sample"
{
    procedure PostSalesLine(var SalesLine: Record "Sales Line")
    var
        LineAmount: Decimal;
    begin
        // Start of the routine: OnBefore<Name>.
        OnBeforePostSalesLine(SalesLine);

        LineAmount := SalesLine.Quantity * SalesLine."Unit Price";
        // Middle of the routine: On<Name>OnAfter<Context>.
        OnPostSalesLineOnAfterCalcAmounts(SalesLine, LineAmount);

        SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);

        // End of the routine: OnAfter<Name>.
        OnAfterPostSalesLine(SalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSalesLine(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostSalesLineOnAfterCalcAmounts(var SalesLine: Record "Sales Line"; var LineAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSalesLine(var SalesLine: Record "Sales Line")
    begin
    end;
}
