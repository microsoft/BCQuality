codeunit 50601 "Directed Rounding Bad"
{
    procedure FloorAmount(Value: Decimal; Precision: Decimal): Decimal
    begin
        // For negative values, '<' rounds toward zero rather than toward negative infinity.
        exit(Round(Value, Precision, '<'));
    end;
}
