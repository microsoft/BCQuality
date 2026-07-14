// Demonstration-only AL. Version 1 shipped with only CalculateAmount().
interface "I Shipping Quote Bad"
{
    procedure CalculateAmount(): Decimal;

    // Added in version 2: every existing implementer now fails to compile.
    procedure CalculateDeliveryDate(): Date;
}

codeunit 50511 "Existing Shipping Quote" implements "I Shipping Quote Bad"
{
    procedure CalculateAmount(): Decimal
    begin
        exit(10);
    end;
}
