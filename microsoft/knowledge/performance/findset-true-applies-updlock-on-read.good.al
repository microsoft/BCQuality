codeunit 50236 "Perf Sample FindSetTrue Good"
{
    procedure NormalizeNames()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet(true) then
            repeat
                Customer.Name := UpperCase(Customer.Name);
                Customer.Modify();
            until Customer.Next() = 0;
    end;

    procedure SumBalances() Total: Decimal
    var
        Customer: Record Customer;
    begin
        Customer.SetAutoCalcFields("Balance (LCY)");
        if Customer.FindSet() then
            repeat
                Total += Customer."Balance (LCY)";
            until Customer.Next() = 0;
    end;

    procedure NormalizeWithTableLock()
    var
        Customer: Record Customer;
    begin
        Customer.LockTable();
        NormalizeSelectedCustomers(Customer);
    end;

    procedure NormalizeWithRecordIsolation()
    var
        Customer: Record Customer;
    begin
        Customer.ReadIsolation := IsolationLevel::UpdLock;
        NormalizeSelectedCustomers(Customer);
    end;

    local procedure NormalizeSelectedCustomers(var Customer: Record Customer)
    begin
        if Customer.FindSet() then
            repeat
                Customer.Name := UpperCase(Customer.Name);
                Customer.Modify();
            until Customer.Next() = 0;
    end;
}
