codeunit 50100 "Validate Partial Rec Bad"
{
    procedure UppercaseUsCustomerNames()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet(true) then
            repeat
                // Validate touches other fields and TableRelation reads; JIT undoes the partial load.
                Customer.Validate(Name, UpperCase(Customer.Name));
                Customer.Modify(false);
            until Customer.Next() = 0;
    end;
}
