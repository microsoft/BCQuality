// Demonstration-only AL. Interface inheritance requires runtime 14.0 / BC25.
interface "I Shipping Quote"
{
    procedure CalculateAmount(): Decimal;
}

interface "I Shipping Quote V2" extends "I Shipping Quote"
{
    procedure CalculateDeliveryDate(): Date;
}

codeunit 50510 "Shipping Quote V2" implements "I Shipping Quote V2"
{
    procedure CalculateAmount(): Decimal
    begin
        exit(10);
    end;

    procedure CalculateDeliveryDate(): Date
    begin
        exit(Today() + 1);
    end;
}
