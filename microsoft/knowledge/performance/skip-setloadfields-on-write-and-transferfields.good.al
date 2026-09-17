codeunit 50100 "Skip LoadFields Write Good"
{
    procedure CopyActiveCustomers(var TempCustomer: Record Customer temporary)
    var
        Customer: Record Customer;
    begin
        // TransferFields needs all fields; omit SetLoadFields so the initial read loads the full row.
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        if Customer.FindSet() then
            repeat
                TempCustomer.TransferFields(Customer);
                TempCustomer.Insert();
            until Customer.Next() = 0;
    end;
}
