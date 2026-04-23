codeunit 51117 "Style Sample ThisKeyword Bad"
{
    procedure ProcessRecord(var Customer: Record Customer)
    begin
        // Ambiguous: is ValidateCustomer a local, a global, or a method on
        // another codeunit in scope?
        ValidateCustomer(Customer);

        // No way to pass the current codeunit without `this`.
    end;

    local procedure ValidateCustomer(var Customer: Record Customer)
    begin
    end;
}
