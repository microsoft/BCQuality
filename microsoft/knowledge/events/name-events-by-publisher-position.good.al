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

    // Same position-naming convention applies to events raised from table and
    // report triggers, not just codeunit procedures.

    // Raised at the end of a table field's OnValidate trigger (for example
    // Customer."No." OnValidate): the position is "after", so OnAfter<Field>.
    procedure HandleCustomerNoValidated(var Customer: Record Customer)
    begin
        OnAfterValidateCustomerNo(Customer);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateCustomerNo(var Customer: Record Customer)
    begin
    end;

    // Raised before a report prints a line from its processing trigger (for
    // example a dataitem OnAfterGetRecord): the position is "before", so
    // OnBefore<Action>.
    procedure HandleReportLineProcessing(var SalesLine: Record "Sales Line")
    begin
        OnBeforeReportPrintLine(SalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReportPrintLine(var SalesLine: Record "Sales Line")
    begin
    end;
}
