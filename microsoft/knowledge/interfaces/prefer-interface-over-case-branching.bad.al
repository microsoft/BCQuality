enum 50204 "Shipping Method Bad"
{
    Extensible = true;

    value(0; Standard) { }
    value(1; Express) { }
}

codeunit 50205 "Shipping Charge Bad"
{
    // Anti-pattern: every call site must 'case' over the enum, and every new
    // shipping method forces a synchronized edit to each of these blocks.
    procedure GetRate(Method: Enum "Shipping Method Bad"; Weight: Decimal): Decimal
    begin
        case Method of
            Method::Standard:
                exit(Weight * 1.5);
            Method::Express:
                exit((Weight * 1.5) + 25);
        end;
    end;

    procedure GetDeliveryDays(Method: Enum "Shipping Method Bad"): Integer
    begin
        case Method of
            Method::Standard:
                exit(5);
            Method::Express:
                exit(1);
        end;
    end;
}
