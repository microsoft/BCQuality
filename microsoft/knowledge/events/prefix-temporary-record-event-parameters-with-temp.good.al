// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50270 "Temp Param Good Sample"
{
    procedure SummarizeLines(var TempSalesLineBuffer: Record "Sales Line" temporary)
    begin
        // The Temp prefix tells subscribers the buffer isn't persisted.
        OnAfterSummarizeLines(TempSalesLineBuffer);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSummarizeLines(var TempSalesLineBuffer: Record "Sales Line" temporary)
    begin
    end;
}
