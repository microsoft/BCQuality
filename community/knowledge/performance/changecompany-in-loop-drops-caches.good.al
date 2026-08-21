codeunit 50100 "ChangeCompany Loop Good"
{
    procedure NameInCompany(CompanyNameValue: Text[30]; CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        Customer.ChangeCompany(CompanyNameValue);
        Customer.SetLoadFields(Name);
        if Customer.Get(CustomerNo) then
            exit(Customer.Name);
    end;

    procedure NamesForCompanies(var Company: Record Company)
    var
        Customer: Record Customer;
    begin
        if Company.FindSet() then
            repeat
                Customer.ChangeCompany(Company.Name);
                Customer.SetLoadFields(Name);
                if Customer.FindFirst() then
                    Message(Customer.Name);
            until Company.Next() = 0;
    end;
}
