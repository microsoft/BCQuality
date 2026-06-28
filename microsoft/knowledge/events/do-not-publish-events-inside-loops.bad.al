// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50266 "Loop Event Bad Sample"
{
    procedure ProcessLines(var SalesLine: Record "Sales Line")
    begin
        if SalesLine.FindSet() then
            repeat
                // Anti-pattern: an event raised on every iteration. Each
                // subscriber runs once per line, so the cost scales with the
                // row count and large batches can time out.
                OnProcessLine(SalesLine);

                SalesLine."Line Amount" := SalesLine.Quantity * SalesLine."Unit Price";
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessLine(var SalesLine: Record "Sales Line")
    begin
    end;
}
