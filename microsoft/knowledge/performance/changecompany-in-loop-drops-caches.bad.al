codeunit 50100 "ChangeCompany Loop Bad"
{
    procedure NamesForCustomers(var Buffer: Record Customer)
    var
        Customer: Record Customer;
        Company: Record Company;
    begin
        Customer.SetLoadFields(Name);
        if Buffer.FindSet() then
            repeat
                if Company.FindSet() then
                    repeat
                        // ChangeCompany per customer per company resets caches every row.
                        Customer.ChangeCompany(Company.Name);
                        if Customer.Get(Buffer."No.") then
                            Message(Customer.Name);
                    until Company.Next() = 0;
            until Buffer.Next() = 0;
    end;
}
