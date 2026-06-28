// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50256 "Event Naming Bad Sample"
{
    procedure PostSalesLine(var SalesLine: Record "Sales Line")
    var
        LineAmount: Decimal;
    begin
        // Anti-pattern: names don't encode the host routine or the
        // before/after position, so subscribers can't tell when they fire.
        BeforePost(SalesLine);

        LineAmount := SalesLine.Quantity * SalesLine."Unit Price";
        MyCustomSalesEvent(SalesLine, LineAmount);

        SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);

        SalesLineEvent(SalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure BeforePost(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure MyCustomSalesEvent(var SalesLine: Record "Sales Line"; var LineAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure SalesLineEvent(var SalesLine: Record "Sales Line")
    begin
    end;
}
