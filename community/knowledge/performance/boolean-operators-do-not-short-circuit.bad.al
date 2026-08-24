codeunit 50541 "Perf Sample NoShortCircuit Bad"
{
    procedure ExceedsThreshold(var Thresholds: array[10] of Decimal; Index: Integer; Amount: Decimal): Boolean
    begin
        // Thresholds[Index] is evaluated even when Index is 0, so the leading range
        // check does not prevent the subscript from being read out of range.
        exit((Index >= 1) and (Index <= ArrayLen(Thresholds)) and (Amount > Thresholds[Index]));
    end;

    procedure IsBlockedCustomer(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        // The Get runs even for an empty CustomerNo, and Blocked is read even when the
        // Get failed, so the result is taken from a record that was never loaded.
        exit((CustomerNo <> '') and Customer.Get(CustomerNo) and (Customer.Blocked <> Customer.Blocked::" "));
    end;
}
