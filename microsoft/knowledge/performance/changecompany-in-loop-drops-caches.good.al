codeunit 50100 "ChangeCompany Loop Good"
{
    procedure NamesForCustomers(var Buffer: Record Customer)
    var
        Customer: Record Customer;
        Company: Record Company;
    begin
        Customer.SetLoadFields(Name);
        if Company.FindSet() then
            repeat
                Customer.ChangeCompany(Company.Name);
                if Buffer.FindSet() then
                    repeat
                        if Customer.Get(Buffer."No.") then
                            Message(Customer.Name);
                    until Buffer.Next() = 0;
            until Company.Next() = 0;
    end;
}
