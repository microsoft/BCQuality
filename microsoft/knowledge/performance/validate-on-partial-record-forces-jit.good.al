codeunit 50100 "Validate Partial Rec Good"
{
    procedure UppercaseUsCustomerNames()
    var
        Customer: Record Customer;
    begin
        // Include every field that Name.OnValidate reads so the runtime never JIT-loads.
        Customer.SetLoadFields(Name, "Search Name");
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet(true) then
            repeat
                Customer.Validate(Name, UpperCase(Customer.Name));
                Customer.Modify(false);
            until Customer.Next() = 0;
    end;
}
