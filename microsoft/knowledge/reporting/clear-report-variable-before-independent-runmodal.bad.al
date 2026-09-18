codeunit 50102 "Run Customer Reports"
{
    procedure RunBlockedAndUnblockedCustomers()
    var
        Customer: Record Customer;
        CustomerList: Report "Customer - List";
    begin
        Customer.SetRange(Blocked, Customer.Blocked::All);
        CustomerList.SetTableView(Customer);
        CustomerList.RunModal();

        Customer.SetRange(Blocked, Customer.Blocked::" ");
        CustomerList.SetTableView(Customer);
        CustomerList.RunModal();
    end;
}