codeunit 50100 "Reset Clears LoadFields Bad"
{
    procedure ListUsCustomerNames()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        // Reset restores a full-row load; the SetLoadFields above is discarded.
        Customer.Reset();
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                Message(Customer.Name);
            until Customer.Next() = 0;
    end;
}
