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

    procedure IsEligibleForFreeShipping(SalesHeader: Record "Sales Header"): Boolean
    begin
        // 'or' is unsafe here: nesting would also be wrong, since it would drop the
        // case where the amount alone already qualifies. Exit as soon as the cheap
        // condition already decides the result; the costly lookup runs only on the
        // path where it can still change the outcome.
        if SalesHeader."Amount Including VAT" >= 1000 then
            exit(true);
        exit(HasActiveLoyaltyBenefit(SalesHeader."Sell-to Customer No."));
    end;

    local procedure HasActiveLoyaltyBenefit(CustomerNo: Code[20]): Boolean
    begin
        // Stands in for a costly check — a webservice call or a large table scan.
        exit(CustomerNo <> '');
    end;
}
