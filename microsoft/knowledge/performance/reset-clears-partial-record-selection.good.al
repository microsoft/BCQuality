codeunit 50100 "Reset Clears LoadFields Good"
{
    procedure ListUsCustomerNames()
    var
        Customer: Record Customer;
    begin
        Customer.Reset();
        Customer.SetLoadFields(Name);
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                Message(Customer.Name);
            until Customer.Next() = 0;
    end;
}
