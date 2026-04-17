codeunit 50103 "Perf Sample FindSetWithNext Bad"
{
    procedure SumLineAmounts(var SalesLine: Record "Sales Line") Total: Decimal
    begin
        if SalesLine.FindFirst() then
            repeat
                Total += SalesLine."Line Amount";
            until SalesLine.Next() = 0;
    end;
}
