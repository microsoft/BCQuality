codeunit 50100 "IsEmpty Before FindSet Good"
{
    procedure ListUsCustomerNames()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                Message(Customer.Name);
            until Customer.Next() = 0;
    end;
}
