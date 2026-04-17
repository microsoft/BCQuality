codeunit 50102 "Perf Sample FindSetWithNext Good"
{
    procedure SumLineAmounts(var SalesLine: Record "Sales Line") Total: Decimal
    begin
        if SalesLine.FindSet() then
            repeat
                Total += SalesLine."Line Amount";
            until SalesLine.Next() = 0;
    end;
}
