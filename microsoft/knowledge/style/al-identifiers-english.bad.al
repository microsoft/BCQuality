codeunit 50100 "Sales Amount Calculator"
{
    procedure BeregnTotalbeloeb(var Salgslinje: Record "Sales Line"): Decimal
    var
        Beloeb: Decimal;
    begin
        Salgslinje.CalcSums(Amount);
        Beloeb := Salgslinje.Amount;
        exit(Beloeb);
    end;
}
