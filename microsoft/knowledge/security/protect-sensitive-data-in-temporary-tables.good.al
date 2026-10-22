codeunit 50100 "Customer Temp Processor"
{
    procedure CountScopedCustomers(CustomerNoFilter: Text): Integer
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
    begin
        Customer.SetFilter("No.", CustomerNoFilter);
        if not Customer.FindSet() then
            exit(0);

        repeat
            TempCustomer := Customer;
            TempCustomer.Insert();
        until Customer.Next() = 0;

        exit(TempCustomer.Count());
    end;
}
