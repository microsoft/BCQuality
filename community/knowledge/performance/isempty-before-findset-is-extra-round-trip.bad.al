codeunit 50100 "IsEmpty Before FindSet Bad"
{
    procedure ListUsCustomerNames()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        Customer.SetRange("Country/Region Code", 'US');
        // IsEmpty does not replace FindSet; it adds a second round-trip.
        if not Customer.IsEmpty() then
            if Customer.FindSet() then
                repeat
                    Message(Customer.Name);
                until Customer.Next() = 0;
    end;
}
