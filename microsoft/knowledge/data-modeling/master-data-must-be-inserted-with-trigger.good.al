codeunit 50100 "Sample Customer Import"
{
    procedure CreateCustomer(ExternalName: Text[100]; ExternalCountry: Code[10]): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        // Insert(true) runs Customer.OnInsert: "No." from the number series,
        // contact and salesperson defaults (when set up), global dimensions, timestamps.
        Customer.Insert(true);
        Customer.Validate(Name, ExternalName);
        Customer.Validate("Country/Region Code", ExternalCountry);
        Customer.Modify(true);
        exit(Customer."No.");
    end;
}
