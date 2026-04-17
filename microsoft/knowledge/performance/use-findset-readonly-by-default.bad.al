codeunit 50109 "Perf Sample FindSetReadonly Bad"
{
    procedure SumInvoiceLines(var SalesLine: Record "Sales Line") Total: Decimal
    begin
        if SalesLine.FindSet(true) then
            repeat
                Total += SalesLine."Line Amount";
            until SalesLine.Next() = 0;
    end;
}
