// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50271 "Temp Param Bad Sample"
{
    procedure SummarizeLines(var SalesLineBuffer: Record "Sales Line" temporary)
    begin
        // Anti-pattern: the parameter is temporary but isn't named with a Temp
        // prefix, so subscribers can't tell the data isn't persisted and may
        // rely on writes that are discarded.
        OnAfterSummarizeLines(SalesLineBuffer);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSummarizeLines(var SalesLineBuffer: Record "Sales Line" temporary)
    begin
    end;
}
