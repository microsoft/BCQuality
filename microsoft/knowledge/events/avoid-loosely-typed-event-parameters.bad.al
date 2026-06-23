// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50286 "Typed Param Bad Sample"
{
    procedure ValidateQuantity(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    var
        RecRef: RecordRef;
    begin
        // Anti-pattern: a RecordRef drops the table type and xRec is ambiguous
        // out of context, so subscribers lose type safety and a clear contract.
        RecRef.GetTable(SalesLine);
        OnAfterValidateQuantity(RecRef, xSalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateQuantity(var RecRef: RecordRef; xSalesLine: Record "Sales Line")
    begin
    end;
}
