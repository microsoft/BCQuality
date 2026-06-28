codeunit 50300 "Discount Api Good"
{
    // Published contract — signature kept exactly as it shipped.
    procedure CalculateDiscount(Amount: Decimal): Decimal
    begin
        exit(Amount * 0.05);
    end;

    // New capability added as a separate overload, so existing callers of
    // CalculateDiscount(Amount) keep compiling. The return value is named, which
    // is the one signature change that is always safe to make.
    procedure CalculateDiscountWithRate(Amount: Decimal; Rate: Decimal) Discount: Decimal
    begin
        Discount := Amount * Rate;
    end;
}
