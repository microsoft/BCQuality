codeunit 50540 "Perf Sample NoShortCircuit Good"
{
    procedure ExceedsThreshold(var Thresholds: array[10] of Decimal; Index: Integer; Amount: Decimal): Boolean
    begin
        // 'and' is safe here: both operands are cheap and neither depends on the other.
        if (Index >= 1) and (Index <= ArrayLen(Thresholds)) then
            // The subscript lives in its own if, so it is never evaluated out of range.
            if Amount > Thresholds[Index] then
                exit(true);
        exit(false);
    end;

    procedure IsBlockedCustomer(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        // The cheap test runs first, and the field is read only after Get succeeded.
        if CustomerNo = '' then
            exit(false);
        if not Customer.Get(CustomerNo) then
            exit(false);
        exit(Customer.Blocked <> Customer.Blocked::" ");
    end;
}
