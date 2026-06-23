// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50265 "Loop Event Good Sample"
{
    procedure ProcessLines(var SalesLine: Record "Sales Line")
    begin
        // Fire once before the loop; subscribers act on the whole set.
        OnBeforeProcessLines(SalesLine);

        if SalesLine.FindSet() then
            repeat
                SalesLine."Line Amount" := SalesLine.Quantity * SalesLine."Unit Price";
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;

        // Fire once after the loop.
        OnAfterProcessLines(SalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessLines(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessLines(var SalesLine: Record "Sales Line")
    begin
    end;
}
