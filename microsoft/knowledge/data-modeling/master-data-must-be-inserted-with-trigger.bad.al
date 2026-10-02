codeunit 50100 "Sample Customer Import"
{
    procedure CreateCustomer(ExternalName: Text[100]; ExternalCountry: Code[10]): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer.Validate(Name, ExternalName);
        Customer.Validate("Country/Region Code", ExternalCountry);
        // RunTrigger defaults to false: OnInsert never runs, so "No." stays
        // blank and no contact, salesperson, or timestamps are set.
        Customer.Insert();
        exit(Customer."No.");
    end;
}
