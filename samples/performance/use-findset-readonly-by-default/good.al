codeunit 50108 "Perf Sample FindSetReadonly Good"
{
    procedure SumInvoiceLines(var SalesLine: Record "Sales Line") Total: Decimal
    begin
        if SalesLine.FindSet() then
            repeat
                Total += SalesLine."Line Amount";
            until SalesLine.Next() = 0;
    end;
}
