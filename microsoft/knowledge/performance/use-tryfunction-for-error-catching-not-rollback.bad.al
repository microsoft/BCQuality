codeunit 50156 "Perf Sample TryFunc Bad"
{
    procedure ApplyDiscountAttempt(var Customer: Record Customer)
    begin
        if not TryApplyDiscount(Customer) then
            Message('Discount not applied');
    end;

    [TryFunction]
    local procedure TryApplyDiscount(var Customer: Record Customer)
    begin
        Customer.Validate("Customer Price Group", 'VIP');
        Customer.Modify(true);
        if Customer."Credit Limit (LCY)" <= 0 then
            Error('Customer %1 not eligible', Customer."No.");
    end;
}
