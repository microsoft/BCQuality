codeunit 50100 "Perf Sample FilterBeforeFind Good"
{
    procedure ProcessUsCustomers(var Customer: Record Customer)
    begin
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                ProcessCustomer(Customer);
            until Customer.Next() = 0;
    end;

    local procedure ProcessCustomer(var Customer: Record Customer)
    begin
        // per-customer work
    end;
}
