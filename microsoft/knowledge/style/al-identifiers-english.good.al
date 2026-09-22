codeunit 50100 "Sales Amount Calculator"
{
    procedure CalculateTotalAmount(var SalesLine: Record "Sales Line"): Decimal
    var
        TotalAmount: Decimal;
    begin
        SalesLine.CalcSums(Amount);
        TotalAmount := SalesLine.Amount;
        exit(TotalAmount);
    end;
}
