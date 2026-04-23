codeunit 51116 "Style Sample ThisKeyword Good"
{
    procedure ProcessRecord(var Customer: Record Customer)
    var
        Other: Codeunit "Style Sample ThisKeyword Good";
    begin
        // Clearly this codeunit's method.
        this.ValidateCustomer(Customer);

        // Only way to pass the current codeunit as an argument.
        Other.DoWith(this);
    end;

    local procedure ValidateCustomer(var Customer: Record Customer)
    begin
    end;

    procedure DoWith(var Helper: Codeunit "Style Sample ThisKeyword Good")
    begin
    end;
}
