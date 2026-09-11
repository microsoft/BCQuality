codeunit 50600 "Directed Rounding Good"
{
    procedure RoundAmount(Value: Decimal; Precision: Decimal; IncreaseMagnitude: Boolean): Decimal
    begin
        if IncreaseMagnitude then
            exit(Round(Value, Precision, '>'));

        exit(Round(Value, Precision, '<'));
    end;
}
