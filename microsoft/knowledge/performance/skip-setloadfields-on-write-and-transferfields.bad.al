codeunit 50100 "Skip LoadFields Write Bad"
{
    procedure CopyActiveCustomers(var TempCustomer: Record Customer temporary)
    var
        Customer: Record Customer;
    begin
        // TransferFields requires all fields; partial load forces JIT per row.
        Customer.SetLoadFields("No.", Name);
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        if Customer.FindSet() then
            repeat
                TempCustomer.TransferFields(Customer);
                TempCustomer.Insert();
            until Customer.Next() = 0;
    end;
}
