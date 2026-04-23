codeunit 50129 "Perf Sample CommitInLoop Bad"
{
    procedure NormalizeCustomerNames()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet(true) then
            repeat
                Customer.Name := UpperCase(Customer.Name);
                Customer.Modify();
                Commit();
            until Customer.Next() = 0;
    end;
}
