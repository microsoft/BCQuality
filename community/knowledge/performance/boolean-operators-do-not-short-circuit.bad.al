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

    procedure IsEligibleForFreeShipping(SalesHeader: Record "Sales Header"): Boolean
    begin
        // HasActiveLoyaltyBenefit runs even when the amount alone already qualifies,
        // paying for the costly check on every evaluation instead of only the path
        // where it can still change the outcome.
        exit((SalesHeader."Amount Including VAT" >= 1000) or HasActiveLoyaltyBenefit(SalesHeader."Sell-to Customer No."));
    end;

    local procedure HasActiveLoyaltyBenefit(CustomerNo: Code[20]): Boolean
    begin
        exit(CustomerNo <> '');
    end;
}
