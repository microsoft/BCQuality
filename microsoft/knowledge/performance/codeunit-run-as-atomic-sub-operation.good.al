codeunit 50142 "Perf Sample AtomicSub Good"
{
    procedure ApplyDiscountToSelection(var Customer: Record Customer)
    var
        ApplyOne: Codeunit "Perf Sample Apply Discount";
    begin
        if Customer.FindSet() then
            repeat
                ClearLastError();
                if not ApplyOne.Run(Customer) then
                    LogSkipped(Customer."No.", GetLastErrorText());
            until Customer.Next() = 0;
    end;

    local procedure LogSkipped(CustomerNo: Code[20]; ErrorText: Text)
    begin
    end;
}

codeunit 50143 "Perf Sample Apply Discount"
{
    TableNo = Customer;

    trigger OnRun()
    begin
        Rec.Validate("Customer Price Group", 'VIP');
        Rec.Modify(true);
    end;
}
