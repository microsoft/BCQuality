codeunit 50572 "Customer Name Audit"
{
    // The outer loop is unfiltered: one extra filtered Count() per customer.
    // The question is about the whole table, not about any single row.
    procedure HasDuplicateCustomerNames(): Boolean
    var
        Customer: Record Customer;
        OtherCustomer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        if Customer.FindSet() then
            repeat
                if Customer.Name <> '' then begin
                    OtherCustomer.SetRange(Name, Customer.Name);
                    if OtherCustomer.Count() > 1 then
                        exit(true);
                end;
            until Customer.Next() = 0;
        exit(false);
    end;
}
