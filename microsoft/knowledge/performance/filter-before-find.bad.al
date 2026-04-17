codeunit 50101 "Perf Sample FilterBeforeFind Bad"
{
    procedure ProcessUsCustomers(var Customer: Record Customer)
    begin
        if Customer.FindSet() then
            repeat
                if Customer."Country/Region Code" = 'US' then
                    ProcessCustomer(Customer);
            until Customer.Next() = 0;
    end;

    local procedure ProcessCustomer(var Customer: Record Customer)
    begin
        // per-customer work
    end;
}
